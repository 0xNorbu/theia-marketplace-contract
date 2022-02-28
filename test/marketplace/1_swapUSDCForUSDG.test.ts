import { ethers } from "hardhat"
import {expect} from "chai"

describe("Swap USDC for USDG", function () {
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

        await usdcContract.connect(admin).mint(account1.address, ethers.utils.parseUnits("1000"))
        await usdgContract.connect(admin).setMinter(marketPlaceContract.address)
        await usdgContract.connect(admin).setBurner(marketPlaceContract.address)
    })

    describe("Swap USDC for USDG", function () {
        it("Should swap USDC for USDG", async function () {
            // Before
            {
                // Account 1
                let account1USDCBalance = await usdcContract.balanceOf(account1.address)
                expect(account1USDCBalance).to.equal(ethers.utils.parseUnits("1000"));

                let account1USDGBalance = await usdgContract.balanceOf(account1.address)
                expect(account1USDGBalance).to.equal(0);

                // Marketplace
                let marketPlaceUSDCBalance = await usdcContract.balanceOf(marketPlaceContract.address)
                expect(marketPlaceUSDCBalance).to.equal(0);

                let marketPlaceUSDGBalance = await usdgContract.balanceOf(marketPlaceContract.address)
                expect(marketPlaceUSDGBalance).to.equal(0);
            }

            await usdcContract.connect(account1).approve(marketPlaceContract.address, ethers.utils.parseUnits("1000"))
            await marketPlaceContract.connect(account1).swapUSDCForUSDG(ethers.utils.parseUnits("1000"))

            // After
            {
                // Account 1
                let account1USDCBalance = await usdcContract.balanceOf(account1.address)
                expect(account1USDCBalance).to.equal(0);

                let account1USDGBalance = await usdgContract.balanceOf(account1.address)
                expect(account1USDGBalance).to.equal(ethers.utils.parseUnits("1000"));

                // Marketplace
                let marketPlaceUSDCBalance = await usdcContract.balanceOf(marketPlaceContract.address)
                expect(marketPlaceUSDCBalance).to.equal(ethers.utils.parseUnits("1000"));

                let marketPlaceUSDGBalance = await usdgContract.balanceOf(marketPlaceContract.address)
                expect(marketPlaceUSDGBalance).to.equal(0);
            }
        })
    })
})