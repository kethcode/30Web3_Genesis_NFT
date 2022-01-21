const hre = require("hardhat");

const delay = ms => new Promise(res => setTimeout(res, ms));

const main = async () => {
    
    const accounts = await ethers.getSigners();

    console.log("  Deployer:    ", accounts[0].address);

    const nftFactory = await hre.ethers.getContractFactory("NFT30Web3");
    const nftContract = await nftFactory.deploy();
    await nftContract.deployed();

    console.log("  NFT Deployed:", nftContract.address);

    console.log("Waiting for bytecode to propogate (120sec)");
    await delay(120000);

    console.log("Verifying on Etherscan");

    await hre.run("verify:verify", {
        address: nftContract.address,
      });

    console.log("Verified on Etherscan");

    await nftContract.mint();
    console.log("Minted Token 0");
};

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });