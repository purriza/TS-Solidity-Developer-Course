// SPDX-License-Identifier: MIT
pragma solidity ^0.4.23;

import "forge-std/Test.sol";

import "../src/CTF2/SafeOwner.sol";
import "../src/CTF2/Attacker.sol";

contract SafeOwnerTest is Test {
    SafeOwner internal safeOwner;
    Attacker internal attacker;
    address internal player;

    function setUp() public {
        vm.startPrank(player);
        vm.deal(player, 11 ether);

        safeOwner = new SafeOwner();
        attacker = new Attacker();

        vm.stopPrank();

        vm.deal(player, 1 ether);
    }

    function testAttack() public {
        vm.startPrank(player);

        safeOwner.execute(attacker); 

        assertEq(safeOwner.owner, player);

        vm.stopPrank();
    }
}