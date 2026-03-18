// Catppuccin Mocha color palette
export const colors = {
  rosewater: "#f5e0dc",
  flamingo: "#f2cdcd",
  pink: "#f5c2e7",
  mauve: "#cba6f7",
  red: "#f38ba8",
  maroon: "#eba0ac",
  peach: "#fab387",
  yellow: "#f9e2af",
  green: "#a6e3a1",
  teal: "#94e2d5",
  sky: "#89dceb",
  sapphire: "#74c7ec",
  blue: "#89b4fa",
  lavender: "#b4befe",
  text: "#cdd6f4",
  subtext1: "#bac2de",
  subtext0: "#a6adc8",
  overlay2: "#9399b2",
  overlay1: "#7f849c",
  overlay0: "#6c7086",
  surface2: "#585b70",
  surface1: "#45475a",
  surface0: "#313244",
  base: "#1e1e2e",
  mantle: "#181825",
  crust: "#11111b",
} as const;

export const categoryIcons: Record<string, string> = {
  shell: "\uf489",       //
  terminal: "\uf120",    //
  editor: "\uf044",      //
  desktop: "\uf108",     //
  appearance: "\uf53f",  //
  "dev-tools": "\uf121", //
  system: "\uf085",      //
  storage: "\uf0a0",     //
  social: "\uf086",      //
};

export const symbols = {
  checked: "\uf046",     //
  unchecked: "\uf096",   //
  arrow: "\uf061",       //
  success: "\uf058",     //
  error: "\uf057",       //
  warning: "\uf071",     //
  spinner: ["\u280b", "\u2819", "\u2839", "\u2838", "\u283c", "\u2834", "\u2826", "\u2827", "\u2807", "\u280f"],
  dot: "\u2022",
  line: "\u2500",
  corner: "\u2514",
  tee: "\u251c",
  pipe: "\u2502",
  stepActive: "●",
  stepInactive: "○",
  brand: "\uf303",       //  (Arch Linux icon)
};
