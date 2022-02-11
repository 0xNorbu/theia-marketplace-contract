import {ethers, network} from "hardhat"
import {expect} from "chai"

describe("Masterchef", function () {
    let admin: any
    let dev: any
    let account1: any
    let account2: any
    let WPAXGContract: any
    let USDGContract: any
    let SUSDGContract: any
    let masterChefContract: any

    before(async function () {
        [admin, dev, account1, account2] = await ethers.getSigners()
        const WPAXGFactory = await ethers.getContractFactory("WPAXG")
        const USDGFactory = await ethers.getContractFactory("USDG")
        const SUSDGFactory = await ethers.getContractFactory("SUSDG")
        const masterChefFactory = await ethers.getContractFactory("MasterChef")

        WPAXGContract = await WPAXGFactory.deploy()
        USDGContract = await USDGFactory.deploy()
        SUSDGContract = await SUSDGFactory.deploy()
        masterChefContract = await masterChefFactory.deploy(
            USDGContract.address,
            SUSDGContract.address,
            dev.address,
            1, // Cake per block
            1  // start block
        )
        await USDGContract.connect(admin).setMinter(masterChefContract.address)
        await SUSDGContract.connect(admin).setMinter(masterChefContract.address)

        await masterChefContract.connect(admin).add(1000, WPAXGContract.address, true)

        // Mint 1000 WPAXG
        await WPAXGContract.connect(admin).mint(account1.address, ethers.utils.parseUnits("1500"))
        // Approve masterchef to move account1 balance
        await WPAXGContract.connect(account1).approve(masterChefContract.address, ethers.utils.parseUnits("1500"))

        // Check balance of account1 before deposit
        {
            const balanceOfAccount1 = await WPAXGContract.balanceOf(account1.address)
            expect(balanceOfAccount1).to.equal(ethers.utils.parseUnits("1500"))
        }

        // Account1 deposit
        await masterChefContract.connect(account1).deposit(1, ethers.utils.parseUnits("1000"))
        // Account1 staking
        await masterChefContract.connect(account1).enterStaking(ethers.utils.parseUnits("500"))

        const now = Date.now();
        await network.provider.send("evm_setNextBlockTimestamp", [now + 100]);

        // // Check balance of account1 after deposit
        // {
        //     const balanceOfAccount1 = await WPAXGContract.balanceOf(account1.address)
        //     expect(balanceOfAccount1).to.equal(0)
        // }

        //await masterChefContract.connect(account1).withdraw(1, ethers.utils.parseUnits("1000"))

        // Check balance of account1 after withdrawal
        // {
        //     const balanceOfAccount1 = await WPAXGContract.balanceOf(account1.address)
        //     expect(balanceOfAccount1).to.equal(ethers.utils.parseUnits("1000"))
        // }

        // await this.chef.deposit(1, '20', { from: alice });
        // await this.chef.withdraw(1, '20', { from: alice });
        // assert.equal((await this.cake.balanceOf(alice)).toString(), '263');
    })

    describe("DepositToken1", function () {
        it("Should deposit", async function () {
            // const blockNumAfter = await ethers.provider.getBlockNumber();
            // console.log(blockNumAfter)
        })
    })
});
