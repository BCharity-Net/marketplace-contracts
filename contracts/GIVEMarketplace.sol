// SPDX-License-Identifier: AGPL-3.0-only
// solhint-disable not-rely-on-time, var-name-mixedcase
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/utils/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/access/Ownable.sol";

import "./PurchaseListener.sol";
//import "./Ownable.sol";
import "./giveNFT/giveNFTv2.sol";
import "./giveNFT/giveNFTv2Factory.sol";


interface IGIVEMarketplace{

	function getAsset(bytes32 id) external view returns (uint256 tokenId, address nftContract, uint256 numSales, uint256 royalties, address owner, address creator);
	
}

/*
 *
 */

contract GIVEMarketplace is Ownable, IGIVEMarketplace {
	using SafeMath for int256;

	//events
	event AssetImported(address indexed owner, bytes32 id, address indexed nftContract, uint256 indexed tokenId, uint256 numSales, uint256 royalties, address creator);
	event AssetCreated(address indexed creator, address indexed nftContract, uint256 indexed tokenId, address owner);
	event AssetOwnershipOffered(bytes32 id, address indexed owner, address indexed recipient);
	event AssetOwnershipChanged(address indexed newOwner, bytes32 assetId, address indexed owner);
	event AssetUpdated(uint256 indexed tokenId, address indexed nftContract, address indexed owner);
	event EnteredFunction();
	event InitialChecks();
	event GotAsset();
	event AssigningAsset();


	//Structures
	struct Asset{
		bytes32 id;
		uint256 tokenId;
		address nftContract;
		uint256 numSales;
		uint256 royalties;
		address assetOwner;
		address creator;
		address recipient;
	}

	struct Order{

		Asset asset;
		address fromAddress;
		address toAddress; //from and to indicate the direction the asset is 'travelling'
		uint orderType; // 1 for sellOrder or 2 for buyOrder
		uint subPrice; //likely in units of finney (0.001 ETH)
		uint price; //subPrice + 9% royalties
		bool isComplete; //indicates if the order has been fulfilled.  
		
		//expirationTime?
		//auctions?
	}

	// Marketplace Lifecycle

	ERC20 public paymentToken;
	IGIVEMarketplace public prev_marketplace;
	address private addressCheck;
	uint256 public txFee;

	constructor(address paymentTokenAddress, address prevMarketplaceAddress) Ownable() {
		_initialize(paymentTokenAddress, prevMarketplaceAddress);
	}

	function _initialize(address paymentTokenAddress, address prevMarketplaceAddress) internal {
		paymentToken = ERC20(paymentTokenAddress);
		prev_marketplace = IGIVEMarketplace(prevMarketplaceAddress);
		addressCheck = prevMarketplaceAddress;
	}

	/// Asset management

	mapping (bytes32 => Asset) public assets;

	function getAsset(bytes32 id) public override view returns (uint256 tokenId, address nftContract, uint256 numSales, uint256 royalties, address assetOwner, address creator) {
		(tokenId, nftContract, numSales, royalties, assetOwner, creator) = _getAssetLocal(id);
		if (assetOwner != address(0))
			return (tokenId, nftContract, numSales, royalties, assetOwner, creator);
		if (addressCheck == address(0))
		    return (tokenId, nftContract, numSales, royalties, assetOwner, creator);
		(tokenId, nftContract, numSales, royalties, assetOwner, creator) = prev_marketplace.getAsset(id);
		return (tokenId, nftContract, numSales, royalties, assetOwner, creator);
	}

	function _getAssetLocal(bytes32 id) internal view returns (uint256 tokenId, address nftContract, uint256 numSales, uint256 royalties, address assetOwner, address creator) {
		Asset memory a = assets[id];
		return (
			a.tokenId, 
			a.nftContract, 
			a.numSales, 
			a.royalties,
			a.assetOwner, 
			a.creator
		);
	}

	modifier onlyAssetOwner(bytes32 assetId) {
        (,,,,address _assetOwner,) = getAsset(assetId);
        require(_assetOwner != address(0), "error_notFound");
        require(_assetOwner == msg.sender || owner() == msg.sender, "error_assetOwnersOnly");
        _;
    }

	function _importAssetIfNeeded(bytes32 assetId) internal returns(bool imported){
		Asset storage a = assets[assetId];
		if (a.id != 0x0) {return false;}
		(uint256 _tokenId, address _nftContract, uint256 _numSales, uint256 _royalties, address _assetOwner, address _creator) = prev_marketplace.getAsset(assetId);
		if (_assetOwner == address(0)) {return false;}
		a.id = assetId;
		a.tokenId = _tokenId; 
		a.nftContract = _nftContract; 
		a.numSales = _numSales; 
		a.royalties = _royalties;
		a.assetOwner = _assetOwner;
		a.creator = _creator;
		emit AssetImported(a.assetOwner, a.id, a.nftContract, a.tokenId, a.numSales, a.royalties, a.creator);
		return true;
	}

	function createAsset(bytes32 assetId, uint256 tokenId, address nftContract, uint256 numSales, uint256 royalties, address assetOwner, address creator) public {
		_createAsset(assetId, tokenId, nftContract, numSales, royalties, assetOwner, creator);
	}

	function _createAsset(bytes32 assetId, uint256 tokenId, address nftContract, uint256 numSales, uint256 royalties, address assetOwner, address creator) internal {
		emit EnteredFunction();
		require(tokenId != 0, "error_nullTokenId");
		require(nftContract != address(0), "error_nullnftContract");
		emit InitialChecks();
		(,,,,address _assetOwner,) = getAsset(assetId);
		emit GotAsset();
		require(_assetOwner == address(0), "error_alreadyExists");
		emit AssigningAsset();
		assets[assetId] = Asset({id: assetId, tokenId: tokenId, nftContract: nftContract, numSales:numSales, royalties: royalties, assetOwner: assetOwner, creator: creator, recipient: address(0)});
		emit AssetCreated(creator, nftContract, tokenId, assetOwner);
	}

	function updateAsset(bytes32 assetId, uint256 tokenId, address nftContract, uint256 numSales, uint256 royalties, address assetOwner, address creator) public onlyAssetOwner(assetId){
		_importAssetIfNeeded(assetId);
		Asset storage a = assets[assetId];
		a.id = assetId;
		a.tokenId = tokenId; 
		a.nftContract = nftContract; 
		a.numSales = numSales; 
		a.royalties =royalties;
		a.assetOwner = assetOwner;
		a.creator = creator;
		//finish filling out this field + implement event
		emit AssetUpdated(a.tokenId, a.nftContract, a.assetOwner);
	}

	//two step asset transfer method
	function offerAsset(bytes32 assetId, address recipient) public onlyAssetOwner(assetId){
		_importAssetIfNeeded(assetId);
		assets[assetId].recipient = recipient;
		address assetOwner = assets[assetId].assetOwner;
		//finish filling out this field + implement event
		emit AssetOwnershipOffered(assetId, assetOwner, recipient);
	}

	function claimAsset(bytes32 assetId) public {
		_importAssetIfNeeded(assetId);
        Asset storage a = assets[assetId];
        require(msg.sender == a.recipient, "error_notPermitted");
        //Implement event
		emit AssetOwnershipChanged(msg.sender, assetId, a.assetOwner);
        a.assetOwner = msg.sender;
        a.recipient = address(0);
	}

	//one step asset transfer method
	function transferAsset(bytes32 assetId, address recipient) public onlyAssetOwner(assetId){
		_importAssetIfNeeded(assetId);
		Asset storage a = assets[assetId];
        a.assetOwner = recipient;
        a.recipient = address(0);
	}

	//Whitelist mangement, if necessary?  

	// Order management

	mapping (uint256 => Order) sellOrder; //uint will be the tokenId. probably only going to have one sellOrder at a time?
	mapping (uint256 => Order[]) buyOrders; //array of Orders to represent buy orders on an asset

	function getSellOrder(uint tokenId) public view returns (Order memory _sellOrder){
		return sellOrder[tokenId]; //returns a sell order of a specific asset
	}

	function getBuyOrders(uint tokenId) public view returns (Order[] memory _buyOrders){
		return buyOrders[tokenId]; //returns array of buy orders on a specific asset
	}

	function getBuyOrder(uint tokenId, address toAddress) public view returns (Asset memory asset, address fromAddress, address toAddressOut, uint256 orderType, uint256 subPrice, uint256 price) { //retrieves a buy order that you made
        Order memory orderOut;
        for (uint256 i = 0; i < buyOrders[tokenId].length; i++){
            if(buyOrders[tokenId][i].toAddress == toAddress){
                orderOut = buyOrders[tokenId][i];
            }
        }
        
        return(
            orderOut.asset,
            orderOut.fromAddress,
            orderOut.toAddress,
            orderOut.orderType,
            orderOut.subPrice,
            orderOut.price
        );
        
	}

	function getOrderLocal() public { //what is a local order?
	    
	}

	function _importBuyOrderIfNeeded() internal {
        
	}
	
	function _importSellOrderIfNeeded() internal {
	    
	}

	function createOrder(bytes32 assetId, address fromAddress, address toAddress, uint orderType, uint subPrice) public {
		Asset memory asset = assets[assetId];
		
		if (orderType == 1){ //if sellOrder
			sellOrder[asset.tokenId] = Order(asset, fromAddress, toAddress, orderType, subPrice, subPrice * 109 / 100, false);
		}
		else if (orderType == 2){ //if buyOrder
			buyOrders[asset.tokenId].push(Order(asset, fromAddress, toAddress, orderType, subPrice, subPrice * 109 / 100, false));
		}
		
	}

	function cancelOrder(Order memory order, address toAddress) public {

		if (order.orderType == 1){
			delete sellOrder[order.asset.tokenId];
		}
		else if (order.orderType == 2){
			for (uint i=0; i < buyOrders[order.asset.tokenId].length; i++){
				if (buyOrders[order.asset.tokenId][i].toAddress == toAddress){ 
				//buyOrders[order.asset.tokenId][i].toAddress retrieves buyOrder array,
				//then iterates through the array with i, and compares the passed toAddress(presumably the user's address)
				//with the address that created the order.
					delete buyOrders[order.asset.tokenId][i].toAddress;

				}
			}
		}
		//TODO delete leaves empty spot; move last element into empty spot.
	}

	function fulfillOrder(Order memory order1) public {
	    
	    //implement actual contract transfers + payment here
	    
	    bytes32 assetIndex = order1.asset.id;
	    transferAsset(assetIndex, msg.sender);
	    
	    order1.isComplete = true;
	}
	
	function matchOrder(Order memory order1, Order memory order2) internal {
	    
	}
	
}