import M3Button from "../components/M3Button";
import { useHasNftClaimable } from "../hooks/useHasNftClaimable";

const YourBadge = () => {
  const hasNftClaimable = useHasNftClaimable();

  return hasNftClaimable ? <M3Button variant="filled">Claim now</M3Button> : <div>A sexy NFT</div>;
};

export default YourBadge;
