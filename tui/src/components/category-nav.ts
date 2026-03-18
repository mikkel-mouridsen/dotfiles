import { Box, Text } from "@opentui/core";
import { colors, categoryIcons } from "../theme";
import type { Category } from "../types";

const CATEGORY_LABELS: Record<Category, string> = {
  shell: "Shell",
  terminal: "Terminal",
  editor: "Editor",
  desktop: "Desktop",
  appearance: "Appearance",
  "dev-tools": "Dev Tools",
  system: "System",
  social: "Social",
};

export function CategoryNav(
  categories: Category[],
  activeCategory: Category,
  moduleCounts: Record<string, { total: number; selected: number }>,
  isFocused: boolean,
) {
  const items = categories.map((cat) => {
    const isActive = cat === activeCategory;
    const icon = categoryIcons[cat] ?? "";
    const label = CATEGORY_LABELS[cat];
    const counts = moduleCounts[cat];
    const countStr = counts ? `${counts.selected}/${counts.total}` : "";

    return Box(
      {
        flexDirection: "row",
        gap: 1,
        paddingX: 1,
        backgroundColor: isActive ? colors.surface0 : undefined,
      },
      Text({ content: icon, fg: isActive ? colors.mauve : colors.overlay0 }),
      Text({ content: label, fg: isActive ? colors.text : colors.subtext0, attributes: isActive ? 1 : 0 }),
      Text({ content: countStr, fg: colors.overlay0 }),
    );
  });

  return Box(
    {
      flexDirection: "column",
      width: 22,
      border: true,
      borderStyle: isFocused ? "heavy" : "rounded",
      borderColor: isFocused ? colors.mauve : colors.surface1,
      paddingY: 1,
      title: " Categories ",
      titleAlignment: "left",
    },
    ...items,
  );
}
