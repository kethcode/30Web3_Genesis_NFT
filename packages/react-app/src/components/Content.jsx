import React from "react";
import styled from "styled-components";

const StyledRoot = styled.div`
  width: 100%;
  flex-grow: 1;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  gap: 4rem;
  margin-bottom: 8rem;
`;

const Content = ({ children }) => {
  return <StyledRoot>{children}</StyledRoot>;
};

export default Content;
