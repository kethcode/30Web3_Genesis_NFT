const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("SVG & NFT", function () {

    it("Should Deploy", async function () {

        let accounts = await ethers.getSigners()

        const svgFactory = await hre.ethers.getContractFactory("SVG");
        const svgContract = await svgFactory.deploy();
        await svgContract.deployed();
    
        console.log("  SVG Deployed:", svgContract.address);

        const nftFactory = await hre.ethers.getContractFactory("NFT", {
            libraries: {
                SVG: svgContract.address
            }
        });
        const nftContract = await nftFactory.deploy();
        await nftContract.deployed();
    
        console.log("  NFT Deployed:", nftContract.address);

        // let overrides = {
        //     value: ethers.utils.parseEther("0.01")
        //   };

        // await nftContract.mint(overrides);
        // await nftContract.tokenURI(0);
    });
});