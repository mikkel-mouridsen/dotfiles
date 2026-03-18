import { Box, Text, type VChild } from "@opentui/core";
import { colors, symbols } from "../theme";
import { ProgressLog } from "../components/progress-log";
import { ScreenLayout } from "../components/screen-layout";

export function ProgressScreen(
  log: string[],
  currentModule: string | null,
  completed: number,
  total: number,
  done: boolean,
) {
  const progress = total > 0 ? Math.round((completed / total) * 100) : 0;
  const barWidth = 40;
  const filledWidth = Math.round((progress / 100) * barWidth);
  const bar = "\u2588".repeat(filledWidth) + "\u2591".repeat(barWidth - filledWidth);

  const spinnerFrames = symbols.spinner;
  const spinnerIdx = Math.floor(Date.now() / 100) % spinnerFrames.length;
  const spinner = done ? symbols.success : spinnerFrames[spinnerIdx];

  const statusText = done
    ? "Complete!"
    : currentModule
      ? `Installing ${currentModule}...`
      : "Preparing...";

  const children: VChild[] = [
    Box(
      {
        flexDirection: "column",
        paddingX: 2,
        width: 60,
        border: true,
        borderStyle: "rounded",
        borderColor: colors.surface1,
        title: " Progress ",
        titleAlignment: "left",
      },
      Box({ flexDirection: "row", gap: 1 },
        Text({ content: spinner, fg: done ? colors.green : colors.mauve }),
        Text({ content: statusText, fg: colors.text }),
      ),
      Box({ flexDirection: "row", gap: 1 },
        Text({ content: bar, fg: colors.mauve }),
        Text({ content: `${progress}%`, fg: colors.subtext0 }),
      ),
      Text({ content: `${completed}/${total} modules`, fg: colors.subtext0 }),
    ),
    ProgressLog(log, 20),
  ];

  if (done) {
    children.push(Text({ content: "Press Enter to continue", fg: colors.subtext0 }));
  }

  return ScreenLayout(
    "progress",
    Box({ flexDirection: "column", gap: 1, alignItems: "center", flexGrow: 1 }, ...children),
  );
}
