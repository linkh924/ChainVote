require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config({path: require("path").resolve(__dirname, '../.env')});

module.exports = {
    solidity: "0.8.19",
    networks: {
        sepolia: {
            url: process.env.ALCHEMY_RPC_URL || "https://rpc2.sepolia.org",
            accounts: [process.env.PRIVATE_KEY],
            timeout: 60000
        }
    },
    etherscan: {
        apiKey: process.env.ETHERSCAN_API_KEY
    }
};