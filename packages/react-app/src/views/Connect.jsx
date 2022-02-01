import { ReactComponent as Logo } from "../illustrations/Logo.svg";
import { Account } from "../components";
import M3Typography from "../M3Typography";
import M3Button from "../components/M3Button";
import { Link } from "react-router-dom";

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
      <div style={{ display: "flex", gap: "2rem" }}>
        <Account web3Modal={web3Modal} loadWeb3Modal={loadWeb3Modal} buttonVariant="filled" />
        <Link to="/hall">
          <M3Button variant="text" icon={<span className="material-icons">skip_next</span>}>
            Skip
          </M3Button>
        </Link>
      </div>
    </div>
  );
};

export default Connect;
