pragma solidity ^0.4.23;

contract SafeOwner {
    
    address public owner;
    
    modifier noOwner() {
        require(owner == 0, 'level already completed');
        _;
    }
    
    bytes4 internal constant SET = bytes4(keccak256('Set(uint256)'));
    
    function execute(address _target) public noOwner {
        require(_target.delegatecall(abi.encodeWithSelector(this.execute.selector)) == false, 'unsafe execution');
        
        (bytes4 sel, uint val) = getRet();
        require(sel == SET);
        function () func;
        assembly { func := val }
        func();
    }
    
    function getRet() internal pure returns (bytes4 sel, uint val) {
        assembly {
            // The returndatasize should be size 36 bytes (0x24)
            if iszero(eq(returndatasize, 0x24)) { revert(0, 0) }
            let ptr := mload(0x40)
            returndatacopy(ptr, 0, 0x24)
            // We take the 4 first bytes to check if is SET
            sel := and(mload(ptr), 0xffffffff00000000000000000000000000000000000000000000000000000000)
            // We take the next 32 bytes to check the function selector (setOwner)
            val := mload(add(0x04, ptr))
        }
    }
    
    function setOwnerExt() external { if (false) setOwner(); }
    
    function setOwner() private { owner = msg.sender; }
}