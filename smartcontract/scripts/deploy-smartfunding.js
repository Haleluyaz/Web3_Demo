// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");
const { ethers } = require("hardhat");
const { utils } = ethers;

async function main() {
  
  const APPToekn = await ethers.getContractFactory("APPToken");
  const tokenContract = await APPToekn.deploy();
  // await tokenContract.deplyTransaction.wait(6);
  await tokenContract.deployed();
  
  const SmartFundingContract = await ethers.getContractFactory("SmartFunding");
  const fundingContract = await SmartFundingContract.deploy(tokenContract.address, "0x02777053d6764996e594c3E88AF1D58D5363a2e6");
  // await fundingContract.deplyTransaction.wait(6);
  await fundingContract.deployed();
  const tx = await fundingContract.initialize(utils.parseEther("0.1"), 7);
  await tx.wait();

  console.log("APPToken deployed to:", tokenContract.address);
  console.log("SmartFunding deployed to:", fundingContract.address);

  try {
    await hre.run("verify:verify", {
       address: tokenContract.address,
       contract: "contracts/APPToken.sol:APPToken"
  });
  } catch {}

  try {
    await hre.run("verify:verify", {
       address: fundingContract.address,
       constructorArguments: [
            tokenContract.address, 
            "0x02777053d6764996e594c3E88AF1D58D5363a2e6"
       ]
  });
  } catch {}
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
