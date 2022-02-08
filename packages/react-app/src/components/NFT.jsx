import PropTypes from "prop-types";
import { Skeleton } from "antd";
import { motion } from "framer-motion";
import { useThemeSwitcher } from "react-css-theme-switcher";
import styled from "styled-components";
import { useGetNft } from "../hooks/useGetNft";
import useGetNftId from "../hooks/useGetNftId";
import M3Typography from "../M3Typography";

const Styled = styled(motion.div)`
  width: 100%;
  max-width: 18rem;
  max-height: 18rem;
  aspect-ratio: 1 / 1;
  background: #efefef;
  border-radius: 28px;
  box-shadow: ${props => props.theme.get("md.sys.elevation.level3", props.colorMode)};
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
    <M3Typography style={{ fontSize: "10rem" }} colorTokenId="md.sys.color.primary">
      ?
    </M3Typography>
  </Base>
);

const LoadingNFT = () => (
  <Base>
    <div
      style={{
        width: "80%",
        height: "85%",
        transform: "translateY(-6px)",
        padding: "1rem",
        display: "flex",
        flexDirection: "column",
        gap: ".5rem",
        justifyContent: "space-around",
        alignItems: "center",
      }}
    >
      <Skeleton active title paragraph={false} />
      <Skeleton.Image active size="large" height="2rem" width="2rem" />
    </div>
  </Base>
);

const SvgToBaseAdapter = styled.img`
  width: 100%;
`;
const ClaimedNFT = ({ name, description, image, disableHoverEffect }) => (
  <Base disableHoverEffect={disableHoverEffect}>
    <SvgToBaseAdapter src={image} alt={name + ", " + description} />
  </Base>
);

// Lazily call "useGetNft" to prevent initial caching when nftId is undefined
const NftLoader = ({ id, readContracts, disableHoverEffect }) => {
  const nft = useGetNft(id, readContracts);
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

// Lazily call "useGetNftId" to prevent initial caching when address is undefined
const NftIdLoader = ({ address, index, readContracts, localProvider, disableHoverEffect }) => {
  const id = useGetNftId(address, index, readContracts);
  return id >= 0 ? (
    <NftLoader
      id={id}
      address={address}
      readContracts={readContracts}
      localProvider={localProvider}
      disableHoverEffect={disableHoverEffect}
    />
  ) : (
    <LoadingNFT />
  );
};

// Lazily render underlying component to prevent initial caching when address is undefined
const IfAddress = ({ address, id, index, readContracts, localProvider, disableHoverEffect }) => {
  if (!address) return <LoadingNFT />;

  if (id >= 0)
    return (
      <NftLoader
        address={address}
        id={id}
        readContracts={readContracts}
        localProvider={localProvider}
        disableHoverEffect={disableHoverEffect}
      />
    );

  if (index >= 0)
    return (
      <NftIdLoader
        address={address}
        index={index}
        readContracts={readContracts}
        localProvider={localProvider}
        disableHoverEffect={disableHoverEffect}
      />
    );

  return <LoadingNFT />;
};

const NFT = ({ mystery, address, id, index, readContracts, localProvider, disableHoverEffect }) => {
  const { currentTheme } = useThemeSwitcher();
  const colorMode = currentTheme ?? "light";
  return mystery ? (
    <MysteryNFT colorMode={colorMode} />
  ) : (
    <IfAddress
      address={address}
      id={id}
      index={index}
      readContracts={readContracts}
      localProvider={localProvider}
      disableHoverEffect={disableHoverEffect}
    />
  );
};

NFT.propTypes = {
  mystery: PropTypes.bool,
  address: PropTypes.string,
  id: PropTypes.number, // ID of the NFT
  index: PropTypes.number, // index of the NFT for this address, returned by ERC721Enumerable.tokenOfOwnerByIndex
  disableHoverEffect: PropTypes.bool,
};

NFT.defaultProps = {
  mystery: false,
  disableHoverEffect: false,
};

export default NFT;
