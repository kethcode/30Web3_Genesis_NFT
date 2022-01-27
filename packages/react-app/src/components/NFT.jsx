import { Spin } from "antd";
import { motion } from "framer-motion";
import { useThemeSwitcher } from "react-css-theme-switcher";
import styled from "styled-components";
import { useGetNft } from "../hooks/useGetNft";
import useGetNftId from "../hooks/useGetNftId";
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

const Base = ({ children, colorMode, disableHoverEffect }) => (
  <Styled
    colorMode={colorMode}
    whileHover={{
      scale: disableHoverEffect ? 1 : 1.05,
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

const LoadingNFT = () => (
  <Base>
    <Spin />
  </Base>
);

// Lazily render underlying componentto prevent initial caching when address is undefined
const IfAddress = ({ address, readContracts, localProvider, disableHoverEffect }) =>
  address ? (
    <NftIdLoader
      address={address}
      readContracts={readContracts}
      localProvider={localProvider}
      disableHoverEffect={disableHoverEffect}
    />
  ) : (
    <LoadingNFT />
  );

// Lazily call "useGetNftId" to prevent initial caching when address is undefined
const NftIdLoader = ({ address, readContracts, localProvider, disableHoverEffect }) => {
  const nftId = useGetNftId(address, readContracts, localProvider);
  return nftId >= 0 ? (
    <NftLoader
      nftId={nftId}
      address={address}
      readContracts={readContracts}
      localProvider={localProvider}
      disableHoverEffect={disableHoverEffect}
    />
  ) : (
    <LoadingNFT />
  );
};

// Lazily call "useGetNft" to prevent initial caching when nftId is undefined
const NftLoader = ({ nftId, readContracts, disableHoverEffect }) => {
  const nft = useGetNft(nftId, readContracts);
  return nft ? (
    <ClaimedNFT
      name={nft.name}
      description={nft.description}
      image={nft.image}
      disableHoverEffect={disableHoverEffect}
    />
  ) : (
    <LoadingNFT />
  );
};

// Nudge the dimensions of the SVG to fit its based
// in order to account for empty space around the
// actual NFT
const SvgToBaseAdapter = styled.img`
  width: 100%;
  transform: scaleX(1.07) scaleY(1.09);
`;
const ClaimedNFT = ({ name, description, image, disableHoverEffect }) => (
  <Base disableHoverEffect={disableHoverEffect}>
    <SvgToBaseAdapter src={image} alt={name + ", " + description} />
  </Base>
);

const NFT = ({ mystery, address, readContracts, localProvider, disableHoverEffect }) => {
  const { currentTheme } = useThemeSwitcher();
  const colorMode = currentTheme ?? "light";
  return mystery ? (
    <MysteryNFT colorMode={colorMode} />
  ) : (
    <IfAddress
      address={address}
      readContracts={readContracts}
      localProvider={localProvider}
      disableHoverEffect={disableHoverEffect}
    />
  );
};

NFT.defaultProps = {
  mystery: false,
  disableHoverEffect: false,
};

export default NFT;
