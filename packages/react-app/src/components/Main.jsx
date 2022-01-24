import React from "react";
import styled from "styled-components";

const StyledRoot = styled.div`
  width: 100%;
  flex-grow: 1;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  align-items: center;
  padding: 3rem;
`;

const Main = ({ children }) => {
  return <StyledRoot>{children}</StyledRoot>;
};

export default Main;
