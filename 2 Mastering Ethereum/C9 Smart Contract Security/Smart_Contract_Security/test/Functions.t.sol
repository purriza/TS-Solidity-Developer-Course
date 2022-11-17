// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "../src/CTF4/Functions.sol";

contract FunctionsTest is Test {
    Functions internal functions;
    address internal player;

    function setUp() public {
        vm.startPrank(player);

        vm.deal(player, 11 ether);

        functions = new Functions{value: 10 ether}();
        
        vm.stopPrank();

        vm.deal(player, 1 ether);
    }

    function testAttack() public {
        vm.startPrank(player);

        // Find the value to set callvalue to jump to the correct place
        functions.breakIt{value: 128}(); 

        assertEq(address(functions).balance, 0);
        assertEq(address(player).balance, 11 ether);  

        //emit log_named_uint("Attacker's credit", IVault(vault).queryCredit(address(attacker)));
        vm.stopPrank();
    }
}