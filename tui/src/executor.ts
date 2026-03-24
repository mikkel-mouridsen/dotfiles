import { mkdirSync } from "fs";
import type { DotfilesModule, Distro, PackageManager, ExecutionResults } from "./types";
import { detectAurHelper, isWindows, getHome } from "./detect";
import { link, unlink } from "./linker";

type LogFn = (line: string) => void;

export class Executor {
  private distro: Distro;
  private packageManager: PackageManager;
  private dotfilesDir: string;
  private log: LogFn;
  private aurHelper: string | null = null;

  constructor(distro: Distro, packageManager: PackageManager, dotfilesDir: string, log: LogFn) {
    this.distro = distro;
    this.packageManager = packageManager;
    this.dotfilesDir = dotfilesDir;
    this.log = log;
  }

  async init(): Promise<void> {
    if (this.distro === "windows") return;
    if (this.distro === "arch") {
      this.aurHelper = await detectAurHelper();
      if (!this.aurHelper) {
        this.log("No AUR helper found. Installing paru...");
        await this.runCommand("sudo pacman -S --needed --noconfirm base-devel git");
        await this.runCommand("git clone https://aur.archlinux.org/paru.git /tmp/paru-build");
        await this.runCommand("cd /tmp/paru-build && makepkg -si --noconfirm");
        this.aurHelper = "paru";
      }
    }
  }

  async installModule(mod: DotfilesModule): Promise<{ success: boolean; error?: string }> {
    try {
      this.log(`\n--- Installing ${mod.name} ---`);

      // 1. Install system packages
      await this.installSystemPackages(mod);

      // 2. Create directories
      if (mod.dirs) {
        const home = getHome();
        for (const dir of mod.dirs) {
          const expanded = dir.replace("~", home);
          mkdirSync(expanded, { recursive: true });
        }
      }

      // 3. Link config files
      for (const pkg of mod.stowPackages) {
        if (isWindows) {
          this.log(`Linking ${pkg}...`);
          link(pkg, {
            dotfilesDir: this.dotfilesDir,
            homeDir: getHome(),
            log: (msg) => this.log(msg),
          });
          // Restore repo versions after adopt
          await this.runCommand(`git -C "${this.dotfilesDir}" checkout -- "${pkg}"`);
        } else {
          this.log(`Stowing ${pkg}...`);
          try {
            await this.runCommand(`cd "${this.dotfilesDir}" && stow -v --target="$HOME" "${pkg}"`);
          } catch {
            this.log(`Conflict detected — adopting existing files for ${pkg}...`);
            await this.runCommand(`cd "${this.dotfilesDir}" && stow --adopt -v --target="$HOME" "${pkg}"`);
            await this.runCommand(`cd "${this.dotfilesDir}" && git checkout -- "${pkg}"`);
          }
        }
      }

      // 4. Post-install hooks
      if (mod.postInstall) {
        for (const hook of mod.postInstall) {
          if (hook.onlyOn && !hook.onlyOn.includes(this.distro)) continue;
          this.log(`Running: ${hook.description}`);
          await this.runCommand(hook.command);
        }
      }

      this.log(`Installed ${mod.name} successfully`);
      return { success: true };
    } catch (err) {
      const msg = err instanceof Error ? err.message : String(err);
      this.log(`ERROR installing ${mod.name}: ${msg}`);
      return { success: false, error: msg };
    }
  }

  async uninstallModule(mod: DotfilesModule): Promise<{ success: boolean; error?: string }> {
    try {
      this.log(`\n--- Removing ${mod.name} ---`);

      for (const pkg of mod.stowPackages) {
        if (isWindows) {
          this.log(`Unlinking ${pkg}...`);
          unlink(pkg, {
            dotfilesDir: this.dotfilesDir,
            homeDir: getHome(),
            log: (msg) => this.log(msg),
          });
        } else {
          this.log(`Unstowing ${pkg}...`);
          await this.runCommand(`cd "${this.dotfilesDir}" && stow -D --target="$HOME" "${pkg}"`);
        }
      }

      this.log(`Removed ${mod.name}`);
      return { success: true };
    } catch (err) {
      const msg = err instanceof Error ? err.message : String(err);
      this.log(`ERROR removing ${mod.name}: ${msg}`);
      return { success: false, error: msg };
    }
  }

