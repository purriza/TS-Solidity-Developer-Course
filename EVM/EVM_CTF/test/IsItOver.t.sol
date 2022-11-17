// SPDX-License-Identifier: MIT
pragma solidity ^0.4.21;

import "forge-std/Test.sol";

import "../src/CTF4/IsItOver.sol";
import "../src/CTF4/Attacker.sol";

contract  IsItOverTest is Test {
    IsItOver internal isItOver;
    Attacker internal attacker;
    address internal player;

    function setUp() public {
        vm.startPrank(player);

        isItOver = new IsItOver{value: 10 ether}();
        attacker = new Attacker(address(isItOver));
        
        vm.stopPrank();
    }

    function testAttack() public {
        vm.startPrank(player);

        attacker.attack();

        assertEq(address(isItOver).isComplete, true);

        vm.stopPrank();
    }
}