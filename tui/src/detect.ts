import { readFileSync, existsSync, lstatSync, readdirSync, realpathSync } from "fs";
import { join } from "path";
import type { Distro, PackageManager } from "./types";

export const isWindows = process.platform === "win32";

export function getHome(): string {
  return process.env.HOME || process.env.USERPROFILE || "";
}

const DISTRO_MAP: Record<string, Distro> = {
  arch: "arch",
  cachyos: "arch",
  endeavouros: "arch",
  manjaro: "arch",
  fedora: "fedora",
  ubuntu: "ubuntu",
  debian: "debian",
  pop: "ubuntu",
  linuxmint: "ubuntu",
};

export function detectDistro(): Distro {
  if (process.platform === "win32") return "windows";
  if (process.platform === "darwin") return "macos";

  try {
    const osRelease = readFileSync("/etc/os-release", "utf-8");
    const idMatch = osRelease.match(/^ID=(.+)$/m);
    if (idMatch) {
      const id = idMatch[1].replace(/"/g, "").trim().toLowerCase();
      return DISTRO_MAP[id] ?? "unknown";
    }
  } catch {}

  return "unknown";
}

export function detectPackageManager(distro: Distro): PackageManager {
  switch (distro) {
    case "arch":
      return "pacman";
    case "fedora":
      return "dnf";
    case "ubuntu":
    case "debian":
      return "apt";
    case "macos":
      return "brew";
    case "windows":
      return "winget";
    default:
      return "pacman";
  }
}

export async function detectAurHelper(): Promise<string | null> {
  if (isWindows) return null;
  for (const helper of ["paru", "yay"]) {
    const result = Bun.spawnSync(["which", helper]);
    if (result.exitCode === 0) return helper;
  }
  return null;
}

export function detectDotfilesDir(): string {
  const home = getHome();
  const candidates = [
    process.env.DOTFILES_DIR,
    join(home, ".dotfiles"),
    join(home, "dotfiles"),
  ];

  for (const dir of candidates) {
    if (dir && existsSync(join(dir, "tui", "index.ts"))) return dir;
  }

  // Fall back to parent of tui directory
  let fallback = new URL("../../", import.meta.url).pathname.replace(/\/$/, "");
  // On Windows, file:///C:/... gives pathname /C:/... — strip the leading slash
  if (isWindows) fallback = fallback.replace(/^\/([A-Za-z]:)/, "$1");
  return fallback;
}

export function walkFiles(dir: string): string[] {
  const results: string[] = [];
  try {
    for (const entry of readdirSync(dir, { withFileTypes: true })) {
      if (entry.name === ".DS_Store") continue;
      const full = join(dir, entry.name);
      if (entry.isDirectory()) results.push(...walkFiles(full));
      else results.push(full);
    }
  } catch {}
  return results;
}

export function isStowLinked(dotfilesDir: string, stowPackage: string): boolean {
  const packageDir = join(dotfilesDir, stowPackage);
  if (!existsSync(packageDir)) return false;

  try {
    const files = walkFiles(packageDir);
    if (files.length === 0) return false;

    const firstFile = files[0];
    const relativePath = firstFile.slice(packageDir.length + 1);
    const home = getHome();

    // Stow targets $HOME, so the expected location is $HOME/<relativePath>.
    // But some packages (e.g. greetd) have files under etc/ that get copied
    // to /etc/ rather than stow-linked — handle both cases.
    const homePath = join(home, relativePath);

    if (existsSync(homePath)) {
      // realpathSync resolves through symlinked ancestor directories,
      // so this works whether stow linked a parent dir or individual files.
      const realPath = realpathSync(homePath);
      return realPath.startsWith(dotfilesDir);
    }

    // For non-$HOME packages: check if the file exists at its absolute path
    // (e.g. etc/greetd/config.toml → /etc/greetd/config.toml)
    if (!isWindows) {
      const absolutePath = `/${relativePath}`;
      if (existsSync(absolutePath)) {
        return true;
      }
    }

    return false;
  } catch {
    return false;
  }
}

export function isDetectCommandPassing(command: string): boolean {
  try {
    const shell = isWindows
      ? ["cmd", "/c", command]
      : ["bash", "-c", command];
    const result = Bun.spawnSync(shell);
    return result.exitCode === 0;
  } catch {
    return false;
  }
}

export function getDistroName(distro: Distro): string {
  const names: Record<Distro, string> = {
    arch: "Arch Linux",
    fedora: "Fedora",
    ubuntu: "Ubuntu",
    debian: "Debian",
    macos: "macOS",
    windows: "Windows",
    unknown: "Unknown",
  };
  return names[distro];
}
