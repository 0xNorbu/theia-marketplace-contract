import { ethers } from "hardhat"
import {expect} from "chai"

describe("Scenario1", function () {
    let admin: any
    let account1: any
    let account2: any
    let BUSDContract: any
    let WGOLDContract: any
    let marketPlaceContract: any

    before(async function () {
        [admin, account1, account2] = await ethers.getSigners()
        const BUSDFactory = await ethers.getContractFactory("BUSD")
        const WGOLDFactory = await ethers.getContractFactory("WGOLD")
        const marketplaceFactory = await ethers.getContractFactory("Marketplace")

        BUSDContract = await BUSDFactory.deploy()
        WGOLDContract = await WGOLDFactory.deploy()
        marketPlaceContract = await marketplaceFactory.deploy(BUSDContract.address, WGOLDContract.address)

        await BUSDContract.deployed()
        await WGOLDContract.deployed()
        await marketPlaceContract.deployed()

        // mint 2 to account1
        await BUSDContract.connect(admin).mint(account1.address, ethers.utils.parseUnits("2"))
        // mint 3 to account2
        await BUSDContract.connect(admin).mint(account2.address, ethers.utils.parseUnits("3"))
    })

    describe("DepositToken1 - check if deposit address array registered correctly", function () {
        it("Should add correct address", async function () {
            // Approve 2 for account1
            await BUSDContract.connect(account1).approve(marketPlaceContract.address, ethers.utils.parseUnits("2"))
            // Account1 deposits 1 two times
            await marketPlaceContract.connect(account1).depositToken1(ethers.utils.parseUnits("1"))
            await marketPlaceContract.connect(account1).depositToken1(ethers.utils.parseUnits("1"))
            // Approve 3 for account2
            await BUSDContract.connect(account2).approve(marketPlaceContract.address, ethers.utils.parseUnits("3"))
            // Account2 deposits 1 three times
            await marketPlaceContract.connect(account2).depositToken1(ethers.utils.parseUnits("1"))
            await marketPlaceContract.connect(account2).depositToken1(ethers.utils.parseUnits("1"))
            await marketPlaceContract.connect(account2).depositToken1(ethers.utils.parseUnits("1"))

            const addressArrayLength = await marketPlaceContract.getRegisterAddressArrayLength()
            expect(addressArrayLength).to.equal(2)
        })
    })
})