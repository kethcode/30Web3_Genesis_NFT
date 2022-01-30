import PropTypes from "prop-types";
import { useThemeSwitcher } from "react-css-theme-switcher";
import styled from "styled-components";

const M3ButtonRoot = styled.button`
  background: none;
  display: flex;
  flex-direction: row;
  justify-content: center;
  align-items: center;
  gap: 8px;
  font-weight: 400;
  padding: ${props =>
    props.icon && !props.onlyIcon ? "10px 24px 10px 16px" : props.icon && props.onlyIcon ? "10px" : "10px 24px"};
  border: none;
  border-radius: 100px;
  font-family: ${props => props.theme.get("md.sys.typescale.label-large.font")};
  line-height: ${props => props.theme.get("md.sys.typescale.label-large.line-height")}px;
  font-size: ${props => props.theme.get("md.sys.typescale.label-large.size")}px;
  letter-spacing: ${props => props.theme.get("md.sys.typescale.label-large.tracking")}px;
  box-shadow: none;
  transition: all 0.25s ease;
  &:hover {
    cursor: pointer;
  }
`;

const M3ButtonBase = ({ icon, children, ...props }) => (
  <M3ButtonRoot icon={icon} {...props}>
    {icon}
    {children}
  </M3ButtonRoot>
);

const M3ButtonFilledEnabled = styled(M3ButtonBase)`
  background: ${props => props.theme.get("md.sys.color.primary", props.colorMode)};
  color: ${props => props.theme.get("md.sys.color.on-primary", props.colorMode)};
  &:hover {
    filter: ${props => (props.colorMode === "light" ? "brightness(1.1)" : "brightness(0.9)")};
    box-shadow: ${props => props.theme.get("md.sys.elevation.level1")};
  }
  &:focus {
    filter: ${props => (props.colorMode === "light" ? "brightness(1.2)" : "brightness(0.8)")};
    box-shadow: none;
  }
  &:active {
    filter: ${props => (props.colorMode === "light" ? "brightness(1.2)" : "brightness(0.8)")};
    box-shadow: none;
  }
`;
const M3ButtonFilledDisabled = styled(M3ButtonBase)`
  background: ${props => props.theme.get("md.sys.color.on-surface", props.colorMode)}12;
  color: ${props => props.theme.get("md.sys.color.on-surface", props.colorMode)}38;
  &:hover {
    cursor: initial;
  }
`;
const M3ButtonFilled = ({ disabled, ...props }) =>
  disabled ? <M3ButtonFilledDisabled {...props} /> : <M3ButtonFilledEnabled {...props} />;

const M3ButtonOutlinedEnabled = styled(M3ButtonBase)`
  background: ${props => props.theme.get("md.sys.color.surface", props.colorMode)};
  outline: 1px solid ${props => props.theme.get("md.sys.color.outline", props.colorMode)};
  outline-offset: -2px;
  color: ${props => props.theme.get("md.sys.color.primary", props.colorMode)};
  &:hover {
    background: ${props => props.theme.get("md.sys.color.primary", props.colorMode)}08;
  }
  &:focus {
    background: ${props => props.theme.get("md.sys.color.primary", props.colorMode)}12;
    outline: 1px solid ${props => props.theme.get("md.sys.color.primary", props.colorMode)};
  }
  &:active {
    background: ${props => props.theme.get("md.sys.color.primary", props.colorMode)}12;
  }
`;
const M3ButtonOutlinedDisabled = styled(M3ButtonBase)`
  outline: 1px solid ${props => props.theme.get("md.sys.color.on-surface", props.colorMode)}12;
  outline-offset: -2px;
  color: ${props => props.theme.get("md.sys.color.on-surface", props.colorMode)}38;
  &:hover {
    cursor: initial;
  }
`;
const M3ButtonOutline = ({ disabled, ...props }) =>
  disabled ? <M3ButtonOutlinedDisabled {...props} /> : <M3ButtonOutlinedEnabled {...props} />;

