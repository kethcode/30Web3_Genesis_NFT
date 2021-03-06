import { motion } from "framer-motion";
import { useThemeSwitcher } from "react-css-theme-switcher";
import { Link, useLocation } from "react-router-dom";
import styled from "styled-components";
import useHasNft from "../hooks/useHasNft";
import useIsAdmin from "../hooks/useIsAdmin";
import M3Typography from "../M3Typography";

const ITEMS = [
  {
    label: "Your badge",
    icon: "card_membership",
    to: "/badge",
    restrictedToAdmin: false,
  },
  {
    label: "Hall of fame",
    icon: "emoji_events",
    to: "/hall",
    restrictedToAdmin: false,
  },
  {
    label: "Mint",
    icon: "auto_awesome",
    to: "/mint",
    restrictedToAdmin: true,
  },
];

const NavItemStyled = styled.div`
  padding-top: 12px;
  padding-bottom: 16px;
  width: 8.5rem;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  gap: 4px;
`;

const ActiveStateIndicator = styled.div`
  width: 64px;
  height: 32px;
  border-radius: 16px;
  background: ${props =>
    props.active ? props.theme.get("md.sys.color.secondary-container", props.colorMode) : "#ffffff00"};
  display: flex;
  justify-content: center;
  align-items: center;
`;

const IconStyled = styled.span`
  position: absolute;
  transform: translate(19px, 4px);
  color: ${props =>
    props.active
      ? props.theme.get("md.sys.color.on-secondary-container", props.colorMode)
      : props.theme.get("md.sys.color.on-surface-variant", props.colorMode)};
`;

const variants = {
  active: {
    transform: "scaleX(1)",
    opacity: 1,
  },
  inactive: {
    transform: "scaleX(0.4)",
    opacity: 0,
  },
};
const NavItemIcon = ({ icon, active, colorMode }) => (
  <div
    style={{
      width: "64px",
      height: "32px",
    }}
  >
    <motion.div
      style={{
        width: "64px",
        height: "32px",
        position: "absolute",
      }}
      animate={active ? "active" : "inactive"}
      variants={variants}
      transition={{ ease: [0, 0.6, 0.15, 0.98], duration: 0.75 }}
    >
      <ActiveStateIndicator active={active} colorMode={colorMode} style={{ position: "absolute" }} />
    </motion.div>
    <IconStyled className={active ? "material-icons" : "material-icons-outlined"} active={active} colorMode={colorMode}>
      {icon}
    </IconStyled>
  </div>
);

const StateLayer = styled.div`
  transition: all 0.25s ease;
  border-radius: ${props => (props.isFirst ? "100px 0px 0px 100px" : props.isLast ? "0px 100px 100px 0px" : "0")};
  &:hover {
    background: ${props =>
      props.active
        ? props.theme.get("md.sys.color.on-surface", props.colorMode)
        : props.theme.get("md.sys.color.on-surface-variant", props.colorMode)}08;
  }
  &:active {
    background: ${props =>
      props.active
        ? props.theme.get("md.sys.color.on-surface", props.colorMode)
        : props.theme.get("md.sys.color.on-surface-variant", props.colorMode)}12;
  }
`;

const NotifPoint = styled.div`
  position: absolute;
  transform: translate(8px, -19px);
  height: 6px;
  width: 6px;
  border-radius: 100%;
  background: ${props => props.theme.get("md.sys.color.error", props.colorMode)};
  outline: 1px solid ${props => props.theme.get("md.sys.color.secondary-container", props.colorMode)};
`;

const NavItem = ({ label, icon, to, colorMode, isFirst, isLast, hasNotif }) => {
  const location = useLocation();
  const active = location.pathname === to;
  return (
    <Link to={to}>
      <StateLayer active={active} colorMode={colorMode} isFirst={isFirst} isLast={isLast}>
        <NavItemStyled active={active} colorMode={colorMode}>
          <NavItemIcon icon={icon} active={active} colorMode={colorMode} />
          {hasNotif && <NotifPoint colorMode={colorMode} />}
          <M3Typography
            fontTokenId="md.sys.typescale.label-medium"
            colorTokenId={active ? "md.sys.color.on-secondary-container" : "md.sys.color.on-surface"}
          >
            {label}
          </M3Typography>
        </NavItemStyled>
      </StateLayer>
    </Link>
  );
};

const Container = styled.span`
  background: ${props => props.theme.get("md.sys.color.surface-variant", props.colorMode)}60;
  border-radius: 100px;
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 0.5rem;
`;

const Nav = ({ address, readContracts }) => {
  const { currentTheme } = useThemeSwitcher();
  const colorMode = currentTheme ?? "light";
  const hasNft = useHasNft(address, readContracts);
  const isAdmin = useIsAdmin(address, readContracts);
  const items = ITEMS.filter(item => isAdmin || !item.restrictedToAdmin);

  return (
    <Container colorMode={colorMode}>
      {items.map((item, index) => (
        <NavItem
          key={index}
          label={item.label}
          icon={item.icon}
          to={item.to}
          colorMode={colorMode}
          isFirst={index === 0}
          isLast={index === items.length - 1}
          hasNotif={hasNft && index === 0}
        />
      ))}
    </Container>
  );
};

export default Nav;
