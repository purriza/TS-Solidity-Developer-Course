// SPDX-License-Identifier MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "../src/CTF3/HowRandomIsRandom.sol";
import "../src/CTF3/Attacker.sol";

contract HowRandomIsRandomTest is Test {
    address internal howRandomIsRandom;
    address internal player;

    function setUp() public {
        howRandomIsRandom = address(new HowRandomIsRandom());
        
        vm.deal(player, 1 ether);
        vm.deal(howRandomIsRandom, 10 ether);
    }

    function testAttack() public {
        vm.startPrank(player);

        Attacker attacker = new Attacker(howRandomIsRandom);
        attacker.attack();

        assertEq(howRandomIsRandom.balance, 0);
        assertEq(address(attacker).balance, 11 ether); 

        emit log_named_uint("Attacker's credit", IVault(howRandomIsRandom).queryCredit(address(attacker)));

        vm.stopPrank();
    }
}