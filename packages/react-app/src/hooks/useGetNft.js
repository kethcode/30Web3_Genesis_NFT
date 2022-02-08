import { useContractReader } from "eth-hooks";
import parseTokenURI from "../helpers/parseTokenURI";

export const useGetNft = (id, readContracts) => {
  // Returns a string like "data:application/json;base64,XXX..."
  const tokenURI = useContractReader(readContracts, "NFT30Web3", "tokenURI", [id]);
  if (!tokenURI) return undefined;
  return parseTokenURI(tokenURI);
};
