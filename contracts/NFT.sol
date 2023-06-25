// NFTMarketplace.sol

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract NFTMarketplace is ERC721 {
  struct NFT {
    uint256 id;
    string name;
    string metadataURI;
    address owner;
    uint256 price;
    bool isForSale;
  }

  NFT[] public nfts;
  mapping(uint256 => address) public nftOwners;

  constructor() ERC721("NFTMarketplace", "NFTM") {}

  function createNFT(string memory _name, string memory _metadataURI) external {
    uint256 nftId = nfts.length;
    nfts.push(NFT(nftId, _name, _metadataURI, msg.sender, 0, false));
    nftOwners[nftId] = msg.sender;
    _safeMint(msg.sender, nftId);
  }

  function transferNFT(uint256 _nftId, address _to) external {
    require(msg.sender == nftOwners[_nftId], "Not the owner of the NFT");
    _transfer(msg.sender, _to, _nftId);
    nftOwners[_nftId] = _to;
  }

  function setNFTForSale(uint256 _nftId, uint256 _price) external {
    require(msg.sender == nftOwners[_nftId], "Not the owner of the NFT");
    nfts[_nftId].isForSale = true;
    nfts[_nftId].price = _price;
  }

  function buyNFT(uint256 _nftId) external payable {
    require(nfts[_nftId].isForSale, "NFT is not for sale");
    require(msg.value >= nfts[_nftId].price, "Insufficient funds");
    address seller = nftOwners[_nftId];
    address buyer = msg.sender;
    nftOwners[_nftId] = buyer;
    nfts[_nftId].isForSale = false;
    nfts[_nftId].price = 0;
    payable(seller).transfer(msg.value);
    _transfer(seller, buyer, _nftId);
  }
}
