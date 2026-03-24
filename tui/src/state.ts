import { existsSync, readFileSync, writeFileSync, mkdirSync } from "fs";
import { dirname, join } from "path";
import type { DotfilesState, Distro } from "./types";
import { getHome } from "./detect";

const STATE_PATH = join(getHome(), ".dotfiles-state.json");

export function loadState(): DotfilesState | null {
  try {
    if (!existsSync(STATE_PATH)) return null;
    const data = readFileSync(STATE_PATH, "utf-8");
    return JSON.parse(data) as DotfilesState;
  } catch {
    return null;
  }
}

export function saveState(state: DotfilesState): void {
  const dir = dirname(STATE_PATH);
  if (!existsSync(dir)) mkdirSync(dir, { recursive: true });
  writeFileSync(STATE_PATH, JSON.stringify(state, null, 2) + "\n");
}

export function createInitialState(distro: Distro, dotfilesDir: string): DotfilesState {
  return {
    installedModules: {},
    lastRun: new Date().toISOString(),
    distro,
    dotfilesDir,
  };
}

export function markInstalled(state: DotfilesState, moduleId: string): void {
  state.installedModules[moduleId] = {
    installedAt: new Date().toISOString(),
  };
  state.lastRun = new Date().toISOString();
}

export function markRemoved(state: DotfilesState, moduleId: string): void {
  delete state.installedModules[moduleId];
  state.lastRun = new Date().toISOString();
}

export function getInstalledModuleIds(state: DotfilesState): string[] {
  return Object.keys(state.installedModules);
}
