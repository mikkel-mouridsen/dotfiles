import { Box, Text } from "@opentui/core";
import { colors } from "../theme";

export function ProgressLog(lines: string[], maxVisible: number) {
  const visible = lines.slice(-maxVisible);

  const rendered = visible.map((line) => {
    let lineColor: string = colors.text;
    if (line.startsWith("ERROR") || line.startsWith("FAIL")) lineColor = colors.red;
    else if (line.startsWith("---")) lineColor = colors.mauve;
    else if (line.includes("successfully") || line.includes("Installed")) lineColor = colors.green;
    else if (line.startsWith("Installing") || line.startsWith("Stowing") || line.startsWith("Running")) lineColor = colors.blue;
    else if (line.startsWith("Skipping")) lineColor = colors.yellow;

    return Text({ content: line, fg: lineColor });
  });

  return Box(
    {
      flexDirection: "column",
      paddingX: 1,
      paddingY: 1,
      border: true,
      borderStyle: "rounded",
      borderColor: colors.surface1,
      backgroundColor: colors.crust,
      height: maxVisible + 2,
      title: " Log ",
      titleAlignment: "left",
    },
    ...rendered,
  );
}
