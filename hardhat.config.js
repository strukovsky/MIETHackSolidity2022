require("@nomiclabs/hardhat-waffle");
require("hardhat-deploy");

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
    const accounts = await hre.ethers.getSigners();

    for (const account of accounts) {
        console.log(account.address);
    }
});

const accounts = {
    mnemonic: `test test test test test test test test test test test waste`,
  };

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
    solidity: "0.8.4",
    namedAccounts: {
        deployer: {
          default: 0,
        },
      },
    networks: {
        bsctestnet: {
            chainId: 97,
            accounts,
            url: `https://data-seed-prebsc-1-s2.binance.org:8545/`,
            live: true,
            saveDeployments: true,
        },
    }
};
