import { useContractReader } from "eth-hooks";

const useGetNftId = (address, index, readContracts) => {
  const id = useContractReader(readContracts, "NFT30Web3", "tokenOfOwnerByIndex", [address, index]);
  return Number(id?._hex);
};

export default useGetNftId;
