import { Spin } from "antd";
import { motion } from "framer-motion";
import { useThemeSwitcher } from "react-css-theme-switcher";
import styled from "styled-components";
import _ from "lodash";
import { Address } from "../components";
import NFT from "../components/NFT";
import M3Typography from "../M3Typography";
import { ReactComponent as OlaSittingOnTheFloorMale } from "../illustrations/OlaSittingOnTheFloorMale.svg";
import useIsConnected from "../hooks/useIsConnected";
import M3Button from "../components/M3Button";
import { Link } from "react-router-dom";
import Title from "../components/Title";
import Subtitle from "../components/Subtitle";

const Container = styled(motion.ul)`
  width: 100%;
  max-width: 68rem;
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(13rem, 1fr));
  grid-template-rows: repeat(auto-fit, 1fr);
  justify-content: flex-start;
  align-items: flex-start;
  justify-items: center;
  gap: 2rem;
  margin: 0;
  list-style: none;
  padding: 0;
  overflow-x: auto;
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

const Texts = ({ transferEvents, web3Modal }) => {
  const isConnected = useIsConnected(web3Modal);
  return (
    <div style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: ".5rem" }}>
      {transferEvents && transferEvents.length > 0 ? (
        <>
          <Title>Great Web3 builders</Title>
          <Subtitle>Who all successfully passed the 30W3 challenge. Kudos to all 👏</Subtitle>
        </>
      ) : (
        <>
          <Title>No one claimed their reward yet</Title>
          <Subtitle>
            {isConnected ? (
              <>
                Head over <b>Your badge</b> now to be the first to claim your 30W3 NFT reward!
              </>
            ) : (
              <>Connect your wallet to be the first to claim your 30W3 NFT reward!</>
            )}
          </Subtitle>
        </>
      )}
    </div>
  );
};

const Actions = ({ web3Modal, account }) => {
  const isConnected = useIsConnected(web3Modal);
  return (
    !isConnected && (
      <div style={{ display: "flex", gap: "2rem" }}>
        <Link to="/">
          <M3Button variant="text" icon={<span className="material-icons">arrow_back</span>}>
            Back
          </M3Button>
        </Link>
        {account}
      </div>
    )
  );
};

const Content = ({ transferEvents, readContracts, localProvider, mainnetProvider }) => {
  const { currentTheme } = useThemeSwitcher();
  const colorMode = currentTheme ?? "light";
  const events = _.chain([...transferEvents])
    .sortBy("blockNumber")
    .reverse()
    .uniqBy(e => e.args[2]._hex)
    .value()
    .reverse();

  return transferEvents && transferEvents.length > 0 ? (
    <Container variants={containerMotion} initial="hidden" animate="visible">
      {events.map((e, index) => (
        <Item key={index} address={e.args[1]} colorMode={colorMode} variants={itemMotion}>
          <NFT address={e.args[1]} readContracts={readContracts} localProvider={localProvider} disableHoverEffect />
          <StyledAddress address={e.args[1]} ensProvider={mainnetProvider} variant="text" />
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
              Received at block #{e.blockNumber}
            </M3Typography>
          </div>
        </Item>
      ))}
    </Container>
  ) : transferEvents && transferEvents.length === 0 ? (
    <OlaSittingOnTheFloorMale style={{ height: "18rem" }} />
  ) : (
    <Spin />
  );
};

const HallOfFame = ({ transferEvents, readContracts, localProvider, mainnetProvider, web3Modal, account }) => {
  return (
    <>
      <Texts transferEvents={transferEvents} />
      <Actions web3Modal={web3Modal} account={account} />
      <Content
        transferEvents={transferEvents}
        readContracts={readContracts}
        localProvider={localProvider}
        mainnetProvider={mainnetProvider}
        web3Modal={web3Modal}
        account={account}
      />
    </>
  );
};

export default HallOfFame;
