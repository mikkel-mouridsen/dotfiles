import { Box, Text } from "@opentui/core";
import { colors } from "../theme";
import { KeybindBar } from "../components/keybind-bar";
import { ScreenLayout } from "../components/screen-layout";
import { CategoryNav } from "../components/category-nav";
import { CheckboxList, type CheckboxItem } from "../components/checkbox-list";
import { ModuleCard } from "../components/module-card";
import type { AppState, Category } from "../types";
import { getCategories } from "../registry";

export function CategoriesScreen(
  state: AppState,
  categoryIndex: number,
  moduleIndex: number,
  scrollOffset: number,
  pane: "categories" | "modules",
) {
  const categories = getCategories().filter((cat) =>
    state.availableModules.some((m) => m.category === cat),
  ) as Category[];

  const activeCategory = categories[categoryIndex] ?? categories[0];
  const categoryModules = state.availableModules.filter((m) => m.category === activeCategory);

  const moduleCounts: Record<string, { total: number; selected: number }> = {};
  for (const cat of categories) {
    const mods = state.availableModules.filter((m) => m.category === cat);
    moduleCounts[cat] = {
      total: mods.length,
      selected: mods.filter((m) => state.selectedModules.has(m.id)).length,
    };
  }

  const checkboxItems: CheckboxItem[] = categoryModules.map((mod) => ({
    id: mod.id,
    label: mod.name,
    description: mod.description,
    checked: state.selectedModules.has(mod.id),
    installed: state.installedModules.has(mod.id),
  }));

  const focusedModule = categoryModules[moduleIndex];

  const modeLabel = state.mode === "fresh" ? "Fresh Install" : "Manage Existing";
  const selectedCount = state.selectedModules.size;

  const isModulesPaneFocused = pane === "modules";

  const rightPaneChildren = [
    CheckboxList(checkboxItems, moduleIndex, scrollOffset, 15),
  ];

  if (focusedModule) {
    rightPaneChildren.push(
      ModuleCard(
        focusedModule,
        state.selectedModules.has(focusedModule.id),
        state.installedModules.has(focusedModule.id),
      ),
    );
  }

  return ScreenLayout(
    "categories",
    Box(
      { flexDirection: "column", paddingX: 1, paddingY: 0 },
      Box({ flexDirection: "row", gap: 1, paddingX: 1 },
        Text({ content: modeLabel, fg: colors.mauve, attributes: 1 }),
        Text({ content: `| ${selectedCount} selected`, fg: colors.subtext0 }),
      ),
    ),
    Box(
      { flexDirection: "row", gap: 1, flexGrow: 1, paddingX: 1 },
      CategoryNav(categories, activeCategory, moduleCounts, !isModulesPaneFocused),
      Box(
        {
          flexDirection: "column",
          flexGrow: 1,
          gap: 1,
          border: true,
          borderStyle: isModulesPaneFocused ? "heavy" : "rounded",
          borderColor: isModulesPaneFocused ? colors.mauve : colors.surface1,
          title: " Modules ",
          titleAlignment: "left",
        },
        ...rightPaneChildren,
      ),
    ),
    KeybindBar([
      { key: "Tab", label: "switch pane" },
      { key: "j/k", label: "navigate" },
      { key: "Space", label: "toggle" },
      { key: "Enter", label: "confirm" },
      { key: "Esc", label: "back" },
    ]),
  );
}
