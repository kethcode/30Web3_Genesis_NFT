import { useContractReader } from "eth-hooks";
import range from "lodash/range";
import NFT from "./NFT";

const AllAccountNFTs = ({ address, readContracts, ...props }) => {
  const balanceOf = useContractReader(readContracts, "NFT30Web3", "balanceOf", [address]);
  return (
    <ul
      style={{
        padding: "1rem",
        margin: 0,
        width: "100%",
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        gap: "2rem",
        overflow: "auto",
      }}
    >
      {range(balanceOf).map(index => (
        <NFT key={address + "-" + index} address={address} index={index} readContracts={readContracts} {...props} />
      ))}
    </ul>
  );
};

export default AllAccountNFTs;
