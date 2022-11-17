pragma solidity ^0.4.21;

contract IsItOver {
    bool public isComplete; // Slot 0
    uint256[] map; // Slot 1 (Length) - uint256(keccak256(slot)) + (index * elementSize)


    function setKeyAndValue(uint256 key, uint256 value) public {
        // Expand dynamic array as needed
        if (map.length <= key)
            map.length = key + 1;

        map[key] = value;
    }

    function getValue(uint256 key) public view returns (uint256) {
        return map[key];
    }
}