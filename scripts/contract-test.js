const API_URL = "https://polygon-mumbai.g.alchemy.com/v2/Nfq9kasfoYe8wbUKeAgXDPTi1VAROBZA";
//const API_URL = "https://polygon-mumbai.infura.io/v3/29b072a9431e43af95316d641b4f50d4";
const PUBLIC_KEY = process.env.PUBLIC_KEY;
const PRIVATE_KEY = process.env.PRIVATE_KEY;

const { createAlchemyWeb3 } = require("@alch/alchemy-web3");
const web3 = createAlchemyWeb3(API_URL);

const contract = require("../scripts/GIVEMarketplace.json");  
// const contract = require("../artifacts/contracts/HelloWorld.sol/HelloWorld.json"); // for Hardhat
const contractAddress = "0x6d3dB3eEA1eF3A6a891d91Ad33EC391c53F885E4";
const NFTMarketplaceContract = new web3.eth.Contract(contract.abi, contractAddress);

async function createNFT(assetId, tokenId, nftContract, numSales, royalties, assetOwner, creator) {
    const nonce = await web3.eth.getTransactionCount(PUBLIC_KEY, 'latest'); // get latest nonce
    //const gasEstimate = await NFTMarketplaceContract.methods.createAsset(assetId, tokenId, nftContract, numSales, royalties, assetOwner, creator).estimateGas(); // estimate gas

    // Create the transaction
    const tx = {
      'from': PUBLIC_KEY,
      'to': contractAddress,
      'nonce': nonce,
      'gas': 2000000, 
      'data': NFTMarketplaceContract.methods.createAsset(assetId, tokenId, nftContract, numSales, royalties, assetOwner, creator).encodeABI()
    };

    // Sign the transaction
    const signPromise = web3.eth.accounts.signTransaction(tx, PRIVATE_KEY);
    signPromise.then((signedTx) => {
      web3.eth.sendSignedTransaction(signedTx.rawTransaction, function(err, hash) {
        if (!err) {
          console.log("The hash of your transaction is: ", hash, "\n Check Alchemy's Mempool to view the status of your transaction!");
        } else {
          console.log("Something went wrong when submitting your transaction:", err)
        }
      });
    }).catch((err) => {
      console.log("Promise failed:", err);
    });
}

async function main() {
  one = web3.utils.toHex(1);
  passone = web3.utils.padRight(one, 32);
  console.log(passone);
  await createNFT(passone, 1, "0xF8e0B830B1d77c2920Cc029abB4081eECCD76F21", 0, 900, "0x11f408335E4B70459dF69390ab8948fcD51004D0", "0x11f408335E4B70459dF69390ab8948fcD51004D0");
}

main();