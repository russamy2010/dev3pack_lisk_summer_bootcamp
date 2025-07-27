// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// --- SafeMath Library ---
// @notice A library for performing safe arithmetic operations on uint256.
// Prevents integer overflows and underflows, which can lead to critical vulnerabilities.
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow"); // c must be greater than or equal to a if no overflow
        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on underflow (when the result would be negative).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction underflow"); // b must be less than or equal to a
        uint256 c = a - b;
        return c;
    }

    // You could also add mul, div, mod if needed for more complex math
    // For this simple vault, add and sub are sufficient.
}

// --- VaultBase Contract ---
// @notice Base contract defining common structure and shared logic for vault systems.
contract VaultBase {
    using SafeMath for uint256; // Use the SafeMath library for all uint256 operations

    // --- State Variables ---
    // @notice Mapping to store the Ether balance of each user.
    mapping(address => uint256) public balances;

    // @notice The address of the contract owner.
    address public owner;

    // --- Events ---
    // @notice Emitted when a user deposits Ether into the vault.
    event Deposit(address indexed user, uint256 amount);

    // @notice Emitted when a user withdraws Ether from the vault.
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

    // --- Shared Functions (can be overridden by derived contracts if needed) ---
    // @dev Returns the balance of a specific user.
    function getUserBalance(address _user) public view returns (uint256) {
        return balances[_user];
    }
}

// --- VaultManager Contract ---
// @notice Derived contract implementing deposit and withdraw functionalities.
contract VaultManager is VaultBase {
    /**
     * @dev Allows users to deposit Ether into the vault.
     * The function is payable, meaning it can receive Ether directly.
     * @notice Checks that the deposited amount is greater than zero.
     */
    function deposit() public payable {
        require(msg.value > 0, "Deposit amount must be greater than zero.");

        // Use SafeMath for addition to prevent overflow
        balances[msg.sender] = balances[msg.sender].add(msg.value);

        emit Deposit(msg.sender, msg.value);
    }

    /**
     * @dev Allows users to withdraw their deposited Ether from the vault.
     * @param _amount The amount of Ether to withdraw (in wei).
     * @notice Checks that the user has sufficient balance and the amount is greater than zero.
     */
    function withdraw(uint256 _amount) public {
        // Ensure the amount to withdraw is positive
        require(_amount > 0, "Withdrawal amount must be greater than zero.");
        // Ensure the user has sufficient balance
        require(balances[msg.sender] >= _amount, "Insufficient balance.");

        // Use SafeMath for subtraction to prevent underflow
        balances[msg.sender] = balances[msg.sender].sub(_amount);

        // Send Ether to the caller
        (bool success, ) = payable(msg.sender).call{value: _amount}("");
        require(success, "Failed to send Ether."); // Revert if Ether transfer fails

        emit Withdrawal(msg.sender, _amount);
    }

    /**
     * @dev Allows the owner to sweep all Ether from the contract.
     * Use with caution.
     */
    function withdrawAllFundsOwner() public onlyOwner {
        uint256 contractBalance = address(this).balance;
        require(contractBalance > 0, "Contract has no Ether to withdraw.");

        // Send all Ether to the owner
        (bool success, ) = payable(owner).call{value: contractBalance}("");
        require(success, "Failed to send Ether to owner.");

        // Note: Individual user balances in 'balances' mapping are not affected by this owner withdrawal.
        // This function is for sweeping the contract's total balance.
        // For a true "bank-like" system, this logic would need to be more sophisticated.
        emit Withdrawal(owner, contractBalance);
    }
}