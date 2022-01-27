import { useEventListener } from "eth-hooks/events/useEventListener";

const useGetTransferEvents = (readContracts, localProvider) =>
  useEventListener(readContracts, "NFT30Web3", "Transfer", localProvider, 1);

export default useGetTransferEvents;
