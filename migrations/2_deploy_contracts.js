const GIVEMarketplace = artifacts.require("./GIVEMarketplace.sol");
// const Community = artifacts.require("./MockCommunity.sol")

module.exports = async (deployer, network) => {
    //const mainnet = network.indexOf("main") > -1
    const mainnet = false;
    const datacoinAddress = mainnet ? "0x0000000000000000000000000000000000000000" : "0x0000000000000000000000000000000000000000"
    const NFTAddress = "0x0000000000000000000000000000000000000000";
    //const streamrUpdaterAddress = "0xb6aA9D2708475fB026a8052E20e63AeA23233613"
    const ownerAddress = mainnet ? "0x0614d227dbcfc33f4f0918b7bd14fdf3a5f8b4ba" : "0x0614d227dbcfc33f4f0918b7bd14fdf3a5f8b4ba"
    //there isn't a previous testnet marketplace
    const marketplaceAddress = mainnet ? "0x0000000000000000000000000000000000000000": "0x0000000000000000000000000000000000000000"
    // await deployer.deploy(Marketplace, datacoinAddress, streamrUpdaterAddress, marketplaceAddress, { gas: 6700000 })
    // await deployer.deploy(Community, Marketplace.deployed().address, { gas: 6000000 })
    await deployer.deploy(GIVEMarketplace, datacoinAddress, marketplaceAddress, {gas: 6700000})
    GIVEMarketplace.deployed().then(m => m.transferOwnership(ownerAddress, { gas: 400000 }))
}
