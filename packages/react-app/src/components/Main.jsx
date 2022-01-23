import React from "react";
import styled from "styled-components";

const StyledRoot = styled.div`
  width: 100%;
  flex-grow: 1;
`;

const Main = ({ children }) => {
  return <StyledRoot>{children}</StyledRoot>;
};

export default Main;
