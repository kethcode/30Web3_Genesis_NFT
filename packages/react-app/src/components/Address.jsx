import { Skeleton } from "antd";
import React from "react";
import PropTypes from "prop-types";
import Blockies from "react-blockies";
import { useThemeSwitcher } from "react-css-theme-switcher";
import { useLookupAddress } from "eth-hooks/dapps/ens";
import M3Button from "./M3Button";

const blockExplorerLink = (address, blockExplorer) => `${blockExplorer || "https://etherscan.io/"}address/${address}`;

/*
  ~ What it does? ~

  Displays an address with a blockie image and option to copy address

  ~ How can I use? ~

  <Address
    address={address}
    ensProvider={mainnetProvider}
    blockExplorer={blockExplorer}
    fontSize={fontSize}
  />

  ~ Features ~

  - Provide ensProvider={mainnetProvider} and your address will be replaced by ENS name
              (ex. "0xa870" => "user.eth")
  - Provide blockExplorer={blockExplorer}, click on address and get the link
              (ex. by default "https://etherscan.io/" or for xdai "https://blockscout.com/poa/xdai/")
  - Provide fontSize={fontSize} to change the size of address text
*/
const Address = props => {
  const { currentTheme } = useThemeSwitcher();
  const address = props.value || props.address;
  const ens = useLookupAddress(props.ensProvider, address);
  const ensSplit = ens && ens.split(".");
  const validEnsCheck = ensSplit && ensSplit[ensSplit.length - 1] === "eth";
  const etherscanLink = blockExplorerLink(address, props.blockExplorer);
  let displayAddress = address?.substr(0, 5) + "..." + address?.substr(-4);

  if (validEnsCheck) {
    displayAddress = ens;
  } else if (props.size === "short") {
    displayAddress += "..." + address.substr(-4);
  } else if (props.size === "long") {
    displayAddress = address;
  }

  if (!address) {
    return (
      <span>
        <Skeleton avatar paragraph={{ rows: 1 }} />
      </span>
    );
  }

  if (props.minimized) {
    return (
      <span style={{ verticalAlign: "middle" }}>
        <a
          style={{ color: currentTheme === "light" ? "#222222" : "#ddd" }}
          target="_blank"
          href={etherscanLink}
          rel="noopener noreferrer"
        >
          <Blockies seed={address.toLowerCase()} size={8} scale={2} />
        </a>
      </span>
    );
  }
  console.log("etherscanLink", etherscanLink);
  return (
    <a href={etherscanLink} target="_blank" rel="noopener noreferrer">
      <M3Button
        variant={props.variant}
        icon={
          <div style={{ borderRadius: "100px", overflow: "hidden", width: "24px", height: "24px" }}>
            <Blockies seed={address.toLowerCase()} size={8} scale={3} />
          </div>
        }
      >
        {displayAddress}
        {/* <span style={{ verticalAlign: "middle" }}> */}

        {/* </span> */}
        {/* <span style={{ verticalAlign: "middle", paddingLeft: 5, fontSize: props.fontSize ? props.fontSize : 28 }}> */}
        {/* {props.onChange ? (
        <Typography editable={{ onChange: props.onChange }} copyable={{ text: address }}>
          <a
            // style={{ color: currentTheme === "light" ? "#222222" : "#ddd" }}
            target="_blank"
            href={etherscanLink}
            rel="noopener noreferrer"
          >
            {displayAddress}
          </a>
        </Typography>
      ) : (
        <Text copyable={{ text: address }}>
          <a
            style={{ color: currentTheme === "light" ? "#222222" : "#ddd" }}
            target="_blank"
            href={etherscanLink}
            rel="noopener noreferrer"
          >
            {displayAddress}
          </a>
        </Text>
      )} */}
      </M3Button>
    </a>
  );
};

M3Button.propTypes = {
  variant: PropTypes.oneOf(["filled", "outline", "elevated", "text", "tonal"]),
};

Address.defaultProps = {
  variant: "filled",
};

export default Address;
