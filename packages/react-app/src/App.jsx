import { Button, Col, Menu, Row } from "antd";
import "antd/dist/antd.css";
import {
  useBalance,
  useContractLoader,
  useContractReader,
  useGasPrice,
  useOnBlock,
  useUserProviderAndSigner,
} from "eth-hooks";
import { useExchangeEthPrice } from "eth-hooks/dapps/dex";
import React, { useCallback, useEffect, useState } from "react";
import { Link, Redirect, Route, Switch, useLocation } from "react-router-dom";
import "./App.css";
import {
  Account,
  Contract,
  Faucet,
  GasGauge,
  Header,
  Ramp,
  ThemeSwitcher,
  NetworkDisplay,
  FaucetHint,
  NetworkSwitch,
  Nav,
} from "./components";
import { NETWORKS, ALCHEMY_KEY } from "./constants";
import externalContracts from "./contracts/external_contracts";
// contracts
import deployedContracts from "./contracts/hardhat_contracts.json";
import { Transactor, Web3ModalSetup } from "./helpers";
import { Home, ExampleUI, Hints, Subgraph } from "./views";
import { useStaticJsonRPC } from "./hooks";
import styled from "styled-components";
import Connect from "./views/Connect";
import { useThemeSwitcher } from "react-css-theme-switcher";
import Main from "./components/Main";
import Demo from "./views/Demo";
import YourBadge from "./views/YourBadge";
import HallOfFame from "./views/HallOfFame";
import Relay from "./views/Relay";
import useIsConnected from "./hooks/useIsConnected";
import Content from "./components/Content";

const { ethers } = require("ethers");
/*
    Welcome to 🏗 scaffold-eth !

    Code:
    https://github.com/scaffold-eth/scaffold-eth

    Support:
    https://t.me/joinchat/KByvmRe5wkR-8F_zz6AjpA
    or DM @austingriffith on twitter or telegram

    You should get your own Alchemy.com & Infura.io ID and put it in `constants.js`
    (this is your connection to the main Ethereum network for ENS etc.)


    🌏 EXTERNAL CONTRACTS:
    You can also bring in contract artifacts in `constants.js`
    (and then use the `useExternalContractLoader()` hook!)
*/

/// 📡 What chain are your contracts deployed to?
const initialNetwork = NETWORKS.localhost; // <------- select your target frontend network (localhost, rinkeby, xdai, mainnet)

// 😬 Sorry for all the console logging
const DEBUG = false;
const NETWORKCHECK = true;
const USE_BURNER_WALLET = false; // toggle burner wallet feature
const USE_NETWORK_SELECTOR = true;

const web3Modal = Web3ModalSetup();

// 🛰 providers
const providers = [
  "https://eth-mainnet.gateway.pokt.network/v1/lb/611156b4a585a20035148406",
  `https://eth-mainnet.alchemyapi.io/v2/${ALCHEMY_KEY}`,
  "https://rpc.scaffoldeth.io:48544",
];

const StyledRoot = styled.div`
  background: ${props => props.theme.get("md.sys.color.background", props.currentTheme)};
  width: 100vw;
  height: 100vh;
  display: flex;
  flex-direction: column;
`;

