// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./utils/TheAwarderFixture.sol";

import "src/src-default/the-awarder/AttackTheAwarder.sol";

contract TheAwarderTest is TheAwarderFixture {
    AttackTheAwarder attackTheAwarder;

    function setUp() public override {
        super.setUp();        
    }

    function test_theAwarder() public {

        // NOTE: Block timestamp is at 1 + 5 days

        // Start acting as the attacker for the remainder of the exploit
        vm.startPrank(attacker);

        /**
         * Code your exploit here
         */
        /*
          ---- We need to get the maximum amount of rewards on the next round ----
          We could take a flash loan of the max amoun of tokens available on the FlashLoanerPool and then deposit them into the AwarderPool
          We really need to get the rewards as soon as possible in order to be able to return the flashLoan in order to not get reverted
        */ 

        // Advance time 5 days so that the attacker can get awards
        vm.warp(block.timestamp + 5 days); // 5 days
        
        attackTheAwarder = new AttackTheAwarder(address(theAwarderPool), address(flashLoanerPool), address(token), address(theAwarderPool.awardToken()));
        attackTheAwarder.attack();

        // Stop acting as the attacker
        vm.stopPrank();
        // Perform exploit validations
        _assertions();
    }

    function _assertions() internal {
        assertEq(theAwarderPool.roundNumber(), 3); // Only one round should have taken place
        for (uint8 i; i < 4; i++) {
            // Users should get negligible awards this round
            vm.prank(users[i]);
            theAwarderPool.distributeAwards();
            uint256 awardPerUser = theAwarderPool.awardToken().balanceOf(
                users[i]
            );
            uint256 delta = awardPerUser - 25e18;
            assertLt(delta, 1e16);
        }
        // Awards must have been issued to the attacker account
        assertGt(theAwarderPool.awardToken().totalSupply(), 100e18);
        uint256 awardAttacker = theAwarderPool.awardToken().balanceOf(
            attacker
        );

        // The amount of awards earned should be really close to 100 tokens
        uint256 deltaAttacker = 100e18 - awardAttacker;
        assertLt(deltaAttacker, 1e17);

        // Attacker finishes with zero DCT tokens in balance
        assertEq(token.balanceOf(attacker), 0);
    }
}