import PropTypes from "prop-types";
import assert from "assert";
import styled from "styled-components";
import theme from "./themes/theme";
import { useThemeSwitcher } from "react-css-theme-switcher";
const fontTokens = theme.fonts;
const fontTokenIds = fontTokens.map(f => f.id);
const colorTokens = theme.colors;
const colorTokenIds = colorTokens.map(c => c.id);

const tokenToBaseComponent = fontTokenId => {
  assert(fontTokenIds.includes(fontTokenId), `Invalid token ${fontTokenId} provided. Should be one of ${fontTokenIds}`);
  const FONT_TAG_TO_BASE_COMPONENT = {
    "display-large": styled.h1,
    "display-medium": styled.h1,
    "display-small": styled.h1,
    "headline-large": styled.h2,
    "headline-medium": styled.h2,
    "headline-small": styled.h2,
    "title-large": styled.h3,
    "title-medium": styled.h3,
    "title-small": styled.h3,
    "body-large": styled.span,
    "body-medium": styled.span,
    "body-small": styled.span,
    "label-large": styled.span,
    "label-medium": styled.span,
    "label-small": styled.span,
  };
  const font = fontTokens.find(f => f.id === fontTokenId);
  const fontTag = font.tags[0];
  return FONT_TAG_TO_BASE_COMPONENT[fontTag];
};

const WEIGH_LABEL_TO_WEIGHT = {
  Regular: 400,
  Medium: 500,
};

const M3Typography = ({ fontTokenId, colorTokenId, children, ...props }) => {
  const { currentTheme } = useThemeSwitcher();
  const colorMode = currentTheme ?? "light";

  const Styled = tokenToBaseComponent(fontTokenId)`
  color: ${props => props.theme.get(colorTokenId, props.colorMode)};
  font-family: ${props => props.theme.get(`${fontTokenId}.font`)};
  line-height: ${props => props.theme.get(`${fontTokenId}.line-height`)}px;
  font-weight: ${props => WEIGH_LABEL_TO_WEIGHT[props.theme.get(`${fontTokenId}.weight`)]};
  font-size: ${props => props.theme.get(`${fontTokenId}.size`)}px;
  letter-spacing: ${props => props.theme.get(`${fontTokenId}.tracking`)};
`;

  return (
    <Styled colorMode={colorMode} {...props}>
      {children}
    </Styled>
  );
};

M3Typography.propTypes = {
  fontTokenId: PropTypes.oneOf(fontTokenIds),
  colorTokenId: PropTypes.oneOf(colorTokenIds),
};

M3Typography.defaultProps = {
  fontTokenId: "md.sys.typescale.body-medium",
  colorTokenId: "md.sys.color.on-background",
};

export default M3Typography;
