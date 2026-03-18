import { createCliRenderer, type CliRenderer, type KeyEvent, instantiate } from "@opentui/core";
import type { AppState, Screen, InstallMode, Category, DotfilesModule, ExecutionResults, ConfigPrompt } from "./types";
import { readFileSync, writeFileSync, existsSync } from "fs";
import { modules, getModuleById, getCategories } from "./registry";
import { detectDistro, detectPackageManager, detectDotfilesDir, isStowLinked, isDetectCommandPassing } from "./detect";
import { loadState, saveState, createInitialState, markInstalled, markRemoved, getInstalledModuleIds } from "./state";
import { resolveDependencies, checkDependents, topologicalSort, reverseTopologicalSort, hasConflicts } from "./deps";
import { executeInstallPlan } from "./executor";
import { WelcomeScreen } from "./screens/welcome";
import { CategoriesScreen } from "./screens/categories";
import { ConfirmScreen } from "./screens/confirm";
import { ProgressScreen } from "./screens/progress";
import { CompleteScreen } from "./screens/complete";

export class App {
  private state: AppState;
  private renderer!: CliRenderer;
  private dotfilesState: ReturnType<typeof loadState>;

  // UI state
  private welcomeFocus = 0;
  private categoryIndex = 0;
  private moduleIndex = 0;
  private moduleScrollOffset = 0;
  private confirmFocus = 0;
  private completeFocus = 0;
  private pane: "categories" | "modules" = "modules";

  // Progress state
  private executionLog: string[] = [];
  private currentModule: string | null = null;
  private completedModules = 0;
  private totalModules = 0;
  private executionDone = false;
  private executionResults: ExecutionResults = {
    installed: [],
    removed: [],
    failed: [],
    manualSteps: [],
  };

  constructor() {
    const distro = detectDistro();
    const packageManager = detectPackageManager(distro);
    const dotfilesDir = detectDotfilesDir();

    this.dotfilesState = loadState();

    // Filter modules available for this distro
    const availableModules = modules.filter(
      (m) => !m.onlyOn || m.onlyOn.includes(distro),
    );

    // Detect currently installed modules via stow link checking + detect commands.
    // Always do live detection so state stays accurate even if the state file is stale.
    const installedModules = new Set<string>();
    if (this.dotfilesState) {
      // Seed from persisted state
      for (const id of getInstalledModuleIds(this.dotfilesState)) {
        installedModules.add(id);
      }
    }
    // Live detection: add any modules that are actually linked/installed
    for (const mod of availableModules) {
      if (installedModules.has(mod.id)) continue;
      if (mod.stowPackages.length > 0) {
        const allLinked = mod.stowPackages.every((pkg) => isStowLinked(dotfilesDir, pkg));
        if (allLinked) installedModules.add(mod.id);
      } else if (mod.detectCommand) {
        if (isDetectCommandPassing(mod.detectCommand)) installedModules.add(mod.id);
      }
    }

    this.state = {
      screen: "welcome",
      mode: "fresh",
      distro,
      packageManager,
      dotfilesDir,
      selectedModules: new Set(),
      installedModules,
      availableModules,
      activeCategory: "shell",
      executionLog: [],
      results: this.executionResults,
    };
  }

  async run(): Promise<void> {
    this.renderer = await createCliRenderer({
      exitOnCtrlC: true,
      useAlternateScreen: true,
      backgroundColor: "#1e1e2e",
    });

    this.renderer.keyInput.on("keypress", (key: KeyEvent) => this.handleKey(key));

    this.render();
    this.renderer.start();
  }

  private render(): void {
    let vnode;
    switch (this.state.screen) {
      case "welcome":
        vnode = WelcomeScreen(this.state, this.welcomeFocus);
        break;
      case "categories":
        vnode = CategoriesScreen(
          this.state,
          this.categoryIndex,
          this.moduleIndex,
          this.moduleScrollOffset,
          this.pane,
        );
        break;
      case "confirm":
        vnode = ConfirmScreen(
          this.state,
          this.getToInstall(),
          this.getToRemove(),
          this.confirmFocus,
        );
        break;
      case "progress":
        vnode = ProgressScreen(
          this.executionLog,
          this.currentModule,
          this.completedModules,
          this.totalModules,
          this.executionDone,
        );
        break;
      case "complete":
        vnode = CompleteScreen(this.executionResults, this.completeFocus);
        break;
    }

    // Clear existing children and add new tree
    const root = this.renderer.root;
    for (const child of root.getChildren()) {
      root.remove(child.id);
    }
    root.add(instantiate(this.renderer, vnode));
    this.renderer.requestRender();
  }

