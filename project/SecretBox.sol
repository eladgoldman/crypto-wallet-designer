// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.3;

contract SecretBox {
    uint key;
    
    constructor(uint _key) {
        key = _key;
    }

    modifier onlyWithKey(uint _key) {
        require(key == _key, "Wrong key");
        _;
    }

    function deposit() public payable {}

    function withdraw(uint _key) public payable onlyWithKey(_key) {
        (bool sent, bytes memory data) = msg.sender.call{value: msg.value}("");
        require(sent, "Failed to send Ether");
    }

    function getBalance(uint _key) public view onlyWithKey(_key) returns (uint) {
        return address(this).balance;
    }

}
