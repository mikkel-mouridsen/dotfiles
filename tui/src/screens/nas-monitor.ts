import { Box, Text } from "@opentui/core";
import { colors, symbols } from "../theme";
import { KeybindBar } from "../components/keybind-bar";
import { ScreenLayout } from "../components/screen-layout";
import type { NasStatus } from "../services/nas-status";

function StatusDot(active: boolean, label: string) {
  return Box(
    { flexDirection: "row", gap: 1 },
    Text({ content: active ? "●" : "●", fg: active ? colors.green : colors.red }),
    Text({ content: label, fg: active ? colors.green : colors.red }),
  );
}

function SectionHeader(title: string) {
  return Text({
    content: `  ${title}`,
    fg: colors.lavender,
    attributes: 1,
  });
}

function InfoRow(label: string, value: string, valueColor?: string) {
  return Box(
    { flexDirection: "row", gap: 1, paddingLeft: 4 },
    Text({ content: label, fg: colors.subtext0 }),
    Text({ content: value, fg: valueColor ?? colors.text }),
  );
}

export function NasMonitorScreen(status: NasStatus | null, actionMessage: string | null) {
  if (!status) {
    return ScreenLayout(
      "nas-monitor",
      Box(
        { flexDirection: "column", alignItems: "center", paddingTop: 4 },
        Text({ content: "Loading NAS status...", fg: colors.overlay1 }),
      ),
      KeybindBar([{ key: "Esc", label: "back" }]),
    );
  }

  const serverSection = Box(
    { flexDirection: "column", gap: 0, paddingTop: 1 },
    SectionHeader("Server"),
    Box(
      { flexDirection: "row", gap: 2, paddingLeft: 4 },
      Text({ content: status.serverName, fg: colors.text }),
      StatusDot(status.serverReachable, status.serverReachable ? "Reachable" : "Unreachable"),
    ),
  );

  const mountsSection = Box(
    { flexDirection: "column", gap: 0, paddingTop: 1 },
    SectionHeader("Mounts"),
    Box(
      { flexDirection: "row", gap: 2, paddingLeft: 4 },
      Text({ content: "\uf0a0", fg: colors.mauve }),
      Text({ content: "Documents", fg: colors.text, width: 14 }),
      StatusDot(status.docsMounted, status.docsMounted ? "Mounted" : "Unmounted"),
      Text({ content: "[d] remount", fg: colors.overlay0 }),
    ),
    Box(
      { flexDirection: "row", gap: 2, paddingLeft: 4 },
      Text({ content: "\uf0a0", fg: colors.mauve }),
      Text({ content: "Media", fg: colors.text, width: 14 }),
      StatusDot(status.mediaMounted, status.mediaMounted ? "Mounted" : "Unmounted"),
      Text({ content: "[m] remount", fg: colors.overlay0 }),
    ),
  );

  const syncSection = Box(
    { flexDirection: "column", gap: 0, paddingTop: 1 },
    SectionHeader("Sync"),
    Box(
      { flexDirection: "row", gap: 2, paddingLeft: 4 },
      Text({ content: "\uf021", fg: colors.mauve }),
      Text({ content: "Timer", fg: colors.text, width: 14 }),
      StatusDot(status.syncTimerActive, status.syncTimerActive ? "Active" : "Inactive"),
    ),
    InfoRow("Last sync:", status.lastSyncTime),
    status.syncRunning
      ? InfoRow("Status:", "Syncing...", colors.yellow)
      : Box({}),
  );

  const messageSection = actionMessage
    ? Box(
        { paddingTop: 1, paddingLeft: 4 },
        Text({
          content: actionMessage,
          fg: actionMessage.startsWith("Error") || actionMessage.startsWith("Failed")
            ? colors.red
            : colors.green,
        }),
      )
    : Box({});

  const content = Box(
    {
      flexDirection: "column",
      border: true,
      borderStyle: "rounded",
      borderColor: colors.surface1,
      paddingX: 2,
      paddingBottom: 1,
      marginX: 4,
      marginTop: 2,
    },
    serverSection,
    mountsSection,
    syncSection,
    messageSection,
  );

  return ScreenLayout(
    "nas-monitor",
    content,
    KeybindBar([
      { key: "d", label: "remount docs" },
      { key: "m", label: "remount media" },
      { key: "a", label: "remount all" },
      { key: "s", label: "sync now" },
      { key: "Esc", label: "back" },
    ]),
  );
}
