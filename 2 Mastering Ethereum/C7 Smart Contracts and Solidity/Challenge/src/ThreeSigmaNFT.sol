// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract ThreeSigmaNFT is ERC721, Ownable {

    /// Variables
    uint nextTokenId;

    /// Constructor (ERC721)
    constructor() public ERC721 ("ThreeSigmaNFT", "TS") {}

    /// Functions

    /// @notice Mints one NFT.
    /// @param receiver — Address of the receiver.
    function mintNFT(address receiver) external {
        nextTokenId++;

        _mint(receiver, nextTokenId);
    }

    /// @notice Mints one NFT using a tokenId.
    /// @param receiver — Address of the receiver.
    /// @param tokenId — Token ID.
    function mint(address receiver, uint256 tokenId) external {
        _mint(receiver, tokenId);
    }

    /// @notice Transfers the NFT.
    /// @param receiverAdress — Receiver address
    /// @param tokenId — Token ID.
    function transferNFT(address receiverAdress, uint256 tokenId) external {
        safeTransferFrom(msg.sender, receiverAdress, tokenId);
    }
}