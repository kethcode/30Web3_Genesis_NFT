import { ReactComponent as Logo } from "../illustrations/Logo.svg";
import { Account } from "../components";
import M3Typography from "../M3Typography";
import Nav from "../components/Nav";

const Connect = ({ web3Modal, loadWeb3Modal }) => {
  return (
    <div
      style={{
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        justifyContent: "center",
        gap: "3rem",
        height: "100%",
      }}
    >
      <Logo width="17rem" />
      <M3Typography fontTokenId="md.sys.typescale.headline-large">Welcome, buidler</M3Typography>
      <div>
        <Account web3Modal={web3Modal} loadWeb3Modal={loadWeb3Modal} buttonVariant="filled" />
      </div>
      <Nav />
    </div>
  );
};

export default Connect;
