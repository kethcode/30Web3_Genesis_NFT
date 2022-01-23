import assert from "assert";
import flatten from "lodash/flatten";
import tokens from "./tokens.json";
import fonts from "./fonts.json";
import elevations from "./elevations.json";

const COLOR_MODES = ["light", "dark"];

const getToken = (theme, id, colorMode = "light") => {
  assert(
    COLOR_MODES.includes(colorMode),
    `Unknown color mode ${colorMode} passed. Please provide on of 'light' or 'dark'`,
  );
  const token = theme.tokens.find(e => e.id === id + "." + colorMode);
  assert(token, `No token with passed id/colorMode ${id}.${colorMode}`);
  return token.value;
};

const getFont = (theme, id) => {
  const font = flatten(theme.fonts.map(item => item.tokens)).find(e => e.id === id);
  assert(font, `No font with passed id ${id}`);
  return font.value;
};

const getElevation = (theme, id) => {
  const elevation = theme.elevations[id];
  assert(elevation, `No font with passed id ${id}`);
  return elevation;
};

const getFromTheme = (theme, id, colorMode) => {
  try {
    return getToken(theme, id, colorMode);
  } catch (error) {
    try {
      return getFont(theme, id);
    } catch (error) {
      try {
        return getElevation(theme, id);
      } catch (error) {
        throw new Error(`No token, font or elevation with passed id/colorMode ${id}.${colorMode}`);
      }
    }
  }
};

const theme = {
  tokens: tokens.entities,
  fonts: fonts.entities,
  elevations: elevations,
  get: (id, colorMode) => getFromTheme(theme, id, colorMode),
};

export default theme;
