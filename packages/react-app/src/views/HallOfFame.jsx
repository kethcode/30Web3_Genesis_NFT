import { Spin } from "antd";
import { motion } from "framer-motion";
import { useThemeSwitcher } from "react-css-theme-switcher";
import styled from "styled-components";
import { Address } from "../components";
import NFT from "../components/NFT";
import M3Typography from "../M3Typography";
import { ReactComponent as OlaSittingOnTheFloorMale } from "../illustrations/OlaSittingOnTheFloorMale.svg";

const Container = styled(motion.ul)`
  width: 100%;
  height: calc(100vh - 14.5rem);
  max-width: 68rem;
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(13rem, 1fr));
  justify-content: flex-start;
  align-items: flex-start;
  justify-items: center;
  gap: 2rem;
  margin: 0;
  list-style: none;
  padding: 0;
  overflow: scroll;
`;

const containerMotion = {
  hidden: { opacity: 1, scale: 0 },
  visible: {
    opacity: 1,
    scale: 1,
    transition: {
      delayChildren: 0.3,
      staggerChildren: 0.1,
    },
  },
};

const ItemStyles = styled(motion.li)`
  width: 13rem;
  padding: 1rem;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  gap: 0.5rem;
  //   border: 1px solid ${props => props.theme.get("md.sys.color.outline", props.colorMode)};
  background: ${props => props.theme.get("md.sys.color.surface", props.colorMode)};
  border-radius: 12px;
`;

const Item = ({ colorMode, variants, children }) => {
  return (
    <ItemStyles colorMode={colorMode} variants={variants}>
      {children}
    </ItemStyles>
  );
};

const itemMotion = {
  hidden: { y: 10, opacity: 0 },
  visible: {
    y: 0,
    opacity: 1,
  },
};

const DateIcon = styled.span`
  color: ${props => props.theme.get("md.sys.color.on-surface-variant", props.colorMode)};
`;

const StyledAddress = styled(Address)`
  margin-top: 2rem;
  margin-bottom: 0.5rem;
`;

const NoOwnerYet = () => (
  <>
    <div style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: ".5rem" }}>
      <M3Typography fontTokenId="md.sys.typescale.title-large" colorTokenId="md.sys.color.on-background">
        No one claimed their reward yet!
      </M3Typography>
      <M3Typography
        fontTokenId="md.sys.typescale.body-large"
        colorTokenId="md.sys.color.on-surface-variant"
        style={{ textAlign: "center", maxWidth: "42rem" }}
      >
        Head over <b>Your badge</b> now to be the first to claim your 30W3 NFT reward.
      </M3Typography>
    </div>
    <OlaSittingOnTheFloorMale style={{ height: "18rem" }} />
  </>
);

const HallOfFame = ({ transferEvents, readContracts, localProvider, mainnetProvider }) => {
  const { currentTheme } = useThemeSwitcher();
  const colorMode = currentTheme ?? "light";
  return transferEvents && transferEvents.length > 0 ? (
    <Container variants={containerMotion} initial="hidden" animate="visible">
      {transferEvents.map(e => (
        <Item key={e.args[1]} address={e.args[1]} colorMode={colorMode} variants={itemMotion}>
          <NFT address={e.args[1]} readContracts={readContracts} localProvider={localProvider} disableHoverEffect />
          <StyledAddress
            address={e.args[1]}
            ensProvider={mainnetProvider}
            variant="text"
            // style={{
            //   marginTop: "2rem",
            //   marginBottom: "0.5rem",
            // }}
          />
          <div
            style={{
              display: "flex",
              justifyContent: "center",
              alignItems: "center",
              gap: "0.5rem",
            }}
          >
            <DateIcon className="material-icons" colorMode={colorMode}>
              event
            </DateIcon>
            <M3Typography fontTokenId="md.sys.typescale.label-medium" colorTokenId="md.sys.color.on-surface-variant">
              Minted at block #{e.blockNumber}
            </M3Typography>
          </div>
        </Item>
      ))}
    </Container>
  ) : transferEvents && transferEvents.length === 0 ? (
    <NoOwnerYet />
  ) : (
    <Spin />
  );
};

export default HallOfFame;
