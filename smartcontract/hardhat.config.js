require("@nomicfoundation/hardhat-toolbox");
require("@nomicfoundation/hardhat-chai-matchers");
require("@nomiclabs/hardhat-waffle");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  
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
