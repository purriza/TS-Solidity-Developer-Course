// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";

import "../src/CTF6/MoneyEater.sol";
import "../src/CTF6/Attacker.sol";

contract MoneyEaterTest is Test {
    MoneyEater internal moneyEater;
    Attacker internal attacker;
    address internal player;

    function setUp() public {
        vm.startPrank(player);
        vm.deal(player, 11 ether);

        moneyEater = new MoneyEater{value: 1 ether}();
        attacker = new Attacker{value: 1 ether}();

        vm.stopPrank();

        vm.deal(player, 1 ether);
    }

    function testAttack() public {
        vm.startPrank(player);

        attacker.attack(); 

        assertEq(address(moneyEater).owner, address(attacker));
        assertEq(address(moneyEater).balance, 0 ether);  
        assertGt(address(attacker).balance > 1)

        vm.stopPrank();
    }
}