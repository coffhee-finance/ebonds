import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

const config: HardhatUserConfig = {
  solidity: "0.8.25",

  networks: {
    hardhat: {},

    arbitrumSepolia: {
      url: "https://sepolia-rollup.arbitrum.io/rpc",
      accounts: [
        ""
      ],
      chainId: 421614,
    },

    robinhoodTestnet: {
      url: "https://rpc.testnet.chain.robinhood.com",
      accounts: [
        ""
      ],
      chainId: 46630,
    },
  },
};

export default config;