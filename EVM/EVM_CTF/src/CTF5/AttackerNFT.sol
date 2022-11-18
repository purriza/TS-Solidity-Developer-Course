// SPDX-License-Identifier: MIT
pragma solidity ^0.4.21;

import "@openzeppelin/token/ERC721/ERC721.sol";
import "@openzeppelin/access/ERC721/Ownable.sol";

contract AttackerNFT is ERC721, Ownable {
    
    constructor() ERC721("AttackerNFT", "ANFT") {}

    function mint(address to, uint256 tokenId) external onlyOwner {
        _mint(to, tokenId)
    }
}