// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract SimpleStorage {
    uint256 private storedData;
    address public owner;

    event DataStored(uint256 indexed newValue, address indexed setter, uint256 timestamp);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    constructor(uint256 initialValue) {
        owner = msg.sender;
        storedData = initialValue;
        emit DataStored(initialValue, msg.sender, block.timestamp);
    }

    function set(uint256 newValue) public {
        storedData = newValue;
        emit DataStored(newValue, msg.sender, block.timestamp);
    }

    function get() public view returns (uint256) {
        return storedData;
    }

    function increment() public {
        storedData += 1;
        emit DataStored(storedData, msg.sender, block.timestamp);
    }

    function decrement() public {
        require(storedData > 0, "Value cannot go below zero");
        storedData -= 1;
        emit DataStored(storedData, msg.sender, block.timestamp);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "New owner cannot be zero address");
        address previousOwner = owner;
        owner = newOwner;
        emit OwnershipTransferred(previousOwner, newOwner);
    }
}
