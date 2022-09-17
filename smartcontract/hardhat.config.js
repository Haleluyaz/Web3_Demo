require("dotenv").config();
require("@nomicfoundation/hardhat-toolbox");
require("@nomicfoundation/hardhat-chai-matchers");
// require("@nomiclabs/hardhat-ethers");

const { ETHERSCAN_API_KEY, PRIVATE_KEY, GOERLI_URL } = process.env;

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  version: "0.8.17",
  etherscan: {
    apiKey: ETHERSCAN_API_KEY,
  },

  networks: {
    goerli: {
      url: GOERLI_URL || "",
      accounts:
        PRIVATE_KEY !== undefined ? [PRIVATE_KEY] : [],
    }
  },

  solidity: {
      version: "0.8.17",
      settings: {
        outputSelection: {
          "*": {
            "*": ["storageLayout"]
          }
        }
      }
    }
};
