import { Box, Text } from "@opentui/core";
import { colors } from "../theme";

export function Header(title: string, subtitle?: string) {
  return Box(
    {
      flexDirection: "column",
      paddingX: 2,
      paddingY: 1,
      border: true,
      borderStyle: "rounded",
      borderColor: colors.mauve,
    },
    Text({ content: title, fg: colors.mauve, attributes: 1 }),
    ...(subtitle ? [Text({ content: subtitle, fg: colors.subtext0 })] : []),
  );
}
