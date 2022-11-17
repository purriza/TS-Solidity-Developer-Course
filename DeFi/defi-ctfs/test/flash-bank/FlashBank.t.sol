// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./utils/FlashBankFixture.sol";

import "src/src-default/flash-bank/AttackFlashBank.sol";

contract FlashBankTest is FlashBankFixture {
    AttackFlashBank attackFlashBank;
    
    function setUp() public override {
        super.setUp();
    }

    function test_flashBank() public {
        // Start acting as the attacker for the remainder of the exploit
        vm.startPrank(attacker);

        /**
         * Code your exploit here
         */
        /*
            ---- We need to take all the ETH from the lending pool ----
        */ 
        attackFlashBank = new AttackFlashBank(address(pool));
        attackFlashBank.attack();

        // Stop acting as the attacker
        vm.stopPrank();
        // Perform exploit validations
        _assertions();
    }

    function _assertions() internal {
        // Verify the attacker drained the pool's funds
        assertEq(address(pool).balance, 0);
        assertGt(address(attacker).balance, ATTACKER_INITIAL_BALANCE);
    }
}