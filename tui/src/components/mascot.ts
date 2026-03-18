import { Box, Text } from "@opentui/core";
import { colors } from "../theme";

const BRAILLE_ART = `$2⡆⣐⢕⢕⢕⢕⢕⢕⢕⢕⠅⢗⢕⢕⢕⢕⢕⢕⢕⠕⠕⢕⢕⢕⢕⢕⢕⢕⢕⢕
$2⢐⢕⢕⢕⢕⢕⣕⢕⢕⠕⠁⢕⢕⢕⢕⢕⢕⢕⢕⠅$1⡄$2⢕⢕⢕⢕⢕⢕⢕⢕⢕
$2⢕⢕⢕⢕⢕⠅⢗⢕⠕$1⣠⠄$2⣗⢕⢕⠕⢕⢕⢕⠕$1⢠⣿$2⠐⢕⢕⢕⠑⢕⢕⠵⢕
$2⢕⢕⢕⢕⠁⢜⠕$1⢁⣴⣿⡇$2⢓⢕⢵⢐⢕⢕⠕$1⢁⣾⢿⣧$2⠑⢕⢕⠄⢑⢕⠅⢕
$2⢕⢕⠵⢁⠔$1⢁⣤⣤⣶⣶⣶$2⡐⣕⢽⠐⢕⠕$1⣡⣾⣶⣶⣶⣤$2⡁⢓⢕⠄⢑⢅⢑
$2⠍⣧⠄$1⣶⣾⣿⣿⣿⣿⣿⣿⣷$2⣔⢕⢄$1⢡⣾⣿⣿⣿⣿⣿⣿⣿⣦$2⡑⢕⢤⠱⢐
$2⢠⢕⠅$1⣾⣿⠋⢿⣿⣿⣿⠉⣿⣿⣷⣦⣶⣽⣿⣿⠈⣿⣿⣿⣿⠏⢹⣷⣷⡅$2⢐
$2⣔⢕⢥$1⢻⣿⡀⠈⠛⠛⠁⢠⣿⣿⣿⣿⣿⣿⣿⣿⡀⠈⠛⠛⠁⠄⣼⣿⣿⡇$2⢔
$2⢕⢕⢽⢸$1⢟$3⢟⢖⢖⢤$1⣶⡟⢻⣿⡿⠻⣿⣿⡟⢀⣿$3⣦⢤⢤⢔⢞⢿$1⢿⣿⠁$2⢕
$2⢕⢕⠅$3⣐⢕⢕⢕⢕⢕$1⣿⣿⡄⠛⢀⣦⠈⠛⢁⣼⣿$3⢗⢕⢕⢕⢕⢕⢕$2⡏⣘⢕
$2⢕⢕⠅$3⢓⣕⣕⣕⣕$1⣵⣿⣿⣿⣾⣿⣿⣿⣿⣿⣿⣿⣷$3⣕⢕⢕⢕⢕⡵$2⢀⢕⢕
$2⢑⢕⠃⡈$1⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿$2⢃⢕⢕⢕
$2⣆⢕⠄⢱⣄$1⠛⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿$2⢁⢕⢕⠕⢁
$2⣿⣦⡀⣿⣿⣷⣶⣬⣍$1⣛⣛⣛⡛⠿⠿⠿⠛⠛⢛⣛$2⣉⣭⣤⣂⢜⠕⢑⣡⣴⣿`;

const COLOR_MAP: Record<string, string> = {
  "$1": colors.red,
  "$2": colors.mauve,
  "$3": colors.yellow,
};

export function Mascot() {
  const lines = BRAILLE_ART.split("\n");

  const renderedLines = lines.map((line) => {
    const segments = line.split(/(\$[123])/);
    let currentColor: string = colors.mauve;
    const textNodes: ReturnType<typeof Text>[] = [];

    for (const seg of segments) {
      if (COLOR_MAP[seg]) {
        currentColor = COLOR_MAP[seg];
      } else if (seg.length > 0) {
        textNodes.push(Text({ content: seg, fg: currentColor as typeof colors.mauve }));
      }
    }

    return Box({ flexDirection: "row" }, ...textNodes);
  });

  return Box({ flexDirection: "column" }, ...renderedLines);
}