const App = props => {
  const { currentTheme } = useThemeSwitcher();
  // specify all the chains your app is available on. Eg: ['localhost', 'mainnet', ...otherNetworks ]
  // reference './constants.js' for other networks
  const networkOptions = [initialNetwork.name, "mainnet", "rinkeby"];

  const [injectedProvider, setInjectedProvider] = useState();
  const [address, setAddress] = useState();
  const [selectedNetwork, setSelectedNetwork] = useState(networkOptions[0]);
  const location = useLocation();

  const targetNetwork = NETWORKS[selectedNetwork];

  // 🔭 block explorer URL
  const blockExplorer = targetNetwork.blockExplorer;

  // load all your providers
  const localProvider = useStaticJsonRPC([
    process.env.REACT_APP_PROVIDER ? process.env.REACT_APP_PROVIDER : targetNetwork.rpcUrl,
  ]);
  const mainnetProvider = useStaticJsonRPC(providers);

  if (DEBUG) console.log(`Using ${selectedNetwork} network`);

  // 🛰 providers
  if (DEBUG) console.log("📡 Connecting to Mainnet Ethereum");

  const logoutOfWeb3Modal = async () => {
    await web3Modal.clearCachedProvider();
    if (injectedProvider && injectedProvider.provider && typeof injectedProvider.provider.disconnect == "function") {
      await injectedProvider.provider.disconnect();
    }
    setTimeout(() => {
      window.location.reload();
    }, 1);
  };

  /* 💵 This hook will get the price of ETH from 🦄 Uniswap: */
  const price = useExchangeEthPrice(targetNetwork, mainnetProvider);

  /* 🔥 This hook will get the price of Gas from ⛽️ EtherGasStation */
  const gasPrice = useGasPrice(targetNetwork, "fast");
  // Use your injected provider from 🦊 Metamask or if you don't have it then instantly generate a 🔥 burner wallet.
  const userProviderAndSigner = useUserProviderAndSigner(injectedProvider, localProvider, USE_BURNER_WALLET);
  const userSigner = userProviderAndSigner.signer;

  useEffect(() => {
    async function getAddress() {
      if (userSigner) {
        const newAddress = await userSigner.getAddress();
        setAddress(newAddress);
      }
    }
    getAddress();
  }, [userSigner]);

  // You can warn the user if you would like them to be on a specific network
  const localChainId = localProvider && localProvider._network && localProvider._network.chainId;
  const selectedChainId =
    userSigner && userSigner.provider && userSigner.provider._network && userSigner.provider._network.chainId;

  // For more hooks, check out 🔗eth-hooks at: https://www.npmjs.com/package/eth-hooks

  // The transactor wraps transactions and provides notificiations
  const tx = Transactor(userSigner, gasPrice);

  // 🏗 scaffold-eth is full of handy hooks like this one to get your balance:
  const yourLocalBalance = useBalance(localProvider, address);

  // Just plug in different 🛰 providers to get your balance on different chains:
  const yourMainnetBalance = useBalance(mainnetProvider, address);

  // const contractConfig = useContractConfig();

  const contractConfig = { deployedContracts: deployedContracts || {}, externalContracts: externalContracts || {} };

  // Load in your local 📝 contract and read a value from it:
  const readContracts = useContractLoader(localProvider, contractConfig);

  // If you want to make 🔐 write transactions to your contracts, use the userSigner:
  const writeContracts = useContractLoader(userSigner, contractConfig, localChainId);

  // EXTERNAL CONTRACT EXAMPLE:
  //
  // If you want to bring in the mainnet DAI contract it would look like:
  const mainnetContracts = useContractLoader(mainnetProvider, contractConfig);

  // If you want to call a function on a new block
  useOnBlock(mainnetProvider, () => {
    console.log(`⛓ A new mainnet block is here: ${mainnetProvider._lastBlockNumber}`);
  });

  // Then read your DAI balance like:
  const myMainnetDAIBalance = useContractReader(mainnetContracts, "DAI", "balanceOf", [
    "0x34aA3F359A9D614239015126635CE7732c18fDF3",
  ]);

  // keep track of a variable from the contract in the local React state:
  const symbol = useContractReader(readContracts, "NFT30Web3", "symbol");

  /*
  const addressFromENS = useResolveName(mainnetProvider, "austingriffith.eth");
  console.log("🏷 Resolved austingriffith.eth as:",addressFromENS)
  */

  //
  // 🧫 DEBUG 👨🏻‍🔬
  //
  useEffect(() => {
    if (
      DEBUG &&
      mainnetProvider &&
      address &&
      selectedChainId &&
      yourLocalBalance &&
      yourMainnetBalance &&
      readContracts &&
      writeContracts &&
      mainnetContracts
    ) {
      console.log("_____________________________________ 🏗 scaffold-eth _____________________________________");
      console.log("🌎 mainnetProvider", mainnetProvider);
      console.log("🏠 localChainId", localChainId);
      console.log("👩‍💼 selected address:", address);
      console.log("🕵🏻‍♂️ selectedChainId:", selectedChainId);
      console.log("💵 yourLocalBalance", yourLocalBalance ? ethers.utils.formatEther(yourLocalBalance) : "...");
      console.log("💵 yourMainnetBalance", yourMainnetBalance ? ethers.utils.formatEther(yourMainnetBalance) : "...");
      console.log("📝 readContracts", readContracts);
      console.log("🌍 DAI contract on mainnet:", mainnetContracts);
      console.log("💵 yourMainnetDAIBalance", myMainnetDAIBalance);
      console.log("🔐 writeContracts", writeContracts);
    }
  }, [
    mainnetProvider,
    address,
    selectedChainId,
    yourLocalBalance,
    yourMainnetBalance,
    readContracts,
    writeContracts,
    mainnetContracts,
    localChainId,
    myMainnetDAIBalance,
  ]);

  const loadWeb3Modal = useCallback(async () => {
    const provider = await web3Modal.connect();
    setInjectedProvider(new ethers.providers.Web3Provider(provider));

    provider.on("chainChanged", chainId => {
      console.log(`chain changed to ${chainId}! updating providers`);
      setInjectedProvider(new ethers.providers.Web3Provider(provider));
    });

    provider.on("accountsChanged", () => {
      console.log(`account changed!`);
      setInjectedProvider(new ethers.providers.Web3Provider(provider));
      // Lazy ways
      //   window.location.reload();
      //   logoutOfWeb3Modal();
    });

    // Subscribe to session disconnection
    provider.on("disconnect", (code, reason) => {
      console.log(code, reason);
      logoutOfWeb3Modal();
    });
    // eslint-disable-next-line
  }, [setInjectedProvider]);

  useEffect(() => {
    if (web3Modal.cachedProvider) {
      loadWeb3Modal();
    }
  }, [loadWeb3Modal]);

  const isConnected = useIsConnected(web3Modal);

  const faucetAvailable = localProvider && localProvider.connection && targetNetwork.name.indexOf("local") !== -1;
  return (
    <StyledRoot currentTheme={currentTheme}>
      <Header
        web3Modal={web3Modal}
        account={
          <Account
            useBurner={false}
            address={address}
            localProvider={localProvider}
            userSigner={userSigner}
            mainnetProvider={mainnetProvider}
            price={price}
            web3Modal={web3Modal}
            loadWeb3Modal={loadWeb3Modal}
            logoutOfWeb3Modal={logoutOfWeb3Modal}
            blockExplorer={blockExplorer}
            buttonVariant="outline"
          />
        }
      />
      <NetworkDisplay
        NETWORKCHECK={NETWORKCHECK}
        localChainId={localChainId}
        selectedChainId={selectedChainId}
        targetNetwork={targetNetwork}
        logoutOfWeb3Modal={logoutOfWeb3Modal}
        USE_NETWORK_SELECTOR={USE_NETWORK_SELECTOR}
      />
      <Main>
        <Content>
          {!isConnected && <Redirect to="/connect" />}
          <Switch>
            <Route exact path="/">
              {isConnected ? <Redirect to="/badge" /> : <Redirect to="/connect" />}
            </Route>
            <Route exact path="/connect">
              {!isConnected ? <Connect web3Modal={web3Modal} loadWeb3Modal={loadWeb3Modal} /> : <Redirect to="/" />}
            </Route>
            <Route exact path="/badge">
              <YourBadge
                address={address}
                gasPrice={gasPrice}
                tx={tx}
                readContracts={readContracts}
                writeContracts={writeContracts}
                localProvider={localProvider}
              />
            </Route>
            <Route exact path="/hall">
              <HallOfFame />
            </Route>
            <Route exact path="/relay">
              <Relay />
            </Route>
            <Route exact path="/demo">
              <Demo />
            </Route>
            <Route path="/se">
              <Menu style={{ textAlign: "center", marginTop: 40 }} selectedKeys={[location.pathname]} mode="horizontal">
                <Menu.Item key="/se">
                  <Link to="/se/">App Home</Link>
                </Menu.Item>
                <Menu.Item key="/se/debug">
                  <Link to="/se/debug">Debug Contracts</Link>
                </Menu.Item>
                <Menu.Item key="/se/hints">
                  <Link to="/se/hints">Hints</Link>
                </Menu.Item>
                <Menu.Item key="/se/exampleui">
                  <Link to="/se/exampleui">ExampleUI</Link>
                </Menu.Item>
                <Menu.Item key="/se/mainnetdai">
                  <Link to="/se/mainnetdai">Mainnet DAI</Link>
                </Menu.Item>
                <Menu.Item key="/se/subgraph">
                  <Link to="/se/subgraph">Subgraph</Link>
                </Menu.Item>
              </Menu>
              <Switch>
                <Route exact path="/">
                  {/* pass in any web3 props to this Home component. For example, yourLocalBalance */}
                  <Home yourLocalBalance={yourLocalBalance} readContracts={readContracts} />
                </Route>
                <Route exact path="/se/debug">
                  <Contract
                    name="NFT30Web3"
                    price={price}
                    signer={userSigner}
                    provider={localProvider}
                    address={address}
                    blockExplorer={blockExplorer}
                    contractConfig={contractConfig}
                  />
                </Route>
                <Route path="/se/hints">
                  <Hints
                    address={address}
                    yourLocalBalance={yourLocalBalance}
                    mainnetProvider={mainnetProvider}
                    price={price}
                  />
                </Route>
                <Route path="/se/exampleui">
                  <ExampleUI
                    address={address}
                    userSigner={userSigner}
                    mainnetProvider={mainnetProvider}
                    localProvider={localProvider}
                    yourLocalBalance={yourLocalBalance}
                    price={price}
                    tx={tx}
                    writeContracts={writeContracts}
                    readContracts={readContracts}
                    purpose={symbol}
                  />
                </Route>
                <Route path="/se/mainnetdai">
                  <Contract
                    name="DAI"
                    customContract={mainnetContracts && mainnetContracts.contracts && mainnetContracts.contracts.DAI}
                    signer={userSigner}
                    provider={mainnetProvider}
                    address={address}
                    blockExplorer="https://etherscan.io/"
                    contractConfig={contractConfig}
                    chainId={1}
                  />
                  {/*
            <Contract
              name="UNI"
              customContract={mainnetContracts && mainnetContracts.contracts && mainnetContracts.contracts.UNI}
              signer={userSigner}
              provider={mainnetProvider}
              address={address}
              blockExplorer="https://etherscan.io/"
            />
            */}
                </Route>
                <Route path="/se/subgraph">
                  <Subgraph
                    subgraphUri={props.subgraphUri}
                    tx={tx}
                    writeContracts={writeContracts}
                    mainnetProvider={mainnetProvider}
                  />
                </Route>
              </Switch>
              <ThemeSwitcher />

              {/* 👨‍💼 Your account is in the top right with a wallet at connect options */}
              <div style={{ position: "fixed", textAlign: "right", right: 0, top: 0, padding: 10 }}>
                <div style={{ display: "flex", flex: 1, alignItems: "center" }}>
                  {USE_NETWORK_SELECTOR && (
                    <div style={{ marginRight: 20 }}>
                      <NetworkSwitch
                        networkOptions={networkOptions}
                        selectedNetwork={selectedNetwork}
                        setSelectedNetwork={setSelectedNetwork}
                      />
                    </div>
                  )}
                  <Account
                    useBurner={USE_BURNER_WALLET}
                    address={address}
                    localProvider={localProvider}
                    userSigner={userSigner}
                    mainnetProvider={mainnetProvider}
                    price={price}
                    web3Modal={web3Modal}
                    loadWeb3Modal={loadWeb3Modal}
                    logoutOfWeb3Modal={logoutOfWeb3Modal}
                    blockExplorer={blockExplorer}
                  />
                </div>
                {yourLocalBalance.lte(ethers.BigNumber.from("0")) && (
                  <FaucetHint localProvider={localProvider} targetNetwork={targetNetwork} address={address} />
                )}
              </div>

              {/* 🗺 Extra UI like gas price, eth price, faucet, and support: */}
              <div style={{ position: "fixed", textAlign: "left", left: 0, bottom: 20, padding: 10 }}>
                <Row align="middle" gutter={[4, 4]}>
                  <Col span={8}>
                    <Ramp price={price} address={address} networks={NETWORKS} />
                  </Col>

                  <Col span={8} style={{ textAlign: "center", opacity: 0.8 }}>
                    <GasGauge gasPrice={gasPrice} />
                  </Col>
                  <Col span={8} style={{ textAlign: "center", opacity: 1 }}>
                    <Button
                      onClick={() => {
                        window.open("https://t.me/joinchat/KByvmRe5wkR-8F_zz6AjpA");
                      }}
                      size="large"
                      shape="round"
                    >
                      <span style={{ marginRight: 8 }} role="img" aria-label="support">
                        💬
                      </span>
                      Support
                    </Button>
                  </Col>
                </Row>

                <Row align="middle" gutter={[4, 4]}>
                  <Col span={24}>
                    {
                      /*  if the local provider has a signer, let's show the faucet:  */
                      faucetAvailable ? (
                        <Faucet localProvider={localProvider} price={price} ensProvider={mainnetProvider} />
                      ) : (
                        ""
                      )
                    }
                  </Col>
                </Row>
              </div>
            </Route>
          </Switch>
        </Content>
        {isConnected && <Nav />}
      </Main>
    </StyledRoot>
  );
};

export default App;