const M3ButtonTextEnabled = styled(M3ButtonBase)`
  color: ${props => props.theme.get("md.sys.color.primary", props.colorMode)};
  &:hover {
    background: ${props => props.theme.get("md.sys.color.primary", props.colorMode)}08;
  }
  //   &:focus {
  //     background: ${props => props.theme.get("md.sys.color.primary", props.colorMode)}12;
  //   }
  //   &:active {
  //     background: ${props => props.theme.get("md.sys.color.primary", props.colorMode)}12;
  //   }
  //   padding: ${props => (props.icon ? "10px 16px 10px 12px" : "10px 12px")};
  gap: 8px;
`;
const M3ButtonTextDisabled = styled(M3ButtonBase)`
  color: ${props => props.theme.get("md.sys.color.on-surface", props.colorMode)}38;
  &:hover {
    cursor: initial;
  }
`;
const M3ButtonText = ({ disabled, ...props }) =>
  disabled ? <M3ButtonTextDisabled {...props} /> : <M3ButtonTextEnabled {...props} />;

const M3ButtonElevatedEnabled = styled(M3ButtonBase)`
  background: ${props => props.theme.get("md.sys.color.surface", props.colorMode)};
  box-shadow: ${props => props.theme.get("md.sys.elevation.level1")};
  color: ${props => props.theme.get("md.sys.color.primary", props.colorMode)};
  &:hover {
    background: ${props => props.theme.get("md.sys.color.primary", props.colorMode)}08;
  }
  &:focus {
    background: ${props => props.theme.get("md.sys.color.primary", props.colorMode)}12;
  }
  &:active {
    background: ${props => props.theme.get("md.sys.color.primary", props.colorMode)}12;
  }
`;
const M3ButtonElevatedDisabled = styled(M3ButtonBase)`
  background: ${props => props.theme.get("md.sys.color.on-surface", props.colorMode)}12;
  color: ${props => props.theme.get("md.sys.color.on-surface", props.colorMode)}38;
`;
const M3ButtonElevated = ({ disabled, ...props }) =>
  disabled ? <M3ButtonElevatedDisabled {...props} /> : <M3ButtonElevatedEnabled {...props} />;

const M3ButtonTonalEnabled = styled(M3ButtonBase)`
  background: ${props => props.theme.get("md.sys.color.secondary-container", props.colorMode)};
  color: ${props => props.theme.get("md.sys.color.on-secondary-container", props.colorMode)};
  &:hover {
    filter: ${props => (props.colorMode === "light" ? "brightness(0.9)" : "brightness(1.1)")};
    box-shadow: ${props => props.theme.get("md.sys.elevation.level1")};
  }
  &:focus {
    filter: ${props => (props.colorMode === "light" ? "brightness(0.8)" : "brightness(1.2)")};
    box-shadow: none;
  }
  &:active {
    filter: ${props => (props.colorMode === "light" ? "brightness(0.8)" : "brightness(1.2)")};
    box-shadow: none;
  }
`;
const M3ButtonTonalDisabled = styled(M3ButtonBase)`
  background: ${props => props.theme.get("md.sys.color.on-surface", props.colorMode)}12;
  color: ${props => props.theme.get("md.sys.color.on-surface", props.colorMode)}38;
`;
const M3ButtonTonal = ({ disabled, ...props }) =>
  disabled ? <M3ButtonTonalDisabled {...props} /> : <M3ButtonTonalEnabled {...props} />;

const M3Button = ({ variant, ...props }) => {
  const { currentTheme } = useThemeSwitcher();
  const colorMode = currentTheme ?? "light";

  switch (variant) {
    case "filled":
      return <M3ButtonFilled colorMode={colorMode} {...props} />;
    case "outline":
      return <M3ButtonOutline colorMode={colorMode} {...props} />;
    case "text":
      return <M3ButtonText colorMode={colorMode} {...props} />;
    case "elevated":
      return <M3ButtonElevated colorMode={colorMode} {...props} />;
    case "tonal":
      return <M3ButtonTonal colorMode={colorMode} {...props} />;
    default:
      return <M3ButtonBase colorMode={colorMode} {...props} />;
  }
};

M3Button.propTypes = {
  variant: PropTypes.oneOf(["filled", "outline", "elevated", "text", "tonal"]),
  disabled: PropTypes.bool,
  onlyIcon: PropTypes.bool,
};

M3Button.defaultProps = {
  variant: "filled",
  disabled: false,
  onlyIcon: false,
};

export default M3Button;
