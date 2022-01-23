import PropTypes from "prop-types";
import assert from "assert";
import styled from "styled-components";
import theme from "./themes/theme";
import { useThemeSwitcher } from "react-css-theme-switcher";
const fonts = theme.fonts;
const fontTokens = fonts.map(f => f.id);

const tokenToBaseComponent = token => {
  assert(fontTokens.includes(token), `Invalid token ${token} provided. Should be one of ${fontTokens}`);
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
  const font = fonts.find(f => f.id === token);
  const fontTag = font.tags[0];
  return FONT_TAG_TO_BASE_COMPONENT[fontTag];
};

const WEIGH_LABEL_TO_WEIGHT = {
  Regular: 400,
  Medium: 500,
};

const M3Typography = ({ token, children, ...props }) => {
  const { currentTheme } = useThemeSwitcher();
  const colorMode = currentTheme ?? "light";

  const Styled = tokenToBaseComponent(token)`
  color: ${props => props.theme.get("md.sys.color.on-background", props.colorMode)};
  font-family: ${props => props.theme.get(`${token}.font`)};
  line-height: ${props => props.theme.get(`${token}.line-height`)}px;
  font-weight: ${props => WEIGH_LABEL_TO_WEIGHT[props.theme.get(`${token}.weight`)]};
  font-size: ${props => props.theme.get(`${token}.size`)}px;
  letter-spacing: ${props => props.theme.get(`${token}.tracking`)};
`;

  return (
    <Styled colorMode={colorMode} {...props}>
      {children}
    </Styled>
  );
};

M3Typography.propTypes = {
  token: PropTypes.oneOf(fontTokens),
};

M3Typography.defaultProps = {
  token: "md.sys.typescale.body-medium",
};

export default M3Typography;
