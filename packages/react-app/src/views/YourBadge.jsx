import { Spin } from "antd";
import PropTypes from "prop-types";
import styled from "styled-components";
import { GasGauge } from "../components";
import M3Button from "../components/M3Button";
import NFT from "../components/NFT";
import useHasNft from "../hooks/useHasNft";
import useHasNftClaimable from "../hooks/useHasNftClaimable";
import M3Typography from "../M3Typography";

const Base = styled.div`
  width: 100%;
  display: flex;
  flex-direction: column;
  align-items: center;
  flex-grow: 1;
  gap: 3rem;
`;

const Title = ({ children }) => (
  <M3Typography
    fontTokenId="md.sys.typescale.title-large"
    style={{ textAlign: "center", maxWidth: "42rem", height: "4rem" }}
  >
    {children}
  </M3Typography>
);

const NftClaimable = ({ gasPrice, onClaim }) => (
  <>
    <Title>
      Nice! Your participation to 30-Web3 has awarded you a new NFT. Claim now to discover it and receive it in your
      wallet 👀
    </Title>
    <NFT mystery />
    <div
      style={{
        display: "flex",
        flexDirection: "column",
        justifyContent: "center",
        alignItems: "center",
        gap: ".5rem",
      }}
    >
      <M3Button variant="filled" onClick={onClaim}>
        Claim now
      </M3Button>
      <GasGauge gasPrice={gasPrice} />
    </div>
  </>
);

const NftClaimed = ({ address, readContracts, localProvider }) => (
  <>
    <Title>This NFT is your reward for completing the 30-Web3 challenge. Congratulations 🎉</Title>
    <NFT address={address} readContracts={readContracts} localProvider={localProvider} />
  </>
);

const YourBadgeBase = ({ address, gasPrice, tx, readContracts, writeContracts, localProvider }) => {
  const hasNft = useHasNft(address, readContracts);
  const hasNftClaimable = useHasNftClaimable(address, readContracts);
  const handleClaim = async () => {
    const result = tx(writeContracts.NFT30Web3.mint(), update => {
      console.log("📡 Transaction Update:", update);
      if (update && (update.status === "confirmed" || update.status === 1)) {
        console.log(" 🍾 Transaction " + update.hash + " finished!");
        console.log(
          " ⛽️ " +
            update.gasUsed +
            "/" +
            (update.gasLimit || update.gas) +
            " @ " +
            parseFloat(update.gasPrice) / 1000000000 +
            " gwei",
        );
      }
    });
    console.log("awaiting metamask/web3 confirm result...", result);
    console.log(await result);
  };

  return (
    <Base>
      {typeof hasNft === "undefined" ? (
        <Spin />
      ) : hasNft ? (
        <NftClaimed address={address} readContracts={readContracts} localProvider={localProvider} />
      ) : hasNftClaimable ? (
        <NftClaimable gasPrice={gasPrice} tx={tx} onClaim={handleClaim} />
      ) : (
        <div>Sorry, no NFT for you</div>
      )}
    </Base>
  );
};

YourBadgeBase.propTypes = {
  address: PropTypes.string.isRequired,
};

const YourBadge = ({ address, gasPrice, tx, readContracts, writeContracts, localProvider }) => {
  return !address ? (
    <Spin />
  ) : (
    <YourBadgeBase
      address={address}
      gasPrice={gasPrice}
      tx={tx}
      readContracts={readContracts}
      writeContracts={writeContracts}
      localProvider={localProvider}
    />
  );
};

export default YourBadge;