  private handleKey(key: KeyEvent): void {
    // Global quit
    if (key.name === "q" && (this.state.screen === "welcome" || this.state.screen === "complete")) {
      this.renderer.destroy();
      process.exit(0);
    }

    switch (this.state.screen) {
      case "welcome":
        this.handleWelcomeKey(key);
        break;
      case "categories":
        this.handleCategoriesKey(key);
        break;
      case "confirm":
        this.handleConfirmKey(key);
        break;
      case "progress":
        this.handleProgressKey(key);
        break;
      case "complete":
        this.handleCompleteKey(key);
        break;
    }

    this.render();
  }

  private handleWelcomeKey(key: KeyEvent): void {
    if (key.name === "j" || key.name === "down") {
      this.welcomeFocus = Math.min(1, this.welcomeFocus + 1);
    } else if (key.name === "k" || key.name === "up") {
      this.welcomeFocus = Math.max(0, this.welcomeFocus - 1);
    } else if (key.name === "return") {
      this.state.mode = this.welcomeFocus === 0 ? "fresh" : "manage";

      if (this.state.mode === "fresh") {
        this.state.selectedModules = new Set(
          this.state.availableModules.filter((m) => m.core).map((m) => m.id),
        );
      } else {
        this.state.selectedModules = new Set(this.state.installedModules);
      }

      this.state.screen = "categories";
      this.categoryIndex = 0;
      this.moduleIndex = 0;
    }
  }

  private handleCategoriesKey(key: KeyEvent): void {
    const categories = this.getVisibleCategories();
    const categoryModules = this.getCategoryModules(categories[this.categoryIndex]);

    if (key.name === "tab") {
      this.pane = this.pane === "categories" ? "modules" : "categories";
    } else if (key.name === "escape") {
      this.state.screen = "welcome";
    } else if (key.name === "return") {
      this.state.screen = "confirm";
      this.confirmFocus = 0;
    }

    if (this.pane === "categories") {
      if (key.name === "j" || key.name === "down") {
        this.categoryIndex = Math.min(categories.length - 1, this.categoryIndex + 1);
        this.moduleIndex = 0;
        this.moduleScrollOffset = 0;
      } else if (key.name === "k" || key.name === "up") {
        this.categoryIndex = Math.max(0, this.categoryIndex - 1);
        this.moduleIndex = 0;
        this.moduleScrollOffset = 0;
      }
    } else {
      if (key.name === "j" || key.name === "down") {
        this.moduleIndex = Math.min(categoryModules.length - 1, this.moduleIndex + 1);
        if (this.moduleIndex >= this.moduleScrollOffset + 15) {
          this.moduleScrollOffset = this.moduleIndex - 14;
        }
      } else if (key.name === "k" || key.name === "up") {
        this.moduleIndex = Math.max(0, this.moduleIndex - 1);
        if (this.moduleIndex < this.moduleScrollOffset) {
          this.moduleScrollOffset = this.moduleIndex;
        }
      } else if (key.name === "space") {
        this.toggleModule(categoryModules[this.moduleIndex]);
      }
    }
  }

  private handleConfirmKey(key: KeyEvent): void {
    if (key.name === "escape") {
      this.state.screen = "categories";
    } else if (key.name === "tab") {
      this.confirmFocus = this.confirmFocus === 0 ? 1 : 0;
    } else if (key.name === "return") {
      if (this.confirmFocus === 0) {
        this.startExecution();
      } else {
        this.state.screen = "categories";
      }
    }
  }

  private handleProgressKey(key: KeyEvent): void {
    if (key.name === "return" && this.executionDone) {
      this.state.screen = "complete";
      this.completeFocus = 0;
    }
  }

  private handleCompleteKey(key: KeyEvent): void {
    const hasFailures = this.executionResults.failed.length > 0;
    if (key.name === "tab" && hasFailures) {
      this.completeFocus = this.completeFocus === 0 ? 1 : 0;
    } else if (key.name === "return") {
      if (this.completeFocus === 0) {
        this.renderer.destroy();
        process.exit(0);
      } else if (hasFailures) {
        this.startExecution(true);
      }
    }
  }

