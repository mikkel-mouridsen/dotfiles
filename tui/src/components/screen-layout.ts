import { Box, Text, type VChild } from "@opentui/core";
import { colors, symbols } from "../theme";
import type { Screen } from "../types";

const SCREENS: Screen[] = ["welcome", "categories", "confirm", "progress", "complete"];

const SCREEN_LABELS: Record<Screen, string> = {
  welcome: "Welcome",
  categories: "Modules",
  confirm: "Confirm",
  progress: "Install",
  complete: "Done",
  "nas-monitor": "NAS Monitor",
};

function TopBar(currentScreen: Screen) {
  const brandSection = Box(
    { flexDirection: "row", gap: 1 },
    Text({ content: symbols.brand, fg: colors.mauve }),
    Text({ content: "Cobo OS", fg: colors.mauve, attributes: 1 }),
  );

  if (currentScreen === "nas-monitor") {
    return Box(
      {
        flexDirection: "row",
        justifyContent: "space-between",
        paddingX: 2,
        paddingY: 0,
        border: true,
        borderStyle: "double",
        borderColor: colors.mauve,
        width: "100%",
      },
      brandSection,
      Box(
        { flexDirection: "row", gap: 1 },
        Text({ content: "\uf0a0", fg: colors.mauve }),
        Text({ content: "Network Storage Monitor", fg: colors.mauve, attributes: 1 }),
      ),
    );
  }

  const stepDots = SCREENS.map((screen) => {
    const isCurrent = screen === currentScreen;
    return Box(
      { flexDirection: "row", gap: 1 },
      Text({
        content: isCurrent ? symbols.stepActive : symbols.stepInactive,
        fg: isCurrent ? colors.mauve : colors.surface2,
      }),
      Text({
        content: SCREEN_LABELS[screen],
        fg: isCurrent ? colors.mauve : colors.surface2,
        attributes: isCurrent ? 1 : 0,
      }),
    );
  });

  return Box(
    {
      flexDirection: "row",
      justifyContent: "space-between",
      paddingX: 2,
      paddingY: 0,
      border: true,
      borderStyle: "double",
      borderColor: colors.mauve,
      width: "100%",
    },
    brandSection,
    Box({ flexDirection: "row", gap: 2 }, ...stepDots),
  );
}

export function ScreenLayout(currentScreen: Screen, ...children: VChild[]) {
  return Box(
    { flexDirection: "column" },
    TopBar(currentScreen),
    ...children,
  );
}
