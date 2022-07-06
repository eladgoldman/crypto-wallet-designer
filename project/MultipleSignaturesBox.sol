// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.3;

import "./VerifySignature.sol";

/* This box requires a pair of message and a vaild signature, according to the 
   publicKey address it was constructed with. */
contract MultipleSignaturesBox {
    uint256 counter;
    address[] publicKeys;
    uint256[]  sets;
    VerifySignature verifier;

    /* Each set is a bitmap of a possible combination of keys
       For example, if keys 1&3 are enough, the set=0b101 will be in the _sets array */
    constructor(address[] memory _publicKeys, uint256[] memory _sets) {
        require(_publicKeys.length > 0, "No keys were provided");
        require(_sets.length > 0, "No sets provided");

        counter = 1;
        publicKeys = _publicKeys;
        sets = _sets;
        verifier = new VerifySignature();
    }

    modifier onlyWithSigantures(bytes[] memory _signatures) {
        
        uint256 sig_res = 0;
        string memory challenge = generateChallenge();
        /* Verify all signatures and save results in sig_res */
        for (uint i = 0; i < publicKeys.length; i++) {
            if(verifier.verify(publicKeys[i], challenge, _signatures[i])) {
                sig_res |= (1 << i);
            }
        }

        bool result = false;

        /* Loop over all sets */
        for (uint i = 0; i < sets.length; i++) {

            /* Check if sig_res fulfills sets[i] */
            if(sets[i] & sig_res == sets[i]) {
                /* sig_res is good, break  */
                result = true;
                break;
            }
        }

        require(result, "Wrong set of signatures");
        increaseCounter();
        _;
    }

    function deposit() public payable {}

    function withdraw(bytes[] memory _signatures)
        public payable onlyWithSigantures(_signatures) {
        (bool sent, bytes memory data) = msg.sender.call{value: msg.value}("");
        require(sent, "Failed to send Ether");
    }

    function getBalance(bytes[] memory _signatures)
        public onlyWithSigantures(_signatures) returns (uint) {
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