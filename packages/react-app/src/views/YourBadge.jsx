import { GasGauge } from "../components";
import M3Button from "../components/M3Button";
import NFT from "../components/NFT";
import useHasNft from "../hooks/useHasNft";
import useHasNftClaimable from "../hooks/useHasNftClaimable";
import M3Typography from "../M3Typography";

const NftClaimable = ({ gasPrice, onClaim }) => (
  <div
    style={{
      display: "flex",
      flexDirection: "column",
      justifyContent: "center",
      alignItems: "center",
      flexGrow: 1,
      gap: "3rem",
    }}
  >
    <NFT mystery />
    <M3Typography style={{ textAlign: "center", maxWidth: "30rem" }}>
      Nice! Your participation to 30-Web3 has awarded you a new NFT badge. Claim now to discover it and receive it in
      your wallet.
    </M3Typography>
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
  </div>
);

const YourBadgeBase = ({ address, gasPrice, tx, readContracts, writeContracts }) => {
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

  if (hasNft) {
    return <NFT address={address} readContracts={readContracts} />;
  } else if (hasNftClaimable) {
    return <NftClaimable gasPrice={gasPrice} tx={tx} onClaim={handleClaim} />;
  } else {
    return <div>Sorry, no NFT for you</div>;
  }
};

const YourBadge = ({ address, gasPrice, tx, readContracts, writeContracts }) => {
  return (
    <div style={{ height: "100%", display: "flex", alignItems: "center" }}>
      {!address ? (
        <div>Loading...</div>
      ) : (
        <YourBadgeBase
          address={address}
          gasPrice={gasPrice}
          tx={tx}
          readContracts={readContracts}
          writeContracts={writeContracts}
        />
      )}
    </div>
  );
};

export default YourBadge;
