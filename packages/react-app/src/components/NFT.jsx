import { motion } from "framer-motion";
import { useThemeSwitcher } from "react-css-theme-switcher";
import styled from "styled-components";
import M3Typography from "../M3Typography";

const Base = styled(motion.div)`
  width: 100%;
  max-width: 278px;
  max-height: 278px;
  aspect-ratio: 1 / 1;
  background: ${props => props.theme.get("md.sys.color.surface-variant", props.colorMode)};
  border-radius: 12px;
  box-shadow: ${props => props.theme.get("md.sys.elevation.level1", props.colorMode)};
  display: flex;
  justify-content: center;
  align-items: center;
`;

const MysteryNFT = ({ colorMode }) => (
  <Base colorMode={colorMode} whileHover={{ scale: 1.05 }}>
    <M3Typography style={{ fontSize: "10rem" }}>?</M3Typography>
  </Base>
);

const NFT = ({ mystery }) => {
  const { currentTheme } = useThemeSwitcher();
  const colorMode = currentTheme ?? "light";
  return mystery ? <MysteryNFT colorMode={colorMode} /> : <Base>Cool NFT content</Base>;
};

export default NFT;
