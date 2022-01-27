import { useContractReader } from "eth-hooks";

const useHasNft = (address, readContracts) => {
  const has = useContractReader(readContracts, "NFT30Web3", "claimed", [address]);
  return has;
};

export default useHasNft;
