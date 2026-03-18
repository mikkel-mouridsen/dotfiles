import { Box, Text } from "@opentui/core";
import { colors, symbols } from "../theme";
import { KeybindBar } from "../components/keybind-bar";
import { ScreenLayout } from "../components/screen-layout";
import type { AppState, DotfilesModule } from "../types";

export function ConfirmScreen(
  state: AppState,
  toInstall: DotfilesModule[],
  toRemove: DotfilesModule[],
  focusIndex: number,
) {
  const sections: ReturnType<typeof Box>[] = [];

  if (toInstall.length > 0) {
    const installItems = toInstall.map((mod) => {
      const pkgCount = Object.values(mod.systemPackages)
        .flat()
        .filter((p) => typeof p === "string").length;
      return Text({ content: `  ${symbols.arrow} ${mod.name} (${pkgCount} packages)`, fg: colors.green });
    });

    sections.push(
      Box({ flexDirection: "column" },
        Text({ content: `To Install (${toInstall.length}):`, fg: colors.green, attributes: 1 }),
        ...installItems,
      ),
    );
  }

  if (toRemove.length > 0) {
    const removeItems = toRemove.map((mod) =>
      Text({ content: `  ${symbols.arrow} ${mod.name}`, fg: colors.red }),
    );

    sections.push(
      Box({ flexDirection: "column" },
        Text({ content: `To Remove (${toRemove.length}):`, fg: colors.red, attributes: 1 }),
        ...removeItems,
      ),
    );
  }

  const hooks = toInstall.flatMap((mod) =>
    (mod.postInstall ?? [])
      .filter((h) => !h.onlyOn || h.onlyOn.includes(state.distro))
      .map((h) => `  ${symbols.dot} [${mod.name}] ${h.description}`),
  );
  if (hooks.length > 0) {
    sections.push(
      Box({ flexDirection: "column" },
        Text({ content: `Post-install hooks (${hooks.length}):`, fg: colors.yellow, attributes: 1 }),
        ...hooks.map((h) => Text({ content: h, fg: colors.yellow })),
      ),
    );
  }

  const buttons = ["Confirm", "Back"].map((label, i) => {
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

  const contentChildren = sections.length > 0
    ? sections
    : [Text({ content: "No changes to apply", fg: colors.overlay0 })];

  return ScreenLayout(
    "confirm",
    Box(
      { flexDirection: "column", gap: 1, alignItems: "center" },
      Box(
        {
          flexDirection: "column",
          gap: 1,
          paddingX: 2,
          paddingY: 1,
          border: true,
          borderStyle: "double",
          borderColor: colors.surface1,
          width: 60,
          title: " Changes Summary ",
          titleAlignment: "left",
        },
        ...contentChildren,
      ),
      Box({ flexDirection: "row", gap: 2 }, ...buttons),
    ),
    KeybindBar([
      { key: "Tab", label: "switch" },
      { key: "Enter", label: "confirm" },
      { key: "Esc", label: "back" },
    ]),
  );
}
