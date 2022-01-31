const { MerkleTree } = require('merkletreejs');
const keccak256 = require('keccak256');

const fs = require("fs");

//import { whitelist } from "../assets/whitelist.js";

const main = async () => {

    let whitelist = fs.readFileSync("./assets/whitelist.js").toString().split("\n");
    console.log(whitelist);

    const leafNodes = whitelist.map(addr => keccak256(addr));
    const merkleTree =  new MerkleTree(leafNodes, keccak256, {sortPairs: true });
    
    const root = merkleTree.getRoot();
    console.log('root:\n', root);
    
    //console.log('Whitelist Merkle Tree:\n', merkleTree.toString());

    const leaf = keccak256(whitelist[4]);
    const proof = merkleTree.getHexProof(leaf);

    console.log('addr:\n',whitelist[4]);
    console.log('leaf:\n', leaf);
    console.log('proof:\n', proof);

    // const verified = merkleTree.verify(proof, leaf, root);

    // console.log('verified:\n', verified);
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