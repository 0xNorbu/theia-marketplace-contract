import { ethers } from "hardhat"
import {expect} from "chai"

describe("Swap PUSDG for USDG", function () {
    let admin: any
    let account1: any
    let usdcContract: any
    let usdgContract: any
    let pusdgContract: any
    let marketPlaceContract: any

    before(async function () {
        [admin, account1] = await ethers.getSigners()
        const usdcFactory = await ethers.getContractFactory("USDC")
        const usdgFactory = await ethers.getContractFactory("USDG")
        const pusdgFactory = await ethers.getContractFactory("PUSDG")
        const marketplaceFactory = await ethers.getContractFactory("Marketplace")

        usdcContract = await usdcFactory.deploy()
        usdgContract = await usdgFactory.deploy()
        pusdgContract = await pusdgFactory.deploy()
        marketPlaceContract = await marketplaceFactory.deploy(
            usdcContract.address,
            usdgContract.address,
            pusdgContract.address
        )

        await usdcContract.deployed()
        await usdgContract.deployed()
        await pusdgContract.deployed()
        await marketPlaceContract.deployed()

        await pusdgContract.connect(admin).setMinter(marketPlaceContract.address)
        await pusdgContract.connect(admin).setBurner(marketPlaceContract.address)
        await usdgContract.connect(admin).setMinter(marketPlaceContract.address)
        await usdgContract.connect(admin).setBurner(marketPlaceContract.address)

        await pusdgContract.connect(admin).mint(account1.address, ethers.utils.parseUnits("1000"))
    })

    describe("Swap PUSDG for USDG", function () {
        it("Swap PUSDG for USDG", async function () {
            // Before
            {
                // Account 1
                let account1PUSDGBalance = await pusdgContract.balanceOf(account1.address)
                expect(account1PUSDGBalance).to.equal(ethers.utils.parseUnits("1000"));

                let account1USDGBalance = await usdgContract.balanceOf(account1.address)
                expect(account1USDGBalance).to.equal(0);

                // Marketplace
                let marketPlacePUSDBalance = await pusdgContract.balanceOf(marketPlaceContract.address)
                expect(marketPlacePUSDBalance).to.equal(0);

                let marketPlaceUSDGBalance = await usdgContract.balanceOf(marketPlaceContract.address)
                expect(marketPlaceUSDGBalance).to.equal(0);
            }

            await pusdgContract.connect(account1).approve(marketPlaceContract.address, ethers.utils.parseUnits("1000"))
            await marketPlaceContract.connect(account1).swapPUSDGForUSDG(ethers.utils.parseUnits("1000"))

            // After
            {
                // Account 1
                let account1PUSDGBalance = await pusdgContract.balanceOf(account1.address)
                expect(account1PUSDGBalance).to.equal(0);

                let account1USDGBalance = await usdgContract.balanceOf(account1.address)
                expect(account1USDGBalance).to.equal(ethers.utils.parseUnits("1000"));

                // Marketplace
                let marketPlacePUSDBalance = await pusdgContract.balanceOf(marketPlaceContract.address)
                expect(marketPlacePUSDBalance).to.equal(0);

                let marketPlaceUSDGBalance = await usdgContract.balanceOf(marketPlaceContract.address)
                expect(marketPlaceUSDGBalance).to.equal(0);
            }
        })
    })
})