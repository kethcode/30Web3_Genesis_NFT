import { useContractReader } from "eth-hooks";

const useHasNft = (address, readContracts) => {
  const has = useContractReader(readContracts, "NFT30Web3", "claimed", [address]);
  //   console.log("useHasNft", has);
  //   console.log("readContracts", readContracts);
  //   console.log("address", address);
  return has;
};

export default useHasNft;
