require("@nomicfoundation/hardhat-toolbox");
require('@nomicfoundation/hardhat-verify');

const AMOY_ENDPOINT = "https://polygon-amoy.g.alchemy.com/v2/_3UvND3xyxsHKYHV_zZ6MCJCYMsPiUSP"
const PRIVATE_KEY = "AQUÍ TU CLAVE PRIVADA PARA TESNET"
const POLYGONSACN_APIKEY = "AQUÍ TU API KEY"

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.28",
  networks:{
      amoy:{
        url: AMOY_ENDPOINT,
        accounts: [PRIVATE_KEY]
      },
  },
  etherscan: {
    apiKey: POLYGONSACN_APIKEY
  }
};
