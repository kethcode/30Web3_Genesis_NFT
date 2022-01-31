const { MerkleTree } = require('merkletreejs');
const keccak256 = require('keccak256');

const fs = require("fs");

// import { whitelist } from "../../react-app/src/assets/whitelist.js";
// const whitelist = require("../../react-app/src/assets/whitelist.js")

const main = async () => {

    let buf = fs.readFileSync("../react-app/src/assets/whitelist.js").toString().split("[")[1].split("]")[0].toString();
    let whitelist = buf.replace(/"/g, '').replace(/,/g, '').trim().split("\n");

    for(let i = 0; i < whitelist.length; i++) {
        whitelist[i] = whitelist[i].trim();
    }
    
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