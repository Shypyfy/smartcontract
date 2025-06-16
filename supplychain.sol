// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SupplyChain is ERC721, Ownable {

    uint256 public productCount = 0;
    uint256[] private productIds;

    struct Product {
        string serialHash;
        string metadataURI;
        address currentOwner;
        bool isFlagged;
        address flaggedBy;
        string flagReason;
        address[] ownerships;
    }

    mapping(uint256 => Product) public products;

    event ProductRegistered(uint256 indexed productId, address indexed creator, string serialHash);
    event OwnershipTransferred(uint256 indexed productId, address from, address to);
    event ProductFlagged(address indexed flaggedBy, uint256 indexed productId, string reason);

    constructor() ERC721("SupplyChainToken", "SCT") Ownable(msg.sender) {}

    modifier onlyProductOwner(uint256 _productId) {
        require(msg.sender == products[_productId].currentOwner, "Not the product owner");
        _;
    }

    function registerProduct(string memory _serialHash, string memory _metadataURI) external returns (uint256) {
        productCount++;
        productIds.push(productCount);

        Product storage p = products[productCount];
        p.serialHash = _serialHash;
        p.metadataURI = _metadataURI;
        p.currentOwner = msg.sender;
        p.ownerships.push(msg.sender);

        emit ProductRegistered(productCount, msg.sender, _serialHash);
        return productCount;
    }

    function transferProductOwnership(uint256 _productId, address _newOwner) external onlyProductOwner(_productId) {
        require(!products[_productId].isFlagged, "Product is flagged as fraud");

        address prevOwner = products[_productId].currentOwner;
        products[_productId].currentOwner = _newOwner;
        products[_productId].ownerships.push(_newOwner);

        emit OwnershipTransferred(_productId, prevOwner, _newOwner);
    }

    function flagProduct(uint256 _productId, string memory _reason) external {
        require(bytes(_reason).length > 0, "Reason required");

        products[_productId].isFlagged = true;
        products[_productId].flagReason = _reason;
        products[_productId].flaggedBy = msg.sender;

        emit ProductFlagged(msg.sender, _productId, _reason);
    }

    function getProduct(uint256 _productId) external view returns (Product memory) {
        return products[_productId];
    }

    function getOwnershipHistory(uint256 _productId) external view returns (address[] memory) {
        return products[_productId].ownerships;
    }
    function getAllProductIds() external view returns (uint256[] memory) {
        return productIds;
    }
}
