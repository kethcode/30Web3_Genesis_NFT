import { useContractReader } from "eth-hooks";

const useIsAdmin = (address, readContracts) => {
  const isAdmin = useContractReader(readContracts, "NFT30Web3", "adminlist", [address]);
  return isAdmin;
};

export default useIsAdmin;
