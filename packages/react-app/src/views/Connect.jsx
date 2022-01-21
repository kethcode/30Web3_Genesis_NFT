import styled from "styled-components";
import ButtonsDemo from "./ButtonsDemo";

const StyledRoot = styled.div`
  height: calc(100vh - 4.5rem);
`;

const Connect = () => {
  return (
    <StyledRoot>
      <ButtonsDemo />
    </StyledRoot>
  );
};

export default Connect;
