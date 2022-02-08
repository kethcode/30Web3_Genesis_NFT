import { Spin } from "antd";
import PropTypes from "prop-types";
import useHasNft from "../hooks/useHasNft";
import { ReactComponent as OlaSittingOnTheFloorFemale } from "../illustrations/OlaSittingOnTheFloorFemale.svg";
import Title from "../components/Title";
import Subtitle from "../components/Subtitle";
import AllAccountNFTs from "../components/AllAccountNFTs";

const NoNftThisAddress = () => (
  <>
    <div style={{ display: "flex", flexDirection: "column", gap: ".5rem" }}>
      <Title>Your NFT reward is on its way</Title>
      <Subtitle>
        Make sure you're connected with the wallet you used to register at 30W3. If you successfully passed the 30W3
        challenge, you should receive in a while. Come check again soon!
      </Subtitle>
    </div>
    <OlaSittingOnTheFloorFemale style={{ height: "18rem" }} />
  </>
);

const NftClaimed = ({ address, readContracts, localProvider }) => (
  <>
    <div style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: ".5rem" }}>
      <Title> Congratulations 🎉</Title>
      <Subtitle>
        This NFT is your reward for completing the 30W3 challenge. Flex it to your friends, you're now a Web3
        Buidloooooor!
      </Subtitle>
    </div>
    <AllAccountNFTs address={address} readContracts={readContracts} localProvider={localProvider} />
  </>
);

const YourBadgeBase = ({ address, readContracts, localProvider }) => {
  const hasNft = useHasNft(address, readContracts);
  return (
    <>
      {typeof hasNft === "undefined" ? (
        <Spin />
      ) : hasNft ? (
        <NftClaimed address={address} readContracts={readContracts} localProvider={localProvider} />
      ) : (
        <NoNftThisAddress />
      )}
    </>
  );
};

YourBadgeBase.propTypes = {
  address: PropTypes.string.isRequired,
};

const YourBadge = ({ address, readContracts, localProvider }) => {
  return !address ? (
    <Spin />
  ) : (
    <YourBadgeBase address={address} readContracts={readContracts} localProvider={localProvider} />
  );
};

export default YourBadge;
