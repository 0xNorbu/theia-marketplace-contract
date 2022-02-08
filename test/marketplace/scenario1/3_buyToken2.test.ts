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

        // mint 1 to account1
        await BUSDContract.connect(admin).mint(account1.address, ethers.utils.parseUnits("1"))

        // Deposit
        {
            await BUSDContract.connect(account1).approve(marketPlaceContract.address, ethers.utils.parseUnits("1"))
            await marketPlaceContract.connect(account1).depositToken1(ethers.utils.parseUnits("1"))
            let account1Balance = await marketPlaceContract.token1Balance(account1.address)
            expect(account1Balance).to.equal(ethers.utils.parseUnits("1"))
        }
    })

    describe("BuyToken2", function () {
        it("Should buy", async function () {
            {
                const scenario1Lock1 = await marketPlaceContract.scenario1Lock(account1.address)
                expect(scenario1Lock1).to.equal(false)
            }

            await marketPlaceContract.connect(account1).buyToken2()

            {
                const scenario1Lock1 = await marketPlaceContract.scenario1Lock(account1.address)
                expect(scenario1Lock1).to.equal(true)
            }
        })

        it("Should not buy if there is no deposit", async function () {
            await expect(
                marketPlaceContract.connect(account2).buyToken2()
            ).to.be.revertedWith("There is not enough token1 balance");
        })
    })
})