import { ethers } from "hardhat";
import {expect} from "chai";

describe("ERC20", function () {
    let admin: any;
    let account1: any;
    let ERC20Mock: any;

    before(async function () {
        [admin, account1] = await ethers.getSigners();
        const erc20ContractFactory = await ethers.getContractFactory("MyToken");
        ERC20Mock = await erc20ContractFactory.deploy();
        await ERC20Mock.deployed();
    });

    describe("Transfer 0 token", function () {
        it("Should not get bonus", async function () {
            await ERC20Mock.connect(account1).transfer(admin.address, ethers.utils.parseUnits("0"))
        });
    });
});