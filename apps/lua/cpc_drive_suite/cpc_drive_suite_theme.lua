-- CPC Drive Suite — UI theme constants
local M = {}

M.THEME_NAMES = { 'Corsa Red', 'Electric Blue', 'Apex Green', 'Sunset Amber', 'Royal Purple' }
M.THEME_ACCENTS = {
  rgbm(0.95, 0.06, 0.085, 1),
  rgbm(0.12, 0.58, 1.00, 1),
  rgbm(0.12, 0.88, 0.52, 1),
  rgbm(1.00, 0.52, 0.08, 1),
  rgbm(0.54, 0.24, 0.92, 1)
}

M.COLOR_TEXT = rgbm(0.96, 0.97, 0.98, 1)
M.COLOR_MUTED = rgbm(0.52, 0.56, 0.62, 1)
M.COLOR_ACTIVE = rgbm(0.25, 0.93, 0.55, 1)
M.COLOR_ACTION = rgbm(1.00, 0.69, 0.20, 1)
M.COLOR_WARNING = rgbm(1.00, 0.34, 0.25, 1)
M.COLOR_PANEL = rgbm(0.024, 0.028, 0.038, 0.95)
M.COLOR_DAMASCUS_DARK = rgbm(0.008, 0.009, 0.012, 0.99)
M.COLOR_DAMASCUS_RED = rgbm(0.28, 0.012, 0.018, 0.18)
M.COLOR_SIDEBAR_PURPLE = rgbm(0.54, 0.24, 0.92, 1)
M.COLOR_SIDEBAR_PURPLE_DARK = rgbm(0.16, 0.07, 0.28, 0.92)
M.PAGE_COLORS = {
  rgbm(0.95, 0.06, 0.085, 1),
  rgbm(0.22, 0.62, 1.00, 1),
  rgbm(0.95, 0.36, 0.12, 1),
  rgbm(0.78, 0.24, 0.95, 1),
  rgbm(0.10, 0.82, 0.72, 1),
  rgbm(1.00, 0.70, 0.18, 1),
  rgbm(0.38, 0.80, 0.36, 1),
  rgbm(0.68, 0.36, 1.00, 1)
}

return M
