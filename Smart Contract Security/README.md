Identify and fix the vulnerabilities in this simple smart contract to make it secure. Add your custom attack function to attack the smart contract and call the withdraw function.
Submit the repo link to your audited source code

Original Code
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
contract VulnerablePiggyBank {
    address public owner;
    constructor() { owner = msg.sender }
    function deposit() public payable {}
    function withdraw() public { payable(msg.sender).transfer(address(this).balance); }
    function attack() public { }
}
