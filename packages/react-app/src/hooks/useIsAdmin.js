import { useContractReader } from "eth-hooks";
import keccak256 from "keccak256";

const useIsAdmin = (address, readContracts) => {
  const ADMIN_ROLE = useContractReader(readContracts, "NFT30Web3", "ADMIN_ROLE");
  const isAdmin = useContractReader(readContracts, "NFT30Web3", "hasRole", [ADMIN_ROLE], [address]);
  console.log("isAdmin:", [address], isAdmin);
  return isAdmin;
};

export default useIsAdmin;