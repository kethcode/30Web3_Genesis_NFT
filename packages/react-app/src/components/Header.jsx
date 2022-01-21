import React from "react";
import { Link } from "react-router-dom";
import styled from "styled-components";
import { ReactComponent as Logo } from "../illustrations/Logo.svg";
import ThemeSwitch from "./ThemeSwitch";

const StyledRoot = styled.div`
  width: 100vw;
  height: 4.5rem;
  display: flex;
  padding: 1rem;
  justify-content: space-between;
`;

const Header = ({ account }) => {
  return (
    <StyledRoot>
      <Link to="/">
        <Logo height="40px" width="54px" />
      </Link>
      <div style={{ display: "flex", gap: ".5rem" }}>
        <ThemeSwitch />
        {account}
      </div>
    </StyledRoot>
  );
};

export default Header;
