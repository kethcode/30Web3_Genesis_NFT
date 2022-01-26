import { useContractReader } from "eth-hooks";

const useHasNft = (address, readContracts) => {
  const has = useContractReader(readContracts, "NFT30Web3", "claimed", [address]);
  console.log("useHasNft", has);
  return has;
};

export default useHasNft;
