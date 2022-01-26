import { useEventListener } from "eth-hooks/events/useEventListener";

const useGetNftId = (address, readContracts, localProvider) => {
  const events = useEventListener(readContracts, "NFT30Web3", "Transfer", localProvider, 1);
  const idAsHex = events.find(item => item.args[1] === address)?.args[2]._hex;
  const id = parseInt(idAsHex);
  return id;
};

export default useGetNftId;
