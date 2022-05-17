// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.3;

import "./VerifySignature.sol";

/* This box requires a pair of message and a vaild signature, according to the 
   publicKey address it was constructed with. */
contract SignatureBox {
    address publicKey;
    VerifySignature verifier;

    constructor(address _publicKey) {
        publicKey = _publicKey;
        verifier = new VerifySignature();
    }

    modifier onlyWithSiganture(string memory _message, bytes memory _signature) {
        require(verifier.verify(publicKey, _message, _signature), "Wrong signature");
        _;
    }

    function deposit() public payable {}

    function withdraw(string memory _message, bytes memory _signature)
        public payable onlyWithSiganture(_message, _signature) {
        (bool sent, bytes memory data) = msg.sender.call{value: msg.value}("");
        require(sent, "Failed to send Ether");
    }

    function getBalance(string memory _message, bytes memory _signature)
        public view onlyWithSiganture(_message, _signature) returns (uint) {
        return address(this).balance;
    }
}