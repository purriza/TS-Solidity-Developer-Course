// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";

import "../src/CTF1/HoneyPot.sol";

contract HoneyPotTest is Test {
    HoneyPot internal honeyPot;
    address internal player;

    function setUp() public {
        vm.startPrank(player);
        vm.deal(player, 11 ether);

        honeyPot = new HoneyPot{value: 10 ether}();
        
        vm.stopPrank();

        vm.deal(player, 1 ether);
    }

    function testAttack() public {
        vm.startPrank(player);

        // We send 32 wei (0x20) to be able to pass the 06 JUMPI OP Code
        honeyPot.withdraw{value: 32 wei}(); 

        assertEq(address(honeyPot).balance, 0);
        assertEq(address(player).balance, 11 ether);  

        vm.stopPrank();
    }
}