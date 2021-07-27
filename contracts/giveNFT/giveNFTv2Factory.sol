// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "openzeppelin-solidity/contracts/access/Ownable.sol";
import "openzeppelin-solidity/contracts/utils/Strings.sol";
import "./IFactoryERC721.sol";

//Import new nft
import "./giveNFTv2.sol";


contract giveNFTv2Factory is FactoryERC721, Ownable {
    using Strings for string;

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );

    address public proxyRegistryAddress;
    address public nftAddress;
    //address public lootBoxNftAddress;
    string public baseURI = "https://givenft-metadata-api.herokuapp.com/api/giveNFT/factory/";

    /*
     * Enforce the existence of only 100 OpenSea creatures.
     */
    //uint256 SUPPLY = 100;

    /*
     * Three different options for minting Creatures (basic, premium, and gold).
     */
    uint256 NUM_OPTIONS = 2;
    uint256 SINGLE_OPTION = 0;
    uint256 MULTIPLE_OPTION = 1;
    uint256 NUM_IN_MULTIPLE_OPTION = 4;

    constructor(address _proxyRegistryAddress, address _nftAddress) {
        proxyRegistryAddress = _proxyRegistryAddress;
        nftAddress = _nftAddress;
	/*
        lootBoxNftAddress = address(
            new CreatureLootBox(_proxyRegistryAddress, address(this))
        );
	*/

        fireTransferEvents(address(0), owner());
    }

    function name() override external pure returns (string memory) {
        return "giveNFT Item Sale";
    }

    function symbol() override external pure returns (string memory) {
        return "GVTF";
    }

    function supportsFactoryInterface() override public pure returns (bool) {
        return true;
    }

    function numOptions() override public view returns (uint256) {
        return NUM_OPTIONS;
    }

    function transferOwnership(address newOwner) override public onlyOwner {
        address _prevOwner = owner();
        super.transferOwnership(newOwner);
        fireTransferEvents(_prevOwner, newOwner);
    }

    function fireTransferEvents(address _from, address _to) private {
        for (uint256 i = 0; i < NUM_OPTIONS; i++) {
            emit Transfer(_from, _to, i);
        }
    }

    function mint(uint256 _optionId, address _toAddress) override public {
	require(
            address(0x58807baD0B376efc12F5AD86aAc70E78ed67deaE) == _msgSender() ||
                owner() == _msgSender() 
        );

        require(canMint(_optionId));

        giveNFTv2 giveTokenv2 = giveNFTv2(nftAddress);
        if (_optionId == SINGLE_OPTION) {
            giveTokenv2.mintTo(_toAddress);
        } 
	else if (_optionId == MULTIPLE_OPTION) {
            for (
                uint256 i = 0;
                i < NUM_IN_MULTIPLE_OPTION;
                i++
            ) {
                giveTokenv2.mintTo(_toAddress);
            }
        }
    }

    function canMint(uint256 _optionId) override public view returns (bool) {
        if (_optionId >= NUM_OPTIONS) {
            return false;
        }

	return true;
    }

    function tokenURI(uint256 _optionId) override external view returns (string memory) {
        return string(abi.encodePacked(baseURI, Strings.toString(_optionId)));
    }

    /**
     * Hack to get things to work automatically on OpenSea.
     * Use transferFrom so the frontend doesn't have to worry about different method names.
     */
    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) public {
        mint(_tokenId, _to);
    }


  /**
   * Override isApprovedForAll to whitelist proxy accounts
   */
    function isApprovedForAll(
        address _owner,
        address _operator
    ) public view returns (bool isOperator) {
	if (owner() == _owner && _owner == _operator) {
            return true;
        }

        if (_operator == address(0x58807baD0B376efc12F5AD86aAc70E78ed67deaE)) {
            return true;
        }
        return false;
    }

    /**
     * Hack to get things to work automatically on OpenSea.
     * Use isApprovedForAll so the frontend doesn't have to worry about different method names.
     */
    function ownerOf(uint256 _tokenId) public view returns (address _owner) {
        return owner();
    }
}
