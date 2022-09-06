const { expect } = require("chai");
const { ethers } = require("hardhat");
const { utils } = ethers;

describe("Deploy smart funding contract", function () {
    it("Should deploy smartfunding", async function() {
        const [owner] = await ethers.getSigners();
        const APPToken = await ethers.getContractFactory("APPToken");
        const tokenContract = await APPToken.deploy();
        await tokenContract.deployed();

        const SmartFundingContract = await ethers.getContractFactory("SmartFunding");
        const fundingContract = await SmartFundingContract.deploy(tokenContract.address);
        await fundingContract.deployed();
        
        // check correct address
        expect(await fundingContract.tokenAddress()).to.equal(tokenContract.address);
        // check correct supply
        expect(await tokenContract.totalSupply()).to.equal(utils.parseUnits("1000000", 18));
        // check owner address have correct token
        expect(await tokenContract.balanceOf(owner.address)).to.equal(utils.parseUnits("1000000", 18));
        
        // check correct token after transfer
        await tokenContract.connect(owner).transfer(fundingContract.address, utils.parseUnits("1000000", 18));
        expect(await tokenContract.balanceOf(owner.address)).to.equal(utils.parseUnits("0", 18));
        expect(await tokenContract.balanceOf(fundingContract.address)).to.equal(utils.parseUnits("1000000", 18));
    })
})