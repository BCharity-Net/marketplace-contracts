const HDWalletProvider = require('@truffle/hdwallet-provider');
const fs = require('fs');
const MNEMONIC = process.env.MNEMONIC;

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
		  provider: () => new HDWalletProvider(MNEMONIC, `https://rpc-mumbai.matic.today`),
		  network_id: 80001,
		  confirmations: 2,
		  timeoutBlocks: 200,
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
					enabled: true,
					runs: 200
				},
				evmVersion: "istanbul" 
			}
		}
	}

}
