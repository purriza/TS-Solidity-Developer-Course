// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "../src/CTF1/Vault.sol";
import "../src/CTF1/Attacker.sol";

contract VaultTest is Test {
    address internal vault;
    address internal player;

    function setUp() public {
        vault = address(new Vault());

        vm.deal(player, 1 ether);
        vm.deal(vault, 10 ether);
    }

    function testAttack() public {
        vm.startPrank(player);
        
        Attacker attacker = new Attacker(vault);
        attacker.attack();

        assertEq(vault.balance, 0);
        assertEq(address(attacker).balance, 11 ether); 

        emit log_named_uint("Attacker's credit", IVault(vault).queryCredit(address(attacker)));
        vm.stopPrank();
    }
}