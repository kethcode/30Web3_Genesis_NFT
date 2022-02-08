import React, { useState } from "react";
import { Spin } from "antd";
import PropTypes from "prop-types";
import M3Button from "../components/M3Button";
import Title from "../components/Title";
import Subtitle from "../components/Subtitle";
import { Link } from "react-router-dom";
import MINTER_ADDRESS from "../MINTER_ADDRESS";
import { AddressInput } from "../components";

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
  const ADDRESS_OR_ENS_REGEX = /(0x[a-zA-Z0-9]{40}|.*.eth)/; // Matches "0x....." or "xxxx.eth"
  const [transferTo, setTransferTo] = useState();
  const [minting, setMinting] = useState(false);

  const handleMintAndTransfer = async () => {
    setMinting(true);
    const result = tx(writeContracts.NFT30Web3.mint(transferTo), update => {
      setMinting(false);
      console.log("📡 Transaction Update:", update);
      if (update && (update.status === "confirmed" || update.status === 1)) {
        setTransferTo("");
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
        This page is only available to users with role "ADMIN_ROLE". Mint here and immediately transfer the reward NFT
        to deserving participants.
      </Subtitle>
      <div style={{ display: "flex", gap: "1rem", alignItems: "center", width: "100%", maxWidth: "44rem" }}>
        <AddressInput
          value={transferTo}
          placeholder="Recipient address"
          onChange={setTransferTo}
          style={{ flexGrow: 1 }}
        />
        <M3Button
          disabled={minting || !transferTo || !transferTo.match(ADDRESS_OR_ENS_REGEX)}
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
