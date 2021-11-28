# Screensaver

## 1.2
- Added two smaller size options ((#18 by lordlycastle)[https://www.youtube.com/watch?v=A3pq9xL3kIs])

## 1.1
- Config sheet detects if colors match existing preset and selects it in picker
- Added option for selecting a random color preset on launch
- Improvements to "extra" cell death animation
- Many optimizations to reduce memory, CPU, and energy usage
  - Neighbor generation is much faster due to usage of ToroidalMatrix
  - Reduced preferred FPS to 30 fps
  - Uses shared SKTexture to reduce per-frame draw count to 1

## 1.0
- Initial release