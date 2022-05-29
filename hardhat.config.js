require("@nomiclabs/hardhat-waffle");
require("hardhat-deploy");
require("./tasks/setup");
// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
    const accounts = await hre.ethers.getSigners();

    for (const account of accounts) {
        console.log(account.address);
    }
});

const accounts = {
    mnemonic: `${process.env.MNEMONIC}`,
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
          blogger: 1,
          advertiser: 2
        },
      },
    networks: {
        ganache: {
            chainId: 1337,
            accounts,
            url: `http://localhost:8585`,
            live: true,
            saveDeployments: true,
        },
        bsctestnet: {
            chainId: 97,
            accounts,
            url: "https://data-seed-prebsc-1-s1.binance.org:8545/",
            live: true,
            saveDeployments: true,
        }
    }
};
