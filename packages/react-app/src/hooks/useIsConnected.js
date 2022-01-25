const useIsConnected = web3Modal => !!web3Modal && !!web3Modal.cachedProvider;

export default useIsConnected;
