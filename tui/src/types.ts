export type Distro = "arch" | "fedora" | "ubuntu" | "debian" | "macos" | "windows" | "unknown";
export type PackageManager = "pacman" | "dnf" | "apt" | "brew" | "winget";
export type Category = "shell" | "terminal" | "editor" | "desktop" | "appearance" | "dev-tools" | "system" | "storage" | "social";

export interface CurlPackage {
  name: string;
  url: string;
  args?: string;
  skipIf?: string;
}

export interface SystemPackages {
  pacman?: string[];
  aur?: string[];
  dnf?: string[];
  apt?: string[];
  brew?: string[];
  winget?: string[];
  curl?: CurlPackage[];
  cargo?: string[];
}

export interface PostInstallHook {
  description: string;
  command: string;
  sudo?: boolean;
  onlyOn?: Distro[];
}

export interface ConfigPrompt {
  label: string;
  default: string;
  configFile: string;      // e.g. "~/.config/network-storage/config.env"
  configKey: string;       // e.g. "SMB_SERVER"
  secret?: boolean;        // hide input (for passwords)
  createIfMissing?: boolean; // create file if it doesn't exist (don't use for stow-managed files)
}

export interface DotfilesModule {
  id: string;
  name: string;
  description: string;
  category: Category;
  core: boolean;
  stowPackages: string[];
  systemPackages: SystemPackages;
  dependencies?: string[];
  conflicts?: string[];
  configPrompts?: ConfigPrompt[];
  postInstall?: PostInstallHook[];
  manualSteps?: string[];
  onlyOn?: Distro[];
  dirs?: string[];
  detectCommand?: string;
}

export interface ModuleState {
  installedAt: string;
  version?: string;
}

export interface DotfilesState {
  installedModules: Record<string, ModuleState>;
  lastRun: string;
  distro: Distro;
  dotfilesDir: string;
}

export type Screen = "welcome" | "categories" | "confirm" | "progress" | "complete" | "nas-monitor";

export type InstallMode = "fresh" | "manage";

export interface AppState {
  screen: Screen;
  mode: InstallMode;
  distro: Distro;
  packageManager: PackageManager;
  dotfilesDir: string;
  selectedModules: Set<string>;
  installedModules: Set<string>;
  availableModules: DotfilesModule[];
  activeCategory: Category;
  executionLog: string[];
  results: ExecutionResults;
}

export interface ExecutionResults {
  installed: string[];
  removed: string[];
  failed: { id: string; error: string }[];
  manualSteps: string[];
}
