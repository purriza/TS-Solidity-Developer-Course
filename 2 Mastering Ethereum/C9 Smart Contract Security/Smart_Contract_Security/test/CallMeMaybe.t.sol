// SPDX-License-Identifier MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "../src/CTF2/CallMeMaybe.sol";
import "../src/CTF2/Attacker.sol";

contract CallMeMaybeTest is Test {
    address internal callMeMaybe;
    address internal player;

    function setUp() public {
        callMeMaybe = address(new CallMeMaybe());
        
        vm.deal(player, 1 ether);
        vm.deal(callMeMaybe, 10 ether);
    }

    function testAttack() public {
        vm.startPrank(player);

        Attacker attacker = new Attacker(callMeMaybe);
        
        assertEq(callMeMaybe.balance, 0);
        assertEq(address(attacker).balance, 11 ether); 

        emit log_named_uint("Attacker's credit", IVault(callMeMaybe).queryCredit(address(attacker)));

        vm.stopPrank();
    }
}