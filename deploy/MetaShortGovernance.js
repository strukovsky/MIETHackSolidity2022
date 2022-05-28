const { ethers } = require("hardhat");

module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy } = deployments;
    const { deployer } = await getNamedAccounts();
    const tokenDeployment = await deployments.get("MetaShort");
    const token = await ethers.getContractAt("MetaShort", tokenDeployment.address);
    const result=  await deploy("MetaShortGovernance", {
        from: deployer,
        args: [token.address],
        log: true
    });
    token.grantRole(await token.MINTER_ROLE(), result.address);
}

module.exports.tags = ["MetaShortGovernance"];
module.exports.dependencies = ["MetaShort"];
