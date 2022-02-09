const { ethers } = require("hardhat");
const { BigNumber } = require("ethers");
const { use, expect } = require("chai");
const { solidity } = require("ethereum-waffle");


use(solidity);

describe("NFT30Web3", function () {
  let nftContract;

  // quick fix to let gas reporter fetch data from gas station & coinmarketcap
  before((done) => {
    setTimeout(done, 2000);
  });

  describe("NFT30Web3", function () {
    it("Should deploy NFT30Web3", async function () {
      
      const [deployer] = await ethers.getSigners();
      
      const NFT30Web3 = await ethers.getContractFactory("NFT30Web3");
      nftContract = await NFT30Web3.deploy(
        [
          '0x9194eFdF03174a804f3552F4F7B7A4bB74BaDb7F',
          '0xDD14ffFAeF2E6F4889c2EDD1418fc816AB48ac26',
          '0x63cab69189dBa2f1544a25c8C19b4309f415c8AA'
        ],
        "Genesis"
      );
      await nftContract.deployed();

      console.log("  NFT Deployed:", nftContract.address);
    });

    it("Should mint with the correct address", async function () {

      //MerkleProof.verify(_proof, _root, _leaf);
      await nftContract.mint('0x9194eFdF03174a804f3552F4F7B7A4bB74BaDb7F');

      const ownsResult = await nftContract.balanceOf('0x9194eFdF03174a804f3552F4F7B7A4bB74BaDb7F');
      expect(ownsResult).to.equal(BigNumber.from(1));
    });
  });
});
