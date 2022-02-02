import { useContractReader } from "eth-hooks";

const useHasNft = (address, readContracts) => {
  const balanceOf = useContractReader(readContracts, "NFT30Web3", "balanceOf", [address]);
  return balanceOf > 0;
};

export default useHasNft;
