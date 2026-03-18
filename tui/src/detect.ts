import { readFileSync, existsSync, lstatSync, readlinkSync, realpathSync } from "fs";
import type { Distro, PackageManager } from "./types";

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
    default:
      return "pacman";
  }
}

export async function detectAurHelper(): Promise<string | null> {
  for (const helper of ["paru", "yay"]) {
    const result = Bun.spawnSync(["which", helper]);
    if (result.exitCode === 0) return helper;
  }
  return null;
}

export function detectDotfilesDir(): string {
  const candidates = [
    process.env.DOTFILES_DIR,
    `${process.env.HOME}/.dotfiles`,
    `${process.env.HOME}/dotfiles`,
  ];

  for (const dir of candidates) {
    if (dir && existsSync(`${dir}/install.sh`)) return dir;
  }

  // Fall back to parent of tui directory
  return new URL("../../", import.meta.url).pathname.replace(/\/$/, "");
}

export function isStowLinked(dotfilesDir: string, stowPackage: string): boolean {
  const packageDir = `${dotfilesDir}/${stowPackage}`;
  if (!existsSync(packageDir)) return false;

  try {
    const result = Bun.spawnSync(["find", packageDir, "-type", "f", "-not", "-name", ".DS_Store"], {
      stdout: "pipe",
    });
    const files = new TextDecoder().decode(result.stdout).trim().split("\n").filter(Boolean);
    if (files.length === 0) return false;

    const firstFile = files[0];
    const relativePath = firstFile.replace(`${packageDir}/`, "");

    // Stow targets $HOME, so the expected location is $HOME/<relativePath>.
    // But some packages (e.g. greetd) have files under etc/ that get copied
    // to /etc/ rather than stow-linked — handle both cases.
    const homePath = `${process.env.HOME}/${relativePath}`;

    if (existsSync(homePath)) {
      // realpathSync resolves through symlinked ancestor directories,
      // so this works whether stow linked a parent dir or individual files.
      const realPath = realpathSync(homePath);
      return realPath.startsWith(dotfilesDir);
    }

    // For non-$HOME packages: check if the file exists at its absolute path
    // (e.g. etc/greetd/config.toml → /etc/greetd/config.toml)
    const absolutePath = `/${relativePath}`;
    if (existsSync(absolutePath)) {
      return true;
    }

    return false;
  } catch {
    return false;
  }
}

export function isDetectCommandPassing(command: string): boolean {
  try {
    const result = Bun.spawnSync(["bash", "-c", command]);
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
    unknown: "Unknown",
  };
  return names[distro];
}
