import { useContractReader } from "eth-hooks";

export const useHasNft = (address, readContracts) => {
  const has = useContractReader(readContracts, "NFT30Web3", "claimed", [address]);
  return has;
};
