APP = {
  VERSION = "1.0.0", -- keep in sync with the version in manifest.json
  AUTHOR = "Clément Prod'homme",
  REPOSITORY = "github.com/clementprdhomme/xteink-passes",
}

LAYOUT = {
  PADDING = 20,
  TITLE_TOP = 40,
  CONTENT_TOP = 100,
}

COLOR = {
  WHITE = 0,
  BLACK = 15,
}

ICON = {
  SIZE = 28,
  LARGE_SIZE = 48,
  SMALL_SIZE = 24,
}

BUTTON = {
  SIZE = 72,
  RADIUS = 14,
}

INPUT = {
  LONG_PRESS_MS = 700,
}

HOME = {
  TICKETS_PER_PAGE = 4,
}

PASS = {
  TICKET_WIDTH = 440,
  TICKET_HEIGHT = 628,
  STUB_SIZE = 100,
  CODE_MARGIN = 10,
  DATA_HEIGHT = 24,
  DATA_GAP = 16,
  FORMATS = {
    {
      key = "qr",
      label = "format.qr.label",
      description = "format.qr.description",
      icon = "qr",
      shape = "square",
    },
    {
      key = "aztec",
      label = "format.aztec.label",
      description = "format.aztec.description",
      icon = "aztec",
      shape = "square",
    },
    {
      key = "code128",
      label = "format.code128.label",
      description = "format.code128.description",
      icon = "code128",
      shape = "long",
      instructions = "format.code128.instructions",
    },
    {
      key = "itf",
      label = "format.itf.label",
      description = "format.itf.description",
      icon = "itf",
      shape = "long",
      instructions = "format.itf.instructions",
    },
    {
      key = "pdf417",
      label = "format.pdf417.label",
      description = "format.pdf417.description",
      icon = "pdf417",
      shape = "long",
    },
  },
}

DIALOG = {
  TOAST_MAX_BYTES = 95,
  CONFIRM_TITLE_MAX_BYTES = 95,
  CONFIRM_MESSAGE_MAX_BYTES = 191,
  BUTTON_MAX_BYTES = 63,
}

STORAGE = {
  FILE = "passes.json",
  VERSION = 1,
}

CODE = {
  SQUARE_SIZE = math.min(
    PASS.TICKET_WIDTH,
    PASS.TICKET_HEIGHT - PASS.STUB_SIZE - PASS.DATA_HEIGHT - PASS.DATA_GAP
  ) - 2 * PASS.CODE_MARGIN,
  LONG_LENGTH = PASS.TICKET_HEIGHT - 2 * PASS.CODE_MARGIN,
  LONG_WIDTH = PASS.TICKET_WIDTH - PASS.STUB_SIZE - PASS.DATA_HEIGHT - PASS.DATA_GAP - 2 * PASS.CODE_MARGIN,
  MARGIN = 4,
  PDF417_ROW_HEIGHT = 3,
  BAR_HEIGHT = 200, -- bars of Code 128 and ITF (the guideline asks for 15% of the length)
  BARCODE_MARGIN = 10,
  -- below this width in pixels (about 0.35 mm), bars and squares get too thin for some scanners
  WARNING_MODULE_SIZE = 3,
}
