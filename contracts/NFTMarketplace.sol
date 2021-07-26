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

	//events

	
	//Structures
	struct Asset{

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
	}

	// Marketplace Lifecycle

	ERC20 public paymentToken;

	constructor() Ownable() public{
		
	}

	function _initialize() internal {
	
	}

	/// Asset management

	function getAsset(){
	
	}

	function getAssetLocal(){
	
	}

	modifier onlyProductOwner(){
	
	}

	function _importAssetIfNeeded(){
	
	}

	function createAsset(){
	
	}

	function updateAsset(){
	
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