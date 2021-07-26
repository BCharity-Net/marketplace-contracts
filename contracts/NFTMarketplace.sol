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
	using SafeMath for int256;


	//Structures

	struct Asset{
		bytes32 id;
		uint tokenId;
		address contract;
		uint numSales;
		uint royalties;
		address owner;
		address creator;
		mapping(address => Order) orders;
	}

	struct Order{

		Asset asset;
		address fromAddress;
		address toAddress;
		uint orderType; // 1 for sellOrder or 2 for buyOrder
		uint subPrice; //likely in units of finney (0.001 ETH)
		uint royalties; //9% of price. however, solidity DOES NOT support decimal/fractional values.
		uint price; //subPrice + royalties
		
		//expirationTime?
		//auctions?

	using SafeMath for int256;

	//events
	event AssetImported(address indexed owner, bytes32 id, address indexed contract, uint indexed tokenId, string name, uint numSales, uint royalties, address creator);
	event AssetCreated(address indexed msg.sender, bytes32 id, string name, address indexed contract, uint indexed tokenId)

	// Marketplace Lifecycle

	ERC20 public paymentToken;

	constructor() Ownable() public{
		
	}

	function _initialize() internal {
	
	}

	/// Asset management

	function getAsset(bytes32 id) public override view returns (uint tokenId, address contract, uint numSales, uint royalties, address owner, address creator) {
		(tokenId, contract, numSales, royalties, owner, creator) = _getAssetLocal(id);
		if (owner != address(0))
			return (token_id, contract, numSales, royalties, owner, creator);
		(tokenId, contract, numSales, royalties, owner, creator) = prev_marketplace.getAsset(id);
		return (token_id, contract, numSales, royalties, owner, creator);
	}

	function getAssetLocal(bytes32 id) internal view returns (uint tokenId, address contract, uint numSales, uint royalties, address owner, address creator) {
		Asset memory a = assets[id];
		return (
			a.tokenId, 
			a.contract, 
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
		a.contract = _contract; 
		a.numSales = _numSales; 
		a.royalties = _royalties;
		a.owner = _owner;
		a.creator = _creator;
		emit AssetImported(a.owner, a.id, a.contract, a.tokenId, a.name, a.numSales, a.royalties, a.creator);
		return true;
	}

	function createAsset(bytes32 assetId, uint tokenId, address contract, uint numSales, uint royalties, address owner, address creator) public {
		_createAsset(assetId, tokenId, contract, numSales, royalties, owner, creator);
	}

	function _createAsset(bytes32 assetId, uint tokenId, address contract, uint numSales, uint royalties, address owner, address creator) internal {
		require(tokenId != 0, "error_nullTokenId");
		require(contract != address(0), "error_nullContract");
		(,,,,,address _owner,,) = getProduct(assetId);
		require(_owner == address(0), "error_alreadyExists");
		assets[assetId] = Asset({id: assetId, tokenId: tokenId, contract: contract, numSales:numSales, royalties: royalties, owner: owner, creator: msg.sender});
		emit AssetCreated(msg.sender, id, name, contract, tokenId);
	}

	function updateAsset() public onlyAssetOwner(assetId){
		
	}

	//two step asset transfer method
	function offerAsset(){
	
	}

	function claimAsset(){
	
	}

	//one step asset transfer method
	function transferAsset(){
	
	}

	//Whitelist mangement, if necessary?  

	// Order management

	mapping (uint => Order) public sellOrder; //uint will be the tokenId. probably only going to have one sellOrder at a time?
	mapping (uint => Order[]) public buyOrders; //array of Orders to represent buy orders on an asset

	function getSellOrders(bytes32 assetId){

		return sellOrder[assetId]; //returns a sell order of a specific asset
		
	}

	function getBuyOrders(bytes32 assetId){

		return buyOrders[assetId]; //returns array of buy orders on a specific asset
	}

	function getOrderLocal(){
	
	}

	function _importOrderIfNeeded(){
	
	}

	function createOrder(Asset asset, address fromAddress, address toAddress, uint orderType, uint subPrice){
		
		
	}

	function cancelOrder(){
	
	}

	function fulfillOrder(){
	
	}
	
}