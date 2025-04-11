require("cmake-tools").setup {
  cmake_command = "cmake",
  cmake_build_directory = "build",
  cmake_runner = {
    name = "quickfix",
  },
  cmake_executor = {
    name = "quickfix",
  },
}
