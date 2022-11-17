// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/src/Test.sol";
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

        bytes8 key = hex"112233440000ea72";

        emit log_bytes32(key);
        // GATE 1
        emit log_bytes32(bytes32(uint256(uint32(uint64(key))))); // 5566ea72
        emit log_bytes32(bytes32(uint256(uint16(uint64(key))))); // ea72

        // GATE 2
        emit log_bytes32(bytes32(uint256(uint64(key)))); // 112233440000ea72

        // GATE 3
        emit log_bytes32(bytes32(uint256(uint16(uint160(tx.origin))))); // ea72 [20 bytes -> uint 20 * 8]

        //require(uint32(uint64(_gateKey)) == uint16(uint64(_gateKey)), "GatekeeperOne: invalid gateThree part one");
        //require(uint32(uint64(_gateKey)) != uint64(_gateKey), "GatekeeperOne: invalid gateThree part two");
        //require(uint32(uint64(_gateKey)) == uint16(tx.origin), "GatekeeperOne: invalid gateThree part three"); // pragma solidity 0.6.0. Derived from the EOA address

        //assertEq(address(functions).balance, 0);
        //assertEq(address(player).balance, 11 ether);  

        //emit log_named_uint("Attacker's credit", IVault(vault).queryCredit(address(attacker)));
        vm.stopPrank();
    }
}