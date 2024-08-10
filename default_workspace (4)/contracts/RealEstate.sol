// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RealEstateToken is ERC721, Ownable {

   constructor() ERC721("Real Estate Token", "RE") Ownable(msg.sender) {
   }

    struct RealEstate {
        string name;
        string location;
        uint256 price;
        address currentOwner;
        bool isRegistered;
    }

    mapping(uint256 => RealEstate) public realEstates;
   
    uint256 private tokenIdCounter;

 // Function to register a new real estate property
    function registerRealEstate(
        string memory name,
        string memory location,
        uint256 price,
        address initialOwner
    ) external onlyOwner returns (uint256) {
        uint256 tokenId = tokenIdCounter;
        _safeMint(initialOwner, tokenId);
        realEstates[tokenId] = RealEstate(name, location, price, initialOwner, true);
        tokenIdCounter++;
        return tokenId;
    }

    //  Function to transfer ownership of a real estate property
    function transferRealEstateOwnership(uint256 tokenId, address newOwner) external {
        // require(_exists(tokenId), "Token ID does not exist");
        require(ownerOf(tokenId) == msg.sender, "You are not the owner of this property");
        realEstates[tokenId].currentOwner = newOwner;
        _transfer(msg.sender, newOwner, tokenId);
    }

    // Function to get real estate property details by token ID
    function getRealEstateDetails(uint256 tokenId)
        external
        view
        returns (
            string memory propertyName,
            string memory propertyLocation,
            uint256 propertyPrice,
            address currentPropertyOwner
        )
    {
        RealEstate storage property = realEstates[tokenId];
        return (property.name, property.location, property.price, property.currentOwner);
    }

}
