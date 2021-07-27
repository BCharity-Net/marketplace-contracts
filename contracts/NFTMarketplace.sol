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

contract GIVEMarketplace is Ownable, IGIVEMarketplace {
	using SafeMath for int256;

	//events
	event AssetImported(address indexed owner, bytes32 id, address indexed nftContract, uint256 indexed tokenId, string name, uint256 numSales, uint256 royalties, address creator);
	event AssetCreated(address indexed creator, bytes32 id, string name, address indexed nftContract, uint256 indexed tokenId);
	event AssetOwnershipOffered(bytes32 id, address indexed owner, address indexed recipient);
	event AssetOwnershipChanged(address indexed newOwner, assetId, address indexed owner);
	event AssetUpdated(uint256 indexed tokenId, address indexed nftContract, address indexed owner);

	//Structures
	struct Asset{
		bytes32 id;
		uint256 tokenId;
		address nftContract;
		uint256 numSales;
		uint256 royalties;
		address owner;
		address creator;
		address recipient;
		mapping(address => Order) orders;
	}

	struct Order{
		
	}

	// Marketplace Lifecycle

	ERC20 public paymentToken;
	IGIVEMarketplace prev_marketplace;

	constructor() Ownable() public{
		
	}

	function _initialize() internal {
	
	}

	/// Asset management

	mapping (bytes32 => Asset) public assets;

	function getAsset(bytes32 id) public override view returns (uint256 tokenId, address nftContract, uint256 numSales, uint256 royalties, address owner, address creator) {
		(tokenId, nftContract, numSales, royalties, owner, creator) = _getAssetLocal(id);
		if (owner != address(0))
			return (tokenId, nftContract, numSales, royalties, owner, creator);
		(tokenId, nftContract, numSales, royalties, owner, creator) = prev_marketplace.getAsset(id);
		return (token_id, nftContract, numSales, royalties, owner, creator);
	}

	function _getAssetLocal(bytes32 id) internal view returns (uint256 tokenId, address nftContract, uint256 numSales, uint256 royalties, address owner, address creator) {
		Asset memory a = assets[id];
		return (
			a.tokenId, 
			a.nftContract, 
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
		(uint256 _tokenId, address _nftContract, uint256 _numSales, uint256 _royalties, address _owner, address _creator) = prev_marketplace.getAsset(assetId);
		if (_owner == address(0)) {return false;}
		a.id = assetId;
		a.tokenId = _tokenId; 
		a.nftContract = _nftContract; 
		a.numSales = _numSales; 
		a.royalties = _royalties;
		a.owner = _owner;
		a.creator = _creator;
		emit AssetImported(a.owner, a.id, a.nftContract, a.tokenId, a.name, a.numSales, a.royalties, a.creator);
		return true;
	}

	function createAsset(bytes32 assetId, uint256 tokenId, address nftContract, uint256 numSales, uint256 royalties, address owner, address creator) public {
		_createAsset(assetId, tokenId, nftContract, numSales, royalties, owner, creator);
	}

	function _createAsset(bytes32 assetId, uint256 tokenId, address nftContract, uint256 numSales, uint256 royalties, address owner, address creator) internal {
		require(tokenId != 0, "error_nullTokenId");
		require(nftContract != address(0), "error_nullnftContract");
		(,,,,,address _owner,,) = getAsset(assetId);
		require(_owner == address(0), "error_alreadyExists");
		assets[assetId] = Asset({id: assetId, tokenId: tokenId, nftContract: nftContract, numSales:numSales, royalties: royalties, owner: owner, creator: creator});
		emit AssetCreated(creator, nftContract, tokenId, owner);
	}

	function updateAsset(bytes32 assetId, uint256 tokenId, address nftContract, uint256 numSales, uint256 royalties, address owner, address creator) public onlyAssetOwner(assetId){
		_importAssetIfNeeded(assetId);
		Asset storage a = assets[assetId];
		a.id = assetId;
		a.tokenId = tokenId; 
		a.nftContract = nftContract; 
		a.numSales = numSales; 
		a.royalties =royalties;
		a.owner = owner;
		a.creator = creator;
		//finish filling out this field + implement event
		emit AssetUpdated(a.tokenId, a.nftContract, a.owner);
	}

	//two step asset transfer method
	function offerAsset(bytes32 assetId, address recipient) public onlyAssetOwner(assetId){
		_importAssetIfNeeded(assetId);
		assets[assetId].recipient = recipient;
		owner = assets[assetId].owner;
		//finish filling out this field + implement event
		emit AssetOwnershipOffered(assetId, owner, recipient);
	}

	function claimAsset(bytes32 assetId) public {
		_importAssetIfNeeded(assetId);
        Asset storage a = assets[assetId];
        require(msg.sender == a.newOwnerCandidate, "error_notPermitted");
        //Implement event
		emit AssetOwnershipChanged(msg.sender, assetId, a.owner);
        a.owner = msg.sender;
        a.newOwnerCandidate = address(0);
	}

	//one step asset transfer method
	function transferAsset(bytes32 assetId, address recipient) public onlyAssetOwner(assetId){
		_importAssetIfNeeded(assetId);
		Asset storage a = assets[assetId];
        a.owner = recipient;
        a.newOwnerCandidate = address(0);
	}

	//Whitelist mangement, if necessary?  

	// Order management

	function getOrder(){
		
	}

	function getOrderLocal(){
	
	}

	function _importOrderIfNeeded(){
	
	}

	function createOrder(){
		
	}

	function cancelOrder (){
	
	}

	function fulfillOrder(){
	
	}
	
}