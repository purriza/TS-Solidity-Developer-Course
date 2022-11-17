pragma solidity ^0.4.21;

contract MoneyEater {
    struct MoneyMeal {
        uint256 timestamp;
        uint256 etherAmount;
    }
    MoneyMeal[] public meals;

    address public owner;

    function MoneyEater() public payable {
        require(msg.value == 1 ether);
        
        owner = msg.sender;
    }
    
    function isComplete() public view returns (bool) {
        return address(this).balance == 0;
    }

    function feed(uint256 etherAmount) public payable {
        // amount is in ether, but msg.value is in wei
        uint256 scale = 10**18 * 1 ether;
        require(msg.value == etherAmount / scale);

        // Uninitialized pointer (meal.timestamp -> slot 0 [meals] / meal.etherAmount -> slot 1 [owner])
        // Need to set it as MoneyMeal memory meal
        MoneyMeal meal;
        meal.timestamp = now;
        meal.etherAmount = etherAmount;

        meals.push(meal);
    }

    function withdraw() public {
        require(msg.sender == owner);
        
        msg.sender.transfer(address(this).balance);
    }
}