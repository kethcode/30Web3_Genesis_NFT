import { Spin } from "antd";
import PropTypes from "prop-types";
import { GasGauge } from "../components";
import M3Button from "../components/M3Button";
import NFT from "../components/NFT";
import useHasNft from "../hooks/useHasNft";
import useHasNftClaimable from "../hooks/useHasNftClaimable";
import M3Typography from "../M3Typography";
import { ReactComponent as OlaSittingOnTheFloorFemale } from "../illustrations/OlaSittingOnTheFloorFemale.svg";

import { whitelist } from "../assets/whitelist.js";

const { MerkleTree } = require("merkletreejs");
const keccak256 = require("keccak256");

const Title = ({ children }) => (
  <M3Typography fontTokenId="md.sys.typescale.title-large" style={{ textAlign: "center", maxWidth: "42rem" }}>
    {children}
  </M3Typography>
);

const NoNftThisAddress = () => (
  <>
    <div style={{ display: "flex", flexDirection: "column", gap: ".5rem" }}>
      <Title>Sorry, your wallet isn't eligible to claim the NFT reward!</Title>
      <M3Typography
        fontTokenId="md.sys.typescale.body-large"
        colorTokenId="md.sys.color.on-surface-variant"
        style={{ textAlign: "center", maxWidth: "42rem" }}
      >
        Your wallet is eligible if you successfully passed the 30W3 challenge. If you did, connect with the address you
        used to register.
      </M3Typography>
    </div>
    <OlaSittingOnTheFloorFemale style={{ height: "18rem" }} />
  </>
);

const NftClaimable = ({ gasPrice, onClaim }) => (
  <>
    <div style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: ".5rem" }}>
      <Title>Heads Up!</Title>
      <M3Typography
        fontTokenId="md.sys.typescale.body-large"
        colorTokenId="md.sys.color.on-surface-variant"
        style={{ textAlign: "center", maxWidth: "42rem" }}
      >
        Your participation to 30-Web3 has awarded you a new NFT. Claim now to discover it and receive it in your wallet.
      </M3Typography>
    </div>
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
    <div style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: ".5rem" }}>
      <Title> Congratulations 🎉</Title>
      <M3Typography
        fontTokenId="md.sys.typescale.body-large"
        colorTokenId="md.sys.color.on-surface-variant"
        style={{ textAlign: "center", maxWidth: "42rem" }}
      >
        This NFT is your reward for completing the 30W3 challenge. Flex it to your friends, you're now a true Web3
        Buidloooooor!
      </M3Typography>
    </div>
    <NFT address={address} readContracts={readContracts} localProvider={localProvider} />
  </>
);

const YourBadgeBase = ({ address, gasPrice, tx, readContracts, writeContracts, localProvider }) => {
  const hasNft = useHasNft(address, readContracts);
  const hasNftClaimable = useHasNftClaimable(address, readContracts);

  const leafNodes = whitelist.map(address => keccak256(address));
  const merkleTree = new MerkleTree(leafNodes, keccak256, { sortPairs: true });
  const root = merkleTree.getRoot();
  const leaf = keccak256(address);
  const proof = merkleTree.getHexProof(leaf);

  const handleClaim = async () => {
    const result = tx(writeContracts.NFT30Web3.mint(proof, root, leaf), update => {
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
    <>
      {typeof hasNft === "undefined" ? (
        <Spin />
      ) : hasNft ? (
        <NftClaimed address={address} readContracts={readContracts} localProvider={localProvider} />
      ) : hasNftClaimable ? (
        <NftClaimable gasPrice={gasPrice} tx={tx} onClaim={handleClaim} />
      ) : (
        <NoNftThisAddress />
      )}
    </>
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
