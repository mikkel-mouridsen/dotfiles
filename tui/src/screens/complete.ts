import { Box, Text } from "@opentui/core";
import { colors, symbols } from "../theme";
import { KeybindBar } from "../components/keybind-bar";
import { ScreenLayout } from "../components/screen-layout";
import type { ExecutionResults } from "../types";

export function CompleteScreen(results: ExecutionResults, focusIndex: number) {
  const sections: ReturnType<typeof Box>[] = [];

  if (results.installed.length > 0) {
    sections.push(
      Box({ flexDirection: "column" },
        Text({ content: `${symbols.success} Installed (${results.installed.length}):`, fg: colors.green, attributes: 1 }),
        ...results.installed.map((id) =>
          Text({ content: `  ${symbols.dot} ${id}`, fg: colors.green }),
        ),
      ),
    );
  }

  if (results.removed.length > 0) {
    sections.push(
      Box({ flexDirection: "column" },
        Text({ content: `${symbols.success} Removed (${results.removed.length}):`, fg: colors.blue, attributes: 1 }),
        ...results.removed.map((id) =>
          Text({ content: `  ${symbols.dot} ${id}`, fg: colors.blue }),
        ),
      ),
    );
  }

  if (results.failed.length > 0) {
    sections.push(
      Box({ flexDirection: "column" },
        Text({ content: `${symbols.error} Failed (${results.failed.length}):`, fg: colors.red, attributes: 1 }),
        ...results.failed.map((f) =>
          Text({ content: `  ${symbols.dot} ${f.id}: ${f.error}`, fg: colors.red }),
        ),
      ),
    );
  }

  if (results.manualSteps.length > 0) {
    sections.push(
      Box({ flexDirection: "column" },
        Text({ content: `${symbols.warning} Manual Steps:`, fg: colors.yellow, attributes: 1 }),
        ...results.manualSteps.map((step) =>
          Text({ content: `  ${symbols.dot} ${step}`, fg: colors.yellow }),
        ),
      ),
    );
  }

  const hasFailures = results.failed.length > 0;
  const buttonLabels = hasFailures ? ["Done", "Retry Failed"] : ["Done"];
  const buttons = buttonLabels.map((label, i) => {
    const isFocused = i === focusIndex;
    return Box(
      {
        paddingX: 3,
        border: true,
        borderStyle: "rounded",
        borderColor: isFocused ? colors.mauve : colors.surface1,
        backgroundColor: isFocused ? colors.surface0 : undefined,
      },
      Text({ content: label, fg: isFocused ? colors.mauve : colors.text, attributes: isFocused ? 1 : 0 }),
    );
  });

  const total = results.installed.length + results.removed.length;
  const subtitle = results.failed.length > 0
    ? `${total} succeeded, ${results.failed.length} failed`
    : `${total} changes applied successfully`;

  return ScreenLayout(
    "complete",
    Box(
      { flexDirection: "column", gap: 1, alignItems: "center" },
      Text({ content: subtitle, fg: colors.subtext0 }),
      Box(
        {
          flexDirection: "column",
          gap: 1,
          paddingX: 2,
          paddingY: 1,
          border: true,
          borderStyle: "rounded",
          borderColor: colors.surface1,
          width: 60,
          title: " Results ",
          titleAlignment: "left",
        },
        ...sections,
      ),
      Box({ flexDirection: "row", gap: 2 }, ...buttons),
    ),
    KeybindBar([
      ...(hasFailures ? [{ key: "Tab", label: "switch" }] : []),
      { key: "Enter", label: "select" },
      { key: "q", label: "quit" },
    ]),
  );
}
