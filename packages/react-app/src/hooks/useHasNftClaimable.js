import { useContractReader } from "eth-hooks";
import { whitelist } from "../assets/whitelist.js";

const { MerkleTree } = require("merkletreejs");
const keccak256 = require("keccak256");

const useHasNftClaimable = (address, readContracts) => {
  let retval = false;

  const leafNodes = whitelist.map(address => keccak256(address));
  const merkleTree = new MerkleTree(leafNodes, keccak256, { sortPairs: true });
  const root = merkleTree.getRoot();
  const leaf = keccak256(address);
  const proof = merkleTree.getHexProof(leaf);

  // return await tx(readContracts.NFT30Web3.verify(proof, root, leaf));

  retval = useContractReader(readContracts, "NFT30Web3", "verify", [proof, root, leaf]);
  return retval;
};

export default useHasNftClaimable;
