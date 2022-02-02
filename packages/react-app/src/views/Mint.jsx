import React, { useState } from "react";
import { Input, Spin } from "antd";
import PropTypes from "prop-types";
import { MerkleTree } from "merkletreejs";
import keccak256 from "keccak256";
import M3Button from "../components/M3Button";
import Title from "../components/Title";
import Subtitle from "../components/Subtitle";
import { Link } from "react-router-dom";
import MINTER_ADDRESS from "../MINTER_ADDRESS";
import { whitelist } from "../assets/whitelist.js";

const WrongAddress = () => (
  <>
    <Title>Woops!</Title>
    <Subtitle>This page is accessible to 30W3 admins only.</Subtitle>
    <Link to="/">
      <M3Button icon={<span className="material-icons">arrow_back</span>}>Back to home</M3Button>
    </Link>
  </>
);

const Mint = ({ address, writeContracts, tx }) => {
  const ADDRESS_REGEX = /0x[a-zA-Z0-9]{40}/;
  const [transferTo, setTransferTo] = useState();
  const [minting, setMinting] = useState(false);
  const handleChange = e => setTransferTo(e.target.value);

  const leafNodes = whitelist.map(address => keccak256(address));
  const merkleTree = new MerkleTree(leafNodes, keccak256, { sortPairs: true });
  const root = merkleTree.getRoot();
  const leaf = keccak256(address);
  const proof = merkleTree.getHexProof(leaf);

  const handleMintAndTransfer = async () => {
    setMinting(true);
    const result = tx(writeContracts.NFT30Web3.mint(proof, root, leaf), update => {
      setMinting(false);
      console.log("📡 Transaction Update:", update);
      if (update && (update.status === "confirmed" || update.status === 1)) {
        setTransferTo(undefined);
        console.log(" 🍾 Transaction " + update.hash + " finished!");
        console.log(
          " ⛽️ " +
            update.gasUsed +
            "/" +
            (update.gasLimit || update.gas) +
            " @ " +
            parseFloat(update.gasPrice) / 1000000000 +
            " gwei",
        );
      }
    });
    console.log("awaiting metamask/web3 confirm result...", result);
    console.log(await result);
  };

  return address !== MINTER_ADDRESS ? (
    <WrongAddress />
  ) : (
    <>
      <Title>Welcome, Admin</Title>
      <Subtitle>
        This page is only available to you. Mint here and immediately transfer the reward NFT to deserving participants.
      </Subtitle>
      <div style={{ display: "flex", gap: "1rem" }}>
        <Input
          value={transferTo}
          placeholder="Recipient address"
          onChange={handleChange}
          style={{ width: "24rem", borderRadius: "100px" }}
        />
        <M3Button
          disabled={minting || !transferTo || !transferTo.match(ADDRESS_REGEX)}
          icon={minting ? <Spin /> : <span className="material-icons">auto_awesome</span>}
          onClick={handleMintAndTransfer}
        >
          Mint and transfer
        </M3Button>
      </div>
    </>
  );
};

Mint.propTypes = {
  address: PropTypes.string.isRequired,
};

export default Mint;
