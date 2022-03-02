import { ethers } from "hardhat"
import {expect} from "chai"

describe("Swap PUSDG for USDC", function () {
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

        await usdcContract.connect(admin).mint(marketPlaceContract.address, ethers.utils.parseUnits("1000"))
        await pusdgContract.connect(admin).mint(account1.address, ethers.utils.parseUnits("1000"))
        await pusdgContract.connect(admin).setMinter(marketPlaceContract.address)
        await pusdgContract.connect(admin).setBurner(marketPlaceContract.address)
    })

    describe("Swap PUSDG for USDC", function () {
        it("Swap PUSDG for USDC", async function () {
            // Before
            {
                // Account 1
                let account1PUSDGBalance = await pusdgContract.balanceOf(account1.address)
                expect(account1PUSDGBalance).to.equal(ethers.utils.parseUnits("1000"));

                let account1USDCBalance = await usdcContract.balanceOf(account1.address)
                expect(account1USDCBalance).to.equal(0);

                // Marketplace
                let marketPlacePUSDGBalance = await pusdgContract.balanceOf(marketPlaceContract.address)
                expect(marketPlacePUSDGBalance).to.equal(0);

                let marketPlaceUSDCBalance = await usdcContract.balanceOf(marketPlaceContract.address)
                expect(marketPlaceUSDCBalance).to.equal(ethers.utils.parseUnits("1000"));
            }

            await marketPlaceContract.connect(account1).swapPUSDGForUSDC(ethers.utils.parseUnits("1000"))

            // After
            {
                // Account 1
                let account1USDCBalance = await usdcContract.balanceOf(account1.address)
                expect(account1USDCBalance).to.equal(ethers.utils.parseUnits("1000"));

                let account1PUSDGBalance = await pusdgContract.balanceOf(account1.address)
                expect(account1PUSDGBalance).to.equal(0);

                // Marketplace
                let marketPlaceUSDCBalance = await usdcContract.balanceOf(marketPlaceContract.address)
                expect(marketPlaceUSDCBalance).to.equal(0);

                let marketPlacePUSDGBalance = await pusdgContract.balanceOf(marketPlaceContract.address)
                expect(marketPlacePUSDGBalance).to.equal(0);
            }
        })
    })
})