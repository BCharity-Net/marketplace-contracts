const HDWalletProvider = require('@truffle/hdwallet-provider');
const fs = require('fs');
const MNEMONIC = process.env.MNEMONIC;
//const MNEMONIC = "stone amateur entire forum turtle sniff core among soccer glimpse lava napkin";

module.exports = {
	// See <http://truffleframework.com/docs/advanced/configuration>
	// to customize your Truffle configuration!

	networks: {
		development: {
		  host: "127.0.0.1",     // Localhost (default: none)
		  port: 8545,            // Standard Ethereum port (default: none)
		  network_id: "*",       // Any network (default: none)
		},
		mumbai: {
		  provider: () => new HDWalletProvider(MNEMONIC, `https://polygon-mumbai.g.alchemy.com/v2/Nfq9kasfoYe8wbUKeAgXDPTi1VAROBZA`),
		  //provider: () => new HDWalletProvider(MNEMONIC, `https://polygon-mumbai.infura.io/v3/29b072a9431e43af95316d641b4f50d4`),
		  network_id: 80001,
		  confirmations: 2,
		  //networkCheckTimeout: 10000000,
		  //timeoutBlocks: 400,
		  skipDryRun: true
		},
	  },
	
	  // Set default mocha options here, use special reporters etc.
	  mocha: {
		// timeout: 100000
	  },

	compilers: {
		solc: {
			version: "0.8.6",
			settings: {
				optimizer: {
					enabled: false,
					runs: 200
				},
				evmVersion: "istanbul" 
			}
		}
	}

}
