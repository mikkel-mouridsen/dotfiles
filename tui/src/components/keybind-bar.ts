import { Box, Text } from "@opentui/core";
import { colors } from "../theme";

export interface KeyBind {
  key: string;
  label: string;
}

export function KeybindBar(binds: KeyBind[]) {
  const items = binds.map((b) =>
    Box({ flexDirection: "row", gap: 1 },
      Box(
        {
          paddingX: 1,
          border: true,
          borderStyle: "rounded",
          borderColor: colors.surface2,
          backgroundColor: colors.surface0,
        },
        Text({ content: b.key, fg: colors.mauve, attributes: 1 }),
      ),
      Text({ content: b.label, fg: colors.subtext0 }),
    ),
  );

  return Box(
    {
      flexDirection: "row",
      gap: 3,
      paddingX: 2,
      paddingY: 0,
      border: true,
      borderStyle: "single",
      borderColor: colors.surface1,
      backgroundColor: colors.mantle,
    },
    ...items,
  );
}
