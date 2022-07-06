// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.3;

import "./VerifySignature.sol";

/* This box requires a pair of message and a vaild signature, according to the 
   publicKey address it was constructed with. */
contract SignatureBox {
    uint256 counter;
    address publicKey;
    VerifySignature verifier;

    constructor(address _publicKey) {
        counter = 1;
        publicKey = _publicKey;
        verifier = new VerifySignature();
    }

    modifier onlyWithSiganture(bytes memory _signature) {
        string memory challenge = generateChallenge();
        require(verifier.verify(publicKey, challenge, _signature), "Wrong signature");
        increaseCounter();
        _;
    }

    function getChallenge() public view returns (string memory) {
        return generateChallenge();
    }

    function deposit() public payable {}

    function withdraw(bytes memory _signature)
        public payable onlyWithSiganture(_signature) {
        (bool sent, bytes memory data) = msg.sender.call{value: msg.value}("");
        require(sent, "Failed to send Ether");
    }

    function getBalance(bytes memory _signature)
        public onlyWithSiganture(_signature) returns (uint) {
        return address(this).balance;
    }

    function generateChallenge() private view returns (string memory) {
        bytes memory self_address = abi.encodePacked(address(this));
        bytes memory counter_bytes = abi.encodePacked(counter);

        string memory challenge = string(bytes.concat(self_address, counter_bytes));
        return challenge;
    }

    function increaseCounter() private {
        counter = counter + 1;
    }
}