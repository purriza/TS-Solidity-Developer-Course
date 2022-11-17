// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "lib/openzeppelin-contracts/contracts/token/ERC721/IERC721Receiver.sol";
import "src/ThreeSigmaNFT.sol";

contract Challenge is IERC721Receiver {
    
    /// Contract instances
    ThreeSigmaNFT _threeSigmaNFT;

    /// Structs
    struct ChallengeData {
        address currentWinner;
        uint timer;
    }

    /// Variables
    ChallengeData ETHChallenge;
    ChallengeData NFTChallenge;
    uint256[] NFTtokenIds;

    /// Constructor
    constructor() {
        ETHChallenge.timer = block.timestamp;
        NFTChallenge.timer = block.timestamp;
        _threeSigmaNFT = new ThreeSigmaNFT();
    }

    /// Modifiers

    /// @notice Ensure that the timer of the challenge received is stil up
    /// @param challengeData — Challenge data 
    modifier checkTimer(ChallengeData memory challengeData) {
        require(block.timestamp - challengeData.timer > 1 days, "The challenge has ended.");
        _;
    }

    /// Functions

    /// @notice Checks if the ETH challenge has ended.
    function checkETHChallenge() external {
        if (block.timestamp - ETHChallenge.timer > 1 days) {
            payable(ETHChallenge.currentWinner).transfer(address(this).balance);
        }
    }

    /// @notice Checks if the NFT challenge has ended.
    function checkNFTChallenge() external {
        if (block.timestamp - NFTChallenge.timer > 1 days) {
            for (uint i = 0; i < NFTtokenIds.length; i++) 
            {
                _threeSigmaNFT.transferNFT(NFTChallenge.currentWinner, NFTtokenIds[i]);
            }
        }
    }

    receive() external payable checkTimer(ETHChallenge) {
        // Whenever we received ETH and the timer is still up, we update the challenge data
        ETHChallenge.currentWinner = msg.sender;
        ETHChallenge.timer = block.timestamp;
    }

    /// @notice Transfers the NFT to the prize pool
    /// @param tokenId — Token ID.
    function transferNFT(uint256 tokenId) external {
        _threeSigmaNFT.transferNFT(msg.sender, address(this), tokenId);
    }

    /// IERC721Receiver
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external checkTimer(NFTChallenge) returns (bytes4) {
        // Whenever we received a ThreeSigmaNFT and the timer is still up, we update the challenge data
        NFTChallenge.currentWinner = msg.sender;
        NFTChallenge.timer = block.timestamp;
        NFTtokenIds.push(tokenId);

        return IERC721Receiver.onERC721Received.selector;
    }

}