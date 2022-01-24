import { GasGauge } from "../components";
import M3Button from "../components/M3Button";
import NFT from "../components/NFT";
import { useHasNftClaimable } from "../hooks/useHasNftClaimable";
import M3Typography from "../M3Typography";

const HasNftClaimable = ({ gasPrice }) => {
  return (
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
        Nice! Your participation to 30-Web3 has awarded you a new NFT badge. Mint now to discover it and receive it in
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
        <M3Button variant="filled">Claim now</M3Button>
        <GasGauge gasPrice={gasPrice} />
      </div>
    </div>
  );
};

const YourBadge = ({ gasPrice }) => {
  const hasNftClaimable = useHasNftClaimable();

  return hasNftClaimable ? <HasNftClaimable gasPrice={gasPrice} /> : <div>A sexy NFT</div>;
};

export default YourBadge;
