import { Box, Text } from "@opentui/core";
import figlet from "figlet";
import { colors } from "../theme";
import { KeybindBar } from "../components/keybind-bar";
import { ScreenLayout } from "../components/screen-layout";
import { Mascot } from "../components/mascot";
import type { AppState } from "../types";
import { getDistroName } from "../detect";

const ASCII_TITLE = figlet.textSync("Cobo OS", { font: "ANSI Shadow" });

function AsciiTitle() {
  const lines = ASCII_TITLE.split("\n");
  const gradientColors = [colors.mauve, colors.mauve, colors.lavender, colors.blue, colors.blue, colors.sapphire];

  return Box(
    { flexDirection: "column" },
    ...lines.map((line, i) =>
      Text({ content: line, fg: gradientColors[i % gradientColors.length] }),
    ),
  );
}

export function WelcomeScreen(state: AppState, focusIndex: number) {
  const distroName = getDistroName(state.distro);
  const installedCount = state.installedModules.size;
  const totalCount = state.availableModules.length;

  const options = [
    {
      label: "Fresh Install",
      description: "Select modules to install on a new system",
      icon: "\u2b07",
    },
    {
      label: "Manage Existing",
      description: "Add or remove modules on your current setup",
      icon: "\u2699",
    },
  ];

  const optionElements = options.map((opt, i) => {
    const isFocused = i === focusIndex;
    return Box(
      {
        flexDirection: "row",
        gap: 2,
        paddingX: 2,
        paddingY: 1,
        border: true,
        borderStyle: isFocused ? "double" : "rounded",
        borderColor: isFocused ? colors.mauve : colors.surface1,
        backgroundColor: isFocused ? colors.surface0 : undefined,
        width: 50,
      },
      Text({ content: opt.icon, fg: isFocused ? colors.mauve : colors.overlay0 }),
      Box({ flexDirection: "column" },
        Text({ content: opt.label, fg: isFocused ? colors.mauve : colors.text, attributes: 1 }),
        Text({ content: opt.description, fg: colors.subtext0 }),
      ),
    );
  });

  const hero = Box(
    { flexDirection: "row", gap: 3, justifyContent: "center", alignItems: "center" },
    Mascot(),
    Box({ flexDirection: "column", gap: 1 },
      AsciiTitle(),
      Text({
        content: `  ${distroName} | ${installedCount}/${totalCount} modules installed`,
        fg: colors.subtext0,
      }),
    ),
  );

  return ScreenLayout(
    "welcome",
    Box(
      { flexDirection: "column", gap: 1, alignItems: "center" },
      hero,
      Text({ content: "" }),
      ...optionElements,
    ),
    KeybindBar([
      { key: "j/k", label: "navigate" },
      { key: "Enter", label: "select" },
      { key: "q", label: "quit" },
    ]),
  );
}
