const { Contract } = require("ethers");

const delay = ms => new Promise(res => setTimeout(res, ms));

const main = async () => {
    
    const [deployer] = await ethers.getSigners();

    const nftContract = Contract(0x1d419010ffea6f5477eba72d5ff7d3a66a4b7e08, NFT30Web3.interface, deployer)
    console.log("  NFT Deployed:", nftContract.address);

    console.log("Verifying on Etherscan");

    await hre.run("verify:verify", {
        address: nftContract.address,
      });

    console.log("Verified on Etherscan");

    await nftContract.mint();
    //await nftContract.tokenURI(0);

    console.log("Minted Token 0");
};

const runMain = async () => {
    try {
        await main();
        process.exit(0);
    } catch (error) {
        console.log(error);
        process.exit(1);
    }
};

runMain();