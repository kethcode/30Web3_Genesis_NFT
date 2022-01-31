const { ethers } = require("hardhat");
const { use, expect } = require("chai");
const { solidity } = require("ethereum-waffle");

const { MerkleTree } = require('merkletreejs');
const keccak256 = require('keccak256');

use(solidity);

describe("NFT30Web3", function () {
  let nftContract;

  let whitelist = [
    '0x9194eFdF03174a804f3552F4F7B7A4bB74BaDb7A',
    '0x9194eFdF03174a804f3552F4F7B7A4bB74BaDb7C',
    '0x9194eFdF03174a804f3552F4F7B7A4bB74BaDb7F',
    '0x9194eFdF03174a804f3552F4F7B7A4bB74BaDb8A',
  ];


  // quick fix to let gas reporter fetch data from gas station & coinmarketcap
  before((done) => {
    setTimeout(done, 2000);
  });

  describe("NFT30Web3", function () {
    it("Should deploy NFT30Web3", async function () {
      
      const [deployer] = await ethers.getSigners();
      
      const NFT30Web3 = await ethers.getContractFactory("NFT30Web3");
      nftContract = await NFT30Web3.deploy(
        deployer.address,
        "Genesis"
      );
      await nftContract.deployed();

      console.log("  NFT Deployed:", nftContract.address);
    });

    describe("Merkle Root", function () {
      it("Should be able to set and get a new merkle root", async function () {

        const leafNodes = whitelist.map(addr => keccak256(addr));
        const merkleTree =  new MerkleTree(leafNodes, keccak256, {sortPairs: true });
        const root = merkleTree.getRoot();

        await nftContract.setWhitelistRoot(root);
        const remoteRoot = await nftContract.getWhitelistRoot()
        expect(remoteRoot).to.equal(ethers.utils.hexlify(root));
      });

      it("Should be able to verify a correct address", async function () {

        const leafNodes = whitelist.map(addr => keccak256(addr));
        const merkleTree =  new MerkleTree(leafNodes, keccak256, {sortPairs: true });
        const root = merkleTree.getRoot();
        const leaf = keccak256(whitelist[2]);
        const proof = merkleTree.getHexProof(leaf);

        await nftContract.setWhitelistRoot(root);

        //MerkleProof.verify(_proof, _root, _leaf);
        const verifyResult = await nftContract.verify(proof, root, leaf);
        expect(verifyResult).to.be.true;
      });

      it("Should be able to reject an invalid address", async function () {

        const leafNodes = whitelist.map(addr => keccak256(addr));
        const merkleTree =  new MerkleTree(leafNodes, keccak256, {sortPairs: true });
        const root = merkleTree.getRoot();
        const leaf = keccak256('0x9194eFdF03174a804f3552F4F7B7A4bB74BaDb8B');
        const proof = merkleTree.getHexProof(leaf);

        await nftContract.setWhitelistRoot(root);

        //MerkleProof.verify(_proof, _root, _leaf);
        const verifyResult = await nftContract.verify(proof, root, leaf);
        expect(verifyResult).to.be.false;
      });


      it("Should mint with the correct address", async function () {

        const leafNodes = whitelist.map(addr => keccak256(addr));
        const merkleTree =  new MerkleTree(leafNodes, keccak256, {sortPairs: true });
        const root = merkleTree.getRoot();
        const leaf = keccak256(whitelist[2]);
        const proof = merkleTree.getHexProof(leaf);

        await nftContract.setWhitelistRoot(root);

        //MerkleProof.verify(_proof, _root, _leaf);
        await nftContract.mint(proof, root, leaf);

        const ownsResult = await nftContract.ownsNFT();
        expect(ownsResult).to.be.true;
      });


      /*it("Should emit a SetPurpose event ", async function () {
        const [owner] = await ethers.getSigners();

        const newPurpose = "Another Test Purpose";

        expect(await myContract.setPurpose(newPurpose)).to.
          emit(myContract, "SetPurpose").
            withArgs(owner.address, newPurpose);
      });*/
     });
  });
});
