import { Box, Text } from "@opentui/core";
import { colors, symbols } from "../theme";
import type { DotfilesModule } from "../types";

export function ModuleCard(mod: DotfilesModule, isSelected: boolean, isInstalled: boolean) {
  const statusText = isInstalled
    ? `${symbols.success} Installed`
    : isSelected
      ? `${symbols.checked} Selected`
      : "Not installed";
  const statusColor = isInstalled ? colors.green : isSelected ? colors.blue : colors.overlay0;

  const children = [
    Box({ flexDirection: "row", gap: 2 },
      Text({ content: mod.name, fg: colors.text, attributes: 1 }),
      Text({ content: statusText, fg: statusColor }),
    ),
    Text({ content: mod.description, fg: colors.subtext0 }),
  ];

  const pkgCount = Object.values(mod.systemPackages)
    .flat()
    .filter((p) => typeof p === "string").length;

  children.push(
    Text({
      content: `Stow: ${mod.stowPackages.join(", ")}  |  Packages: ${pkgCount}`,
      fg: colors.overlay0,
    }),
  );

  if (mod.dependencies?.length) {
    children.push(
      Text({ content: `Depends on: ${mod.dependencies.join(", ")}`, fg: colors.overlay1 }),
    );
  }

  if (mod.onlyOn) {
    children.push(
      Text({ content: `Platform: ${mod.onlyOn.join(", ")}`, fg: colors.yellow }),
    );
  }

  return Box(
    {
      flexDirection: "column",
      paddingX: 2,
      paddingY: 1,
      border: true,
      borderStyle: "rounded",
      borderColor: colors.surface1,
      backgroundColor: colors.mantle,
      width: "100%" as any,
      title: ` ${mod.name} `,
      titleAlignment: "left",
    },
    ...children,
  );
}
