const { task } = require('hardhat/config');

task('setup', 'Setup advertisement')
    .setAction(async (taskArgs, hre) => {
        const signers = await hre.ethers.getSigners();
        const deployer = signers[0];
        const blogger = signers[1];
        const advertiser = signers[2];
        console.log(`Accounts:\ndeployer: ${deployer.address}\nblogger: ${blogger.address}\nadvertiser: ${advertiser.address}`)
        const governance = await hre.ethers.getContractAt("MetaShortGovernance", "0x32713e409Dc17b44E831c09a3A33173FeC6eF57b");
        const token = await hre.ethers.getContractAt("MetaShort", "0xa209136dEA7BBB8cE08c04A187c0972F551E87B1");
        const desiredReactions = 10;
        const desiredComments = 10;
        const thresholdReactions = 10;
        const thresholdComments = 10;
        const until = Math.round(new Date().getTime() / 1000) + 24 * 3600
        const tips = 1000;
        console.log(`Configuring for blogger ${blogger.address}`);
        await governance.connect(deployer).registerBlogger(blogger.address);
        await token.mint(blogger.address, 1);
        await token.connect(blogger).approve(governance.address, 10000000);

        console.log(`Configuring for advertiser ${advertiser.address}`);
        await governance.connect(deployer).registerAdvertiser(advertiser.address);
        await token.connect(deployer).mint(advertiser.address, 10000000);
        await token.connect(advertiser).approve(governance.address, 10000000);

        console.log("Publish advertisement");
        await governance.connect(advertiser).publishAdvertisement(desiredReactions, desiredComments, thresholdReactions, thresholdComments, until, tips);
        console.log("Submit advertisement");
        await governance.connect(blogger).submitAdvertisement(1);
    });