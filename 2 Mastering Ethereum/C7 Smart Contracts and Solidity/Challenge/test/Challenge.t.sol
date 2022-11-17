// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "lib/forge-std/src/Test.sol";
import "../src/Challenge.sol";
import "../src/ThreeSigmaNFT.sol";

contract ChallengeTest is Test {
    ThreeSigmaNFT public nft;
    Challenge public challenge;
    address player = address(100);
    address myThreeSigmaNFTAddress = address(43535354);

    function setUp() public {
        vm.startPrank(player);
        nft = new ThreeSigmaNFT(); // Deploying contract
        //nft = ThreeSigmaNFT(myThreeSigmaNFTAddress); // Casting 
        challenge = new Challenge(address(nft)); // Deploying contract
        vm.stopPrank();
    }

    function testMint() public {
        // Test 1 - Equal
        uint tokenId = 100;
        vm.startPrank(player);

        vm.expectEmit(true, true, true, false);
        emit Transfer(address(0), player, 100);
        nft.mint(player, tokenId);

        assertEq(nft.ownerOf(tokenId), player);
        assertEq(nft.balanceOf(player), 1);

        vm.stopPrank();

        // Test 2 - Expect revert
        address eve = address(200);
        vm.startPrank(eve);

        vm.expectRevert("Ownable: caller is not the owner");
        nft.mint(eve, 1000000);

        vm.stopPrank();
    }

    function testDeposit() public {

    }
}
