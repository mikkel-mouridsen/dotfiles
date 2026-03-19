import { readFileSync, existsSync } from "fs";

export interface NasStatus {
  serverName: string;
  serverReachable: boolean;
  docsMounted: boolean;
  mediaMounted: boolean;
  syncTimerActive: boolean;
  lastSyncTime: string;
  syncRunning: boolean;
}

function readServerName(): string {
  const configPath = `${process.env.HOME}/.config/network-storage/config.env`;
  if (!existsSync(configPath)) return "gondor";
  try {
    const content = readFileSync(configPath, "utf-8");
    const match = content.match(/^SMB_SERVER=(.+)$/m);
    return match?.[1]?.trim() || "gondor";
  } catch {
    return "gondor";
  }
}

function runCmd(cmd: string[]): { exitCode: number; stdout: string } {
  const proc = Bun.spawnSync(cmd, { stdout: "pipe", stderr: "pipe" });
  return {
    exitCode: proc.exitCode ?? 1,
    stdout: new TextDecoder().decode(proc.stdout).trim(),
  };
}

export function getNasStatus(): NasStatus {
  const serverName = readServerName();

  const docs = runCmd(["systemctl", "is-active", "mnt-network\\x2dstorage-documents.mount"]);
  const media = runCmd(["systemctl", "is-active", "mnt-network\\x2dstorage-media.mount"]);
  const timer = runCmd(["systemctl", "--user", "is-active", "network-storage-sync.timer"]);
  const syncSvc = runCmd(["systemctl", "--user", "is-active", "network-storage-sync.service"]);
  const lastSync = runCmd(["systemctl", "--user", "show", "network-storage-sync.timer", "-p", "LastTriggerUSec", "--value"]);
  const ping = runCmd(["ping", "-c1", "-W2", serverName]);

  let lastSyncTime = "never";
  if (lastSync.stdout && lastSync.stdout !== "n/a" && lastSync.stdout !== "0") {
    try {
      const d = new Date(lastSync.stdout.replace(" UTC", "Z").replace(" ", "T"));
      if (!isNaN(d.getTime())) {
        lastSyncTime = d.toLocaleString([], {
          month: "short", day: "numeric",
          hour: "2-digit", minute: "2-digit",
        });
      } else {
        lastSyncTime = lastSync.stdout;
      }
    } catch {
      lastSyncTime = lastSync.stdout;
    }
  }

  return {
    serverName,
    serverReachable: ping.exitCode === 0,
    docsMounted: docs.stdout === "active",
    mediaMounted: media.stdout === "active",
    syncTimerActive: timer.stdout === "active",
    lastSyncTime,
    syncRunning: syncSvc.stdout === "active",
  };
}

export function remountShare(share: "documents" | "media" | "all"): { success: boolean; error?: string } {
  const units = [];
  if (share === "documents" || share === "all") units.push("mnt-network\\x2dstorage-documents.mount");
  if (share === "media" || share === "all") units.push("mnt-network\\x2dstorage-media.mount");

  for (const unit of units) {
    const result = Bun.spawnSync(["sudo", "systemctl", "restart", unit], {
      stdout: "pipe",
      stderr: "pipe",
    });
    if (result.exitCode !== 0) {
      const err = new TextDecoder().decode(result.stderr).trim();
      return { success: false, error: `Failed to restart ${unit}: ${err}` };
    }
  }
  return { success: true };
}

export function triggerSync(): { success: boolean; error?: string } {
  const result = Bun.spawnSync(
    ["systemctl", "--user", "start", "network-storage-sync.service"],
    { stdout: "pipe", stderr: "pipe" },
  );
  if (result.exitCode !== 0) {
    const err = new TextDecoder().decode(result.stderr).trim();
    return { success: false, error: `Sync failed: ${err}` };
  }
  return { success: true };
}
