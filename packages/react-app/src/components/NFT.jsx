import { motion } from "framer-motion";
import { useThemeSwitcher } from "react-css-theme-switcher";
import styled from "styled-components";
import { useGetNft } from "../hooks/useGetNft";
import M3Typography from "../M3Typography";

const Styled = styled(motion.div)`
  width: 100%;
  max-width: 320px;
  max-height: 240px;
  aspect-ratio: 320 / 240;
  background: ${props => props.theme.get("md.sys.color.surface-variant", props.colorMode)};
  border-radius: 12px;
  box-shadow: ${props => props.theme.get("md.sys.elevation.level5", props.colorMode)};
  display: flex;
  justify-content: center;
  align-items: center;
`;

const Base = ({ children, colorMode }) => (
  <Styled
    colorMode={colorMode}
    whileHover={{
      scale: 1.05,
    }}
  >
    {children}
  </Styled>
);

const MysteryNFT = ({ colorMode }) => (
  <Base colorMode={colorMode}>
    <M3Typography style={{ fontSize: "10rem" }}>?</M3Typography>
  </Base>
);

// Nudge the dimensions of the SVG to fit its based
// in order to account for empty space around the
// actual NFT
const SvgToBaseAdapter = styled.img`
  transform: scaleX(1.07) scaleY(1.09);
`;

const ClaimedNFT = ({ address, readContracts }) => {
  const nft = useGetNft(address, readContracts);
  return nft ? (
    <Base whileHover={{ scale: 1.05 }}>
      <SvgToBaseAdapter src={nft.image} alt={nft.name + ", " + nft.description} />
    </Base>
  ) : (
    <Base>Error</Base>
  );
};

const NFT = ({ mystery, address, readContracts }) => {
  const { currentTheme } = useThemeSwitcher();
  const colorMode = currentTheme ?? "light";

  return mystery ? (
    <MysteryNFT colorMode={colorMode} />
  ) : (
    <ClaimedNFT address={address} readContracts={readContracts} />
  );
};

export default NFT;
