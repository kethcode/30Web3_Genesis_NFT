import React from "react";
import { Link } from "react-router-dom";
import styled from "styled-components";
import { useIsConnected } from "../hooks/useIsConnected";
import { ReactComponent as Logo } from "../illustrations/Logo.svg";
import ThemeSwitcher from "./ThemeSwitcher";

const StyledRoot = styled.div`
  height: 4.5rem;
  display: flex;
  padding: 1rem;
  justify-content: ${props => (!props.isConnected ? "flex-end" : "space-between")};
`;

const Header = ({ account, web3Modal }) => {
  const isConnected = useIsConnected(web3Modal);

  return (
    <StyledRoot isConnected={isConnected}>
      {isConnected && (
        <Link to="/">
          <Logo height="40px" width="54px" />
        </Link>
      )}
      <div style={{ display: "flex", gap: ".5rem" }}>
        <ThemeSwitcher />
        {isConnected && account}
      </div>
    </StyledRoot>
  );
};

export default Header;
