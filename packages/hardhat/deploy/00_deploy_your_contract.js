// deploy/00_deploy_your_contract.js

const delay = ms => new Promise(res => setTimeout(res, ms));

const { ethers } = require("hardhat");
const localChainId = "31337";

module.exports = async ({ getNamedAccounts, deployments, getChainId }) => {
  
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  const chainId = await getChainId();
  
  await deploy("NFT30Web3", {
    // Learn more about args here: https://www.npmjs.com/package/hardhat-deploy#deploymentsdeploy
    from: deployer,
    // args: [ "Hello", ethers.utils.parseEther("1.5") ],
    args:   
      [
        [
        '0x9194eFdF03174a804f3552F4F7B7A4bB74BaDb7F',
        '0xDD14ffFAeF2E6F4889c2EDD1418fc816AB48ac26',
        '0x63cab69189dBa2f1544a25c8C19b4309f415c8AA'
        ],
        "Genesis"
      ],
    log: true,
    waitConfirmations: 5,
  });

  // Getting a previously deployed contract
  const nftContract = await ethers.getContract("NFT30Web3", deployer);

  console.log("Deployed:", nftContract.address);
  console.log("Deployer:", deployer);

  console.log("Waiting for bytecode to propogate (150sec)");
  await delay(150000);

  console.log("Verifying on Etherscan");

  await hre.run("verify:verify", {
      address: nftContract.address,
      constructorArguments: 
      [
        [
          '0x9194eFdF03174a804f3552F4F7B7A4bB74BaDb7F',
          '0xDD14ffFAeF2E6F4889c2EDD1418fc816AB48ac26',
          '0x63cab69189dBa2f1544a25c8C19b4309f415c8AA'
        ],
        "Genesis"
      ]
    });

  console.log("Verified on Etherscan");


  /*  await YourContract.setPurpose("Hello");
  
    To take ownership of yourContract using the ownable library uncomment next line and add the 
    address you want to be the owner. 
    // await yourContract.transferOwnership(YOUR_ADDRESS_HERE);

    //const yourContract = await ethers.getContractAt('YourContract', "0xaAC799eC2d00C013f1F11c37E654e59B0429DF6A") //<-- if you want to instantiate a version of a contract at a specific address!
  */

  /*
  //If you want to send value to an address from the deployer
  const deployerWallet = ethers.provider.getSigner()
  await deployerWallet.sendTransaction({
    to: "0x34aA3F359A9D614239015126635CE7732c18fDF3",
    value: ethers.utils.parseEther("0.001")
  })
  */

  /*
  //If you want to send some ETH to a contract on deploy (make your constructor payable!)
  const yourContract = await deploy("YourContract", [], {
  value: ethers.utils.parseEther("0.05")
  });
  */

  /*
  //If you want to link a library into your contract:
  // reference: https://github.com/austintgriffith/scaffold-eth/blob/using-libraries-example/packages/hardhat/scripts/deploy.js#L19
  const yourContract = await deploy("YourContract", [], {}, {
   LibraryName: **LibraryAddress**
  });
  */

  // Verify from the command line by running `yarn verify`

  // You can also Verify your contracts with Etherscan here...
  // You don't want to verify on localhost
  // try {
  //   if (chainId !== localChainId) {
  //     await run("verify:verify", {
  //       address: YourContract.address,
  //       contract: "contracts/YourContract.sol:YourContract",
  //       contractArguments: [],
  //     });
  //   }
  // } catch (error) {
  //   console.error(error);
  // }
};
module.exports.tags = ["NFT30Web3"];