  private toggleModule(mod: DotfilesModule | undefined): void {
    if (!mod) return;

    if (this.state.selectedModules.has(mod.id)) {
      const dependents = checkDependents(mod.id, this.state.availableModules, this.state.selectedModules);
      if (dependents.length > 0) {
        for (const depId of dependents) {
          this.state.selectedModules.delete(depId);
        }
      }
      this.state.selectedModules.delete(mod.id);
    } else {
      const conflicts = hasConflicts(mod.id, this.state.availableModules, this.state.selectedModules);
      if (conflicts.length > 0) {
        for (const cId of conflicts) {
          this.state.selectedModules.delete(cId);
        }
      }

      this.state.selectedModules.add(mod.id);

      const deps = resolveDependencies(mod.id, this.state.availableModules, this.state.selectedModules);
      for (const depId of deps) {
        this.state.selectedModules.add(depId);
      }
    }
  }

  private getVisibleCategories(): Category[] {
    return [...new Set(this.state.availableModules.map((m) => m.category))] as Category[];
  }

  private getCategoryModules(category: Category | undefined): DotfilesModule[] {
    if (!category) return [];
    return this.state.availableModules.filter((m) => m.category === category);
  }

  private getToInstall(): DotfilesModule[] {
    const ids = [...this.state.selectedModules].filter(
      (id) => !this.state.installedModules.has(id),
    );
    const sorted = topologicalSort(ids, this.state.availableModules);
    return sorted.map((id) => getModuleById(id)).filter(Boolean) as DotfilesModule[];
  }

  private getToRemove(): DotfilesModule[] {
    const ids = [...this.state.installedModules].filter(
      (id) => !this.state.selectedModules.has(id),
    );
    const sorted = reverseTopologicalSort(ids, this.state.availableModules);
    return sorted.map((id) => getModuleById(id)).filter(Boolean) as DotfilesModule[];
  }

  private needsSudo(toInstall: DotfilesModule[], toRemove: DotfilesModule[]): boolean {
    return [...toInstall, ...toRemove].some((mod) => {
      const hasSudoPackages =
        (mod.systemPackages.pacman?.length ?? 0) > 0 ||
        (mod.systemPackages.dnf?.length ?? 0) > 0 ||
        (mod.systemPackages.apt?.length ?? 0) > 0;
      const hasSudoHooks = mod.postInstall?.some(
        (h) => h.sudo || h.command.includes("sudo"),
      );
      return hasSudoPackages || hasSudoHooks;
    });
  }

  private async leaveScreen(): Promise<void> {
    this.renderer.destroy();
  }

  private async reenterScreen(): Promise<void> {
    this.renderer = await createCliRenderer({
      exitOnCtrlC: true,
      useAlternateScreen: true,
      backgroundColor: "#1e1e2e",
    });
    this.renderer.keyInput.on("keypress", (key: KeyEvent) => this.handleKey(key));
  }

  private async acquireSudo(): Promise<void> {
    await this.leaveScreen();

    console.log("\n  Elevated privileges are required for installation.");
    console.log("  You may be prompted for your password.\n");

    const proc = Bun.spawnSync(["sudo", "-v"], {
      stdin: "inherit",
      stdout: "inherit",
      stderr: "inherit",
    });

    if (proc.exitCode !== 0) {
      console.log("  Failed to acquire sudo credentials. Proceeding anyway...\n");
    }

    await this.reenterScreen();
  }

