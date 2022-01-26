import { useContractReader } from "eth-hooks";

export const useGetNft = (id, readContracts) => {
  // Returns a string like "data:application/json;base64,XXX..."
  const nft = useContractReader(readContracts, "NFT30Web3", "tokenURI", [id]);
  if (!nft) return undefined;
  // Remove the heading part ("data:application/json;base64,")
  const content = nft.substring(29, nft.length - 1);
  // Decode
  const decoded = Buffer.from(content, "base64");
  // Parse
  const parsed = JSON.parse(decoded);
  return parsed;
};
