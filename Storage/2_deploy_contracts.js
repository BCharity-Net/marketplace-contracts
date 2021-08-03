const GIVEMarketplace = artifacts.require("./GIVEMarketplace.sol");
// const Community = artifacts.require("./MockCommunity.sol")

module.exports = async (deployer, network) => {
    //const mainnet = network.indexOf("main") > -1
    const mainnet = false;
    const datacoinAddress = mainnet ? "0x0cf0ee63788a0849fe5297f3407f701e122cc023" : "0x8e3877fe5551f9c14bc9b062bbae9d84bc2f5d4e"
    const NFTAddress = "0xF8e0B830B1d77c2920Cc029abB4081eECCD76F21";
    //const streamrUpdaterAddress = "0xb6aA9D2708475fB026a8052E20e63AeA23233613"
    const ownerAddress = mainnet ? "0x6926f20dD0e6cf785052705bB39c91816a753D238" : "0x6926f20dD0e6cf785052705bB39c91816a753D23"
    //there isn't a previous testnet marketplace
    const marketplaceAddress = mainnet ? "0xa10151d088f6f2705a05d6c83719e99e079a61c1": "0x0000000000000000000000000000000000000000"
    // await deployer.deploy(Marketplace, datacoinAddress, streamrUpdaterAddress, marketplaceAddress, { gas: 6700000 })
    // await deployer.deploy(Community, Marketplace.deployed().address, { gas: 6000000 })
    await deployer.deploy(GIVEMarketplace, datacoinAddress, NFTAddress, marketplaceAddress, {gas: 6700000})
    GIVEMarketplace.deployed().then(m => m.transferOwnership(ownerAddress, { gas: 400000 }))
}