  private async runConfigPrompts(modulesToInstall: DotfilesModule[]): Promise<void> {
    const prompts: { mod: DotfilesModule; prompt: ConfigPrompt }[] = [];
    for (const mod of modulesToInstall) {
      if (mod.configPrompts) {
        for (const p of mod.configPrompts) {
          prompts.push({ mod, prompt: p });
        }
      }
    }
    if (prompts.length === 0) return;

    await this.leaveScreen();

    console.log("\n  ━━━ Module Configuration ━━━\n");

    for (const { mod, prompt } of prompts) {
      const configPath = prompt.configFile.replace("~", process.env.HOME!);

      // Read current value from config file if it exists
      let currentValue = prompt.default;
      if (existsSync(configPath)) {
        const content = readFileSync(configPath, "utf-8");
        const match = content.match(new RegExp(`^${prompt.configKey}=(.*)$`, "m"));
        if (match) currentValue = match[1];
      }

      // Prompt user — use read -s for secret fields to hide input
      let proc;
      if (prompt.secret) {
        const displayDefault = currentValue ? "********" : "empty";
        proc = Bun.spawnSync(
          ["bash", "-c", `read -srp "  [${mod.name}] ${prompt.label} [${displayDefault}]: " val; echo "$val"`],
          { stdin: "inherit", stdout: "pipe", stderr: "inherit" },
        );
        // Print newline after hidden input
        console.log("");
      } else {
        proc = Bun.spawnSync(
          ["bash", "-c", `read -rp "  [${mod.name}] ${prompt.label} [${currentValue}]: " val; echo "$val"`],
          { stdin: "inherit", stdout: "pipe", stderr: "inherit" },
        );
      }
      const input = new TextDecoder().decode(proc.stdout).trim();
      const value = input || currentValue;

      // Write value to config file
      if (existsSync(configPath)) {
        let content = readFileSync(configPath, "utf-8");
        const regex = new RegExp(`^${prompt.configKey}=.*$`, "m");
        if (regex.test(content)) {
          content = content.replace(regex, `${prompt.configKey}=${value}`);
        } else {
          content += `\n${prompt.configKey}=${value}\n`;
        }
        writeFileSync(configPath, content);
      } else if (prompt.createIfMissing) {
        // Only create files that aren't managed by stow
        const dir = configPath.substring(0, configPath.lastIndexOf("/"));
        Bun.spawnSync(["mkdir", "-p", dir]);
        writeFileSync(configPath, `${prompt.configKey}=${value}\n`, { mode: 0o600 });
      }

      // Display confirmation (mask secrets)
      if (prompt.secret) {
        console.log(`  → ${prompt.configKey}=${value ? "********" : "(empty)"}`);
      } else {
        console.log(`  → ${prompt.configKey}=${value}`);
      }
    }

    console.log("");
    await this.reenterScreen();
  }

  private async startExecution(retryOnly = false): Promise<void> {
    this.executionLog = [];
    this.executionDone = false;
    this.completedModules = 0;

    const toInstall = retryOnly
      ? this.executionResults.failed
          .map((f) => getModuleById(f.id))
          .filter(Boolean) as DotfilesModule[]
      : this.getToInstall();
    const toRemove = retryOnly ? [] : this.getToRemove();
    this.totalModules = toInstall.length + toRemove.length;

    // Run interactive config prompts before entering progress screen
    await this.runConfigPrompts(toInstall);

    // Acquire sudo before entering the progress screen
    if (this.needsSudo(toInstall, toRemove)) {
      // Check if sudo is already cached (non-interactive check)
      const check = Bun.spawnSync(["sudo", "-n", "true"], {
        stdout: "pipe",
        stderr: "pipe",
      });
      if (check.exitCode !== 0) {
        await this.acquireSudo();
      }
    }

    this.state.screen = "progress";
    this.render();

    const log = (line: string) => {
      this.executionLog.push(line);

      if (line.startsWith("--- Installing") || line.startsWith("--- Removing")) {
        const match = line.match(/--- (?:Installing|Removing) (.+) ---/);
        if (match) this.currentModule = match[1];
      }
      if (line.startsWith("Installed") || line.startsWith("Removed")) {
        this.completedModules++;
      }

      this.render();
    };

    this.executionResults = await executeInstallPlan(
      toInstall,
      toRemove,
      this.state.distro,
      this.state.packageManager,
      this.state.dotfilesDir,
      log,
    );

    // Update persisted state
    const persistedState = this.dotfilesState ?? createInitialState(this.state.distro, this.state.dotfilesDir);
    for (const id of this.executionResults.installed) {
      markInstalled(persistedState, id);
      this.state.installedModules.add(id);
    }
    for (const id of this.executionResults.removed) {
      markRemoved(persistedState, id);
      this.state.installedModules.delete(id);
    }
    saveState(persistedState);

    this.executionDone = true;
    this.currentModule = null;
    this.state.results = this.executionResults;
    this.render();
  }
}
