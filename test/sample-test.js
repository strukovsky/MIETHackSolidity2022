const { expect } = require("chai");
const { ethers } = require("hardhat");
const { setTimeout } = require("timers/promises");


describe("MetaShortGovernance", function () {

    before(async function() {
        const signers = await ethers.getSigners();
        this.deployer = signers[0];
        this.blogger = signers[1];
        this.advertiser = signers[2];
        
        const MetaShort = await ethers.getContractFactory("MetaShort");
        const MetaShortGovernance = await ethers.getContractFactory("MetaShortGovernance");

        this.token = await MetaShort.deploy();
        this.governance = await MetaShortGovernance.deploy(this.token.address);
        this.token.grantRole(this.token.MINTER_ROLE(), this.governance.address);


        await this.governance.registerAdvertiser(this.advertiser.address);
        this.token.mint(this.advertiser.address, 10000000000);
        this.token.connect(this.advertiser).approve(this.governance.address, 10000000000);
       
        this.initialBalanceOfBlogger = 10000000000;
        await this.governance.registerBlogger(this.blogger.address);
        await this.token.mint(this.blogger.address,  this.initialBalanceOfBlogger);
        this.token.connect(this.blogger).approve(this.governance.address,  this.initialBalanceOfBlogger);
    })

    it("Should perform a publishing of advertisement", async function () {
       
        const desiredReactions = 10;
        const desiredComments = 10;
        const thresholdReactions = 5;
        const thresholdComments = 5;
        const tips = 100;
        // This advertisement is exposed only for 5 seconds
        const until = Math.round(new Date().getTime() / 1000) + 5;
        const totalCalculatedPrice = desiredComments * 50 + desiredReactions * 10 + tips;

        await expect(this.governance.connect(this.advertiser).publishAdvertisement(
            desiredReactions,
            desiredComments,
            thresholdReactions,
            thresholdComments,
            until,
            tips
        )).to.emit(this.governance, "AdvertisementPublished").withArgs(
            1,
            desiredReactions,
            desiredComments,
            thresholdReactions,
            thresholdComments,
            until,
            tips,
            totalCalculatedPrice,
            this.advertiser.address
        );
    });

    it("should perform a submit for advertisement", async function(){
        await this.governance.connect(this.blogger).submitAdvertisement(1);
    });

    it("should perform adding activities", async function(){
        await this.governance.sendActivity(1, 10, 10);
    });

    it("should finish advertisement ", async function(){
        const waitForFinish = async () => {
            await setTimeout(5000);

            await this.governance.connect(this.blogger).requireRewardForAdvertisement(1);
            const tips = 100;
            expect(await this.token.balanceOf(this.blogger.address)).to.be.eq(this.initialBalanceOfBlogger + tips);   
        }
    });
});
