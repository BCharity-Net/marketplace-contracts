// solhint-disable not-rely-on-time
pragma solidity ^0.6.6;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";

import "./PurchaseListener.sol";
import "./Ownable.sol";

interface IGIVEMarketplace{

}

/*
 *
 */

contract GIVEMarketplace is Ownable, IGIVEMarketplace{

	using SafeMath for uint256;
	
	//events (must be defined before structs for some reason...)
	event AssetImported(address indexed owner, bytes32 id, address indexed contractAddress, uint indexed tokenId, string name, uint numSales, uint royalties, address creator);
	event AssetCreated(address indexed owner, bytes32 id, string name, address indexed contractAddress, uint indexed tokenId);
	
	//Structures
	struct Asset{
		bytes32 id;
		uint tokenId;
		address contractAddress;
		uint numSales;
		uint royalties;
		address owner;
		address creator;
		mapping(address => Order) orders;
	}

	struct Order{

		Asset asset;
		address fromAddress;
		address toAddress; //from and to indicate the direction the asset is 'travelling'
		uint orderType; // 1 for sellOrder or 2 for buyOrder
		uint subPrice; //likely in units of finney (0.001 ETH)
		uint price; //subPrice + 9% royalties
		
		//expirationTime?
		//auctions?

	}

	// Marketplace Lifecycle

	ERC20 public paymentToken;

	constructor() Ownable() public{
		
	}

	function _initialize() internal {
	
	}

	/// Asset management

	function getAsset(bytes32 id) public override view returns (uint tokenId, address contractAddress, uint numSales, uint royalties, address owner, address creator) {
		(tokenId, contractAddress, numSales, royalties, owner, creator) = _getAssetLocal(id);
		if (owner != address(0))
			return (token_id, contractAddress, numSales, royalties, owner, creator);
		(tokenId, contractAddress, numSales, royalties, owner, creator) = prev_marketplace.getAsset(id);
		return (token_id, contractAddress, numSales, royalties, owner, creator);
	}

	function _getAssetLocal(bytes32 id) internal view returns (uint tokenId, address contractAddress, uint numSales, uint royalties, address owner, address creator) {
		Asset memory a = assets[id];
		return (
			a.tokenId, 
			a.contractAddress, 
			a.numSales, 
			a.royalties,
			a.owner, 
			a.creator
		);
	}

	modifier onlyAssetOwner(bytes32 assetId) {
        (,,,,,address _owner,,) = getAsset(assetId);
        require(_owner != address(0), "error_notFound");
        require(_owner == msg.sender || owner == msg.sender, "error_assetOwnersOnly");
        _;
    }

	function _importAssetIfNeeded(bytes32 assetId) internal returns(bool imported){
		Asset storage a = assets[assetId];
		if (a.id != 0x0) {return false;}
		(_tokenId, _contract, _numSales, _royalties, _owner, _creator) = prev_marketplace.getAsset(assetId);
		if (_owner == address(0)) {return false;}
		a.id = assetId;
		a.tokenId = _tokenId; 
		a.contractAddress = _contractAddress; 
		a.numSales = _numSales; 
		a.royalties = _royalties;
		a.owner = _owner;
		a.creator = _creator;
		emit AssetImported(a.owner, a.id, a.contractAddress, a.tokenId, a.name, a.numSales, a.royalties, a.creator);
		return true;
	}

	function createAsset(bytes32 assetId, uint tokenId, address contractAddress, uint numSales, uint royalties, address owner, address creator) public {
		_createAsset(assetId, tokenId, contractAddress, numSales, royalties, owner, creator);
	}

	function _createAsset(bytes32 assetId, uint tokenId, address contractAddress, uint numSales, uint royalties, address owner, address creator) internal {
		require(tokenId != 0, "error_nullTokenId");
		require(contractAddress != address(0), "error_nullContract");
		(,,,,,address _owner,,) = getProduct(assetId);
		require(_owner == address(0), "error_alreadyExists");
		assets[assetId] = Asset({id: assetId, tokenId: tokenId, contractAddress: contractAddress, numSales:numSales, royalties: royalties, owner: owner, creator: msg.sender});
		emit AssetCreated(msg.sender, id, name, contractAddress, tokenId);
	}

	function updateAsset(bytes32 assetId) public onlyAssetOwner(assetId){
		
	}

	//two step asset transfer method
	function offerAsset() public {
	
	}

	function claimAsset() public {
	
	}

	//one step asset transfer method
	function transferAsset() public {
	
	}

	//Whitelist mangement, if necessary?  

	// Order management

	mapping (uint => Order) public sellOrder; //uint will be the tokenId. probably only going to have one sellOrder at a time?
	mapping (uint => Order[]) public buyOrders; //array of Orders to represent buy orders on an asset

	function getSellOrder(uint tokenId) public {
		return sellOrder[tokenId]; //returns a sell order of a specific asset
	}

	function getBuyOrders(uint tokenId) public {
		return buyOrders[tokenId]; //returns array of buy orders on a specific asset
	}

	function getBuyOrder(uint tokenId, address toAddress) public { //retrieves a buy order that you made


	}

	function getOrderLocal() public { //what is a local order?
	
	}

	function _importOrderIfNeeded() internal {

	}

	function createOrder(Asset asset, address fromAddress, address toAddress, uint orderType, uint subPrice) public {
		
		if (orderType == 1){ //if sellOrder
			sellOrder[asset.tokenId] = Order(asset, fromAddress, toAddress, orderType, subPrice, subPrice * 109 / 100);
		}
		else if (orderType == 2){ //if buyOrder
			buyOrders[asset.tokenId].push(Order(asset, fromAddress, toAddress, orderType, subPrice, subPrice * 109 / 100));
		}
		
	}

	function cancelOrder(Order order, address toAddress) public {

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

	function fulfillOrder() public {
	
	}
	
}