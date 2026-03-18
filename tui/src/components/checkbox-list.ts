import { Box, Text } from "@opentui/core";
import { colors, symbols } from "../theme";

export interface CheckboxItem {
  id: string;
  label: string;
  description: string;
  checked: boolean;
  installed?: boolean;
}

export function CheckboxList(
  items: CheckboxItem[],
  focusIndex: number,
  scrollOffset: number,
  maxVisible: number,
) {
  const visible = items.slice(scrollOffset, scrollOffset + maxVisible);

  const rows = visible.map((item, i) => {
    const actualIndex = scrollOffset + i;
    const isFocused = actualIndex === focusIndex;
    const icon = item.checked ? symbols.checked : symbols.unchecked;
    const iconColor = item.checked ? colors.green : colors.surface2;

    let labelColor: string = colors.text;
    if (isFocused) labelColor = colors.mauve;
    else if (item.installed && item.checked) labelColor = colors.subtext0;

    const children = [
      Text({ content: icon, fg: iconColor }),
      Text({ content: item.label, fg: labelColor, attributes: isFocused ? 1 : 0 }),
    ];

    if (item.installed) {
      children.push(Text({ content: " [installed]", fg: colors.overlay0 }));
    }

    return Box(
      {
        flexDirection: "row",
        gap: 1,
        paddingX: 1,
        backgroundColor: isFocused ? colors.surface0 : undefined,
      },
      ...children,
    );
  });

  const hasMore = scrollOffset + maxVisible < items.length;
  const hasLess = scrollOffset > 0;

  return Box(
    { flexDirection: "column" },
    ...(hasLess ? [Text({ content: " ...", fg: colors.overlay0 })] : []),
    ...rows,
    ...(hasMore ? [Text({ content: " ...", fg: colors.overlay0 })] : []),
  );
}
