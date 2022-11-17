// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract CallMeMaybe {
    modifier callMeMaybe() {
      uint32 size;
      address _addr = msg.sender;
      assembly {
        size := extcodesize(_addr)
      }
      if (size > 0) {
          revert();
      }
      _;
    }

    function hereIsMyNumber() public callMeMaybe {
        if(tx.origin == msg.sender) { // No tenemos que ser una EOA, hay que llamar desde SC
            revert();
        } else {
            payable(msg.sender).transfer(address(this).balance);
        }
    }

    receive() external payable {}
}