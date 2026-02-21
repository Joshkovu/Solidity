// SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;

/**
 * @title Reentrancy Vault (INTENTIONALLY VULNERABLE)
 * @author Joash Kuteesa
 * @notice This contract is a training/demo target for an auditor
 *
 * EXPECTED:
 * - Static analyzers (Slither) should flag reentrancy
 * - The attacker can drain more ETH than they deposited by re-entering withdraw().
 *
 * VULNERABILITY:
 * - External call is made Before updating user balance.
 * - Uses call.value() which forwards all available gas, allowing the attacker to re-enter the withdraw function and drain the contract.
 */

contract ReentrancyVault {
    mapping(address => uint256) public userBalances;

    error ReentrancyVault__DepositMustBeGreaterThanZero();

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);

    function deposit() external payable {
        if (msg.value > 0) {
            revert ReentrancyVault__DepositMustBeGreaterThanZero();
        }
        userBalances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 _amount) external {
        require(_amount > 0, "Withdraw amount must be greater than zero");
        uint256 balance = userBalances[msg.sender];
        require(balance >= _amount, "Insufficient balance");
        // Vulnerable external call
        (bool success, ) = msg.sender.call{value: _amount}("");
        require(success, "Transfer failed");
        // Update user balance after the external call (vulnerable to reentrancy)
        userBalances[msg.sender] = balance - _amount;
        emit Withdraw(msg.sender, _amount);
    }

    function vaultBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
