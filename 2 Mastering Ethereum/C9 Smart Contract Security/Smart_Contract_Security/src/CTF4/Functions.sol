// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Functions {
    
    constructor() public payable { require(msg.value != 0); }
    
    function withdraw() private {
        require(msg.value == 0, 'dont send funds!');
        payable(address(msg.sender)).transfer(address(this).balance);
    }
    
    function frwd() internal
        { withdraw(); }
        
    struct Func { function () internal f; }
    
    function breakIt() public payable {
        require(msg.value != 0, 'send funds!');
        Func memory func;
        func.f = frwd;


        assembly { 
            mstore( // offset in memory, value
                func, 
                add(mload(func), callvalue())
            ) 
        }
        func.f();
    }
}