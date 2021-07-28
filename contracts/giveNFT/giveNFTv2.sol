// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC721Tradable.sol";

/**
 * @title BPlaceholder
 * A sample placeholder NFT for testing purposes.
 */
contract giveNFTv2 is ERC721Tradable {
    constructor(address _proxyRegistryAddress)
        ERC721Tradable("giveNFTv2", "GVT2", _proxyRegistryAddress)
    {}

    function baseTokenURI() override public pure returns (string memory) {
        return "https://givenft-metadata-api.herokuapp.com/api/giveNFT/v2/";
    }

    function contractURI() public pure returns (string memory) {
        return "https://givenft-metadata-api.herokuapp.com/contract/giveNFT/v2/contract";
    }
}
