// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";

import "../src/CTF3/Ship.sol";
import "../src/CTF3/Attacker.sol";

contract ShipTest is Test {
    Ship internal ship;
    Attacker internal attacker;
    address internal player;

    function setUp() public {
        vm.startPrank(player);

        ship = new Ship{value: 10 ether}();

        vm.stopPrank();
    }

    function testAttack() public {
        vm.startPrank(player);

        // We need to attack from the Attacker constructor
        attacker = new Attacker(address(ship));

        assertEq(address(ship).onOurWay, true);

        vm.stopPrank();
    }
}