import type { DotfilesModule, Distro, PackageManager, ExecutionResults } from "./types";
import { detectAurHelper } from "./detect";

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
        for (const dir of mod.dirs) {
          const expanded = dir.replace("~", process.env.HOME!);
          await this.runCommand(`mkdir -p "${expanded}"`);
        }
      }

      // 3. Stow packages
      for (const pkg of mod.stowPackages) {
        this.log(`Stowing ${pkg}...`);
        await this.runCommand(`cd "${this.dotfilesDir}" && stow -v --target="$HOME" "${pkg}"`);
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
        this.log(`Unstowing ${pkg}...`);
        await this.runCommand(`cd "${this.dotfilesDir}" && stow -D --target="$HOME" "${pkg}"`);
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

    // Curl installs (for non-packaged software)
    if (pkgs.curl?.length) {
      for (const curl of pkgs.curl) {
        if (curl.skipIf) {
          const check = Bun.spawnSync(["which", curl.skipIf]);
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
    // Silently extend sudo timeout between modules
    Bun.spawnSync(["sudo", "-v", "-n"], { stdout: "pipe", stderr: "pipe" });
  }

  private async runCommand(command: string): Promise<string> {
    const proc = Bun.spawn(["bash", "-c", command], {
      stdin: "inherit",
      stdout: "pipe",
      stderr: "pipe",
      env: { ...process.env, HOME: process.env.HOME },
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
