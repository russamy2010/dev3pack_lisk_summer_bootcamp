// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//Create src/SafeMath.sol
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction underflow");
        uint256 c = a - b;
        return c;
    }
}

//Create src/PiggyBank.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SafeMath.sol"; // Import the SafeMath library

/**
 * @title PiggyBank
 * @dev A secure contract for depositing and withdrawing Ether,
 * addressing common vulnerabilities.
 */
contract PiggyBank {
    using SafeMath for uint256; // Apply SafeMath to all uint256 operations

    // --- State Variables ---
    // @notice The address of the contract owner.
    address public owner;

    // @notice Mapping to store the Ether balance of each user.
    mapping(address => uint256) public balances;

    // --- Events ---
    // @notice Emitted when a user deposits Ether into the piggy bank.
    event Deposit(address indexed user, uint256 amount);

    // @notice Emitted when a user withdraws Ether from the piggy bank.
    event Withdrawal(address indexed user, uint256 amount);

    // --- Modifiers ---
    // @notice Restricts a function call to only the contract owner.
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function.");
        _; // Placeholder for the function body
    }

    // --- Constructor ---
    // @notice Sets the deployer of the contract as the owner.
    constructor() {
        owner = msg.sender;
    }

    // --- Functions ---

    /**
     * @dev Allows users to deposit Ether into the piggy bank.
     * The function is payable, meaning it can receive Ether directly.
     * @notice Ensures the deposited amount is greater than zero.
     */
    function deposit() public payable {
        // Security Fix 1: Prevent 0 Ether deposits
        require(msg.value > 0, "Deposit amount must be greater than zero.");

        // Security Fix 2: Track individual user balances using SafeMath
        balances[msg.sender] = balances[msg.sender].add(msg.value);

        emit Deposit(msg.sender, msg.value);
    }

    /**
     * @dev Allows a user to withdraw their deposited Ether from the piggy bank.
     * @param _amount The amount of Ether to withdraw (in wei).
     * @notice Checks that the user has sufficient balance and the amount is greater than zero.
     * @notice Ensures only the owner can withdraw all contract funds (via a separate function).
     */
    function withdraw(uint256 _amount) public {
        // Security Fix 3: Ensure withdrawal amount is positive
        require(_amount > 0, "Withdrawal amount must be greater than zero.");
        // Security Fix 4: Prevent arbitrary withdrawal - ensure user has sufficient balance
        require(balances[msg.sender] >= _amount, "Insufficient balance.");

        // Security Fix 5: Update user balance before sending Ether (prevents re-entrancy in some cases)
        // Use SafeMath for subtraction
        balances[msg.sender] = balances[msg.sender].sub(_amount);

        // Security Best Practice: Use .call{} for sending Ether
        // It's the recommended way in modern Solidity for its flexibility and gas forwarding.
        // It also returns a boolean indicating success/failure.
        (bool success, ) = payable(msg.sender).call{value: _amount}("");
        require(success, "Failed to send Ether."); // Revert if Ether transfer fails

        emit Withdrawal(msg.sender, _amount);
    }

    /**
     * @dev Allows the owner to sweep any remaining Ether from the contract.
     * This function should be used cautiously, primarily for recovering stuck funds or
     * in scenarios where the contract is being decommissioned.
     * This does NOT affect individual user balances tracked in `balances`.
     */
    function ownerWithdrawAllContractFunds() public onlyOwner {
        uint256 contractBalance = address(this).balance;
        require(contractBalance > 0, "Contract has no Ether to withdraw.");

        // Send all Ether to the owner
        (bool success, ) = payable(owner).call{value: contractBalance}("");
        require(success, "Failed to send Ether to owner.");

        emit Withdrawal(owner, contractBalance);
    }

    /**
     * @dev Public getter function to check a user's deposited balance.
     * @param _user The address of the user whose balance to query.
     * @return The balance of the specified user in wei.
     */
    function getUserBalance(address _user) public view returns (uint256) {
        return balances[_user];
    }
}