  private async installSystemPackages(mod: DotfilesModule): Promise<void> {
    const pkgs = mod.systemPackages;

    // Pacman packages
    if (this.packageManager === "pacman" && pkgs.pacman?.length) {
      this.log(`Installing pacman packages: ${pkgs.pacman.join(", ")}`);
      await this.runCommand(`sudo pacman -S --needed --noconfirm ${pkgs.pacman.join(" ")}`);
    }

    // AUR packages
    if (this.distro === "arch" && pkgs.aur?.length && this.aurHelper) {
      this.log(`Installing AUR packages: ${pkgs.aur.join(", ")}`);
      await this.runCommand(`${this.aurHelper} -S --needed --noconfirm ${pkgs.aur.join(" ")}`);
    }

    // DNF packages
    if (this.packageManager === "dnf" && pkgs.dnf?.length) {
      this.log(`Installing dnf packages: ${pkgs.dnf.join(", ")}`);
      await this.runCommand(`sudo dnf install -y ${pkgs.dnf.join(" ")}`);
    }

    // APT packages
    if (this.packageManager === "apt" && pkgs.apt?.length) {
      this.log(`Installing apt packages: ${pkgs.apt.join(", ")}`);
      await this.runCommand(`sudo apt-get install -y ${pkgs.apt.join(" ")}`);
    }

    // Brew packages
    if (this.packageManager === "brew" && pkgs.brew?.length) {
      this.log(`Installing brew packages: ${pkgs.brew.join(", ")}`);
      await this.runCommand(`brew install ${pkgs.brew.join(" ")}`);
    }

    // Winget packages
    if (this.packageManager === "winget" && pkgs.winget?.length) {
      for (const pkg of pkgs.winget) {
        this.log(`Installing ${pkg} via winget...`);
        await this.runCommand(`winget install -e --id ${pkg} --accept-package-agreements --accept-source-agreements`);
      }
    }

    // Curl installs (for non-packaged software — skip on Windows, use winget instead)
    if (pkgs.curl?.length && !isWindows) {
      for (const curl of pkgs.curl) {
        if (curl.skipIf) {
          const whichCmd = isWindows ? "where" : "which";
          const check = Bun.spawnSync([whichCmd, curl.skipIf]);
          if (check.exitCode === 0) {
            this.log(`Skipping ${curl.name} (already installed)`);
            continue;
          }
        }
        this.log(`Installing ${curl.name} via curl...`);
        const args = curl.args ? ` | sh -s -- ${curl.args}` : " | sh";
        await this.runCommand(`curl -fsSL "${curl.url}"${args}`);
      }
    }

    // Cargo packages
    if (pkgs.cargo?.length) {
      for (const pkg of pkgs.cargo) {
        this.log(`Installing ${pkg} via cargo...`);
        await this.runCommand(`cargo install ${pkg}`);
      }
    }
  }

  refreshSudo(): void {
    if (isWindows) return;
    // Silently extend sudo timeout between modules
    Bun.spawnSync(["sudo", "-v", "-n"], { stdout: "pipe", stderr: "pipe" });
  }

  private async runCommand(command: string): Promise<string> {
    const shell = isWindows
      ? ["powershell", "-NoProfile", "-NonInteractive", "-Command", command]
      : ["bash", "-c", command];
    const proc = Bun.spawn(shell, {
      stdin: "inherit",
      stdout: "pipe",
      stderr: "pipe",
      env: { ...process.env },
    });

    const fullOutput: string[] = [];

    const streamLines = async (stream: ReadableStream<Uint8Array>) => {
      const reader = stream.getReader();
      const decoder = new TextDecoder();
      let buffer = "";

      while (true) {
        const { done, value } = await reader.read();
        if (done) break;

        buffer += decoder.decode(value, { stream: true });
        const lines = buffer.split("\n");
        buffer = lines.pop() ?? "";

        for (const line of lines) {
          if (line.trim()) {
            this.log(line);
            fullOutput.push(line);
          }
        }
      }

      if (buffer.trim()) {
        this.log(buffer);
        fullOutput.push(buffer);
      }
    };

    await Promise.all([
      streamLines(proc.stdout as ReadableStream),
      streamLines(proc.stderr as ReadableStream),
    ]);

    const exitCode = await proc.exited;

    if (exitCode !== 0) {
      throw new Error(`Command failed (exit ${exitCode}): ${command}`);
    }

    return fullOutput.join("\n");
  }
}

export async function executeInstallPlan(
  toInstall: DotfilesModule[],
  toRemove: DotfilesModule[],
  distro: Distro,
  packageManager: PackageManager,
  dotfilesDir: string,
  log: LogFn,
): Promise<ExecutionResults> {
  const executor = new Executor(distro, packageManager, dotfilesDir, log);
  await executor.init();

  const results: ExecutionResults = {
    installed: [],
    removed: [],
    failed: [],
    manualSteps: [],
  };

  // Remove first (reverse order)
  for (const mod of toRemove) {
    executor.refreshSudo();
    const result = await executor.uninstallModule(mod);
    if (result.success) {
      results.removed.push(mod.id);
    } else {
      results.failed.push({ id: mod.id, error: result.error ?? "Unknown error" });
    }
  }

  // Then install
  for (const mod of toInstall) {
    executor.refreshSudo();
    const result = await executor.installModule(mod);
    if (result.success) {
      results.installed.push(mod.id);
      if (mod.manualSteps) {
        results.manualSteps.push(...mod.manualSteps.map((s) => `[${mod.name}] ${s}`));
      }
    } else {
      results.failed.push({ id: mod.id, error: result.error ?? "Unknown error" });
    }
  }

  return results;
}
