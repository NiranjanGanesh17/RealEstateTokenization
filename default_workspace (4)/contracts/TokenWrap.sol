// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract NFTCoinBridge is ERC20, Ownable {
    IERC721 public nftContract;
    IERC20 public coinContract;

    mapping(uint256 => uint256) public nftToCoins; // Mapping NFT token IDs to ERC-20 coin amounts

    constructor(address _nftContract) ERC20("Coin", "COIN") Ownable(msg.sender) {
        nftContract = IERC721(_nftContract);
        // coinContract = IERC20(_coinContract);
        
    }

    // Mint ERC-20 coins for an NFT owner
    function mintCoinsForNFT(uint256 tokenId, uint256 amount) external {
        require(nftContract.ownerOf(tokenId) == msg.sender, "You are not the owner of this NFT");
        require(nftToCoins[tokenId] == 0, "Coins already minted for this NFT");

        // Mint ERC-20 coins
        _mint(msg.sender, amount);

        // Associate NFT token ID with ERC-20 coin amount
        nftToCoins[tokenId] = amount;
    }


     // Burn ERC-20 coins when NFT is transferred or sold
    function burnCoinsForNFT(uint256 tokenId) external {
        require(nftContract.ownerOf(tokenId) == msg.sender, "You are not the owner of this NFT");
        require(nftToCoins[tokenId] > 0, "No coins minted for this NFT");

        // Burn ERC-20 coins
        _burn(msg.sender,nftToCoins[tokenId]);

        // Remove association of NFT token ID with ERC-20 coins
        delete nftToCoins[tokenId];
    }


     function getDetails(uint256 tokenId)
        external
        view
        returns (
         
            uint256 balance
        )
    {
       return nftToCoins[tokenId];
    }
}