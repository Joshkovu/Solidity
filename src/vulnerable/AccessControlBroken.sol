// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

/**
 * @title AccessControlBroken
 * @author Joash Kuteesa
 * @notice  Demo contract for missing access control
 *
 * EXPECTED:
 * - Auditor flags "missing access control" on any function that modifies state without proper access restrictions.
 * - An attacker can call these functions to perform unauthorized actions, such as adding themselves as an
 *
 * VULNERABILITY:
 * - No access control is implemented on addAdmin and removeAdmin functions, allowing anyone to add or remove admins.
 * - This can lead to unauthorized users gaining admin privileges or removing legitimate admins,
 */

contract AccessControlBroken {
    address public admin;

    event AdminChanged(address indexed oldAdmin, address indexed newAdmin);
    event Deposited(address indexed from, uint256 amount);
    event Withdrawn(address indexed to, uint256 amount);

    constructor() {
        admin = msg.sender;
    }

    receive() external payable {
        emit Deposited(msg.sender, msg.value);
    }

    function deposit() external payable {
        require(msg.value > 0, "zero deposit");
        emit Deposited(msg.sender, msg.value);
    }

    /**
     *
     * @param newAdmin Vulnerability : Anyone can become an admin
     */

    function setAdmin(address newAdmin) external {
        require(newAdmin != address(0), "zero admin");
        emit AdminChanged(admin, newAdmin);
        admin = newAdmin;
    }

    /**
     *
     * @param to This allows one to withdraw their money from the vault
     */
    function withdrawAll(address payable to) external {
        require(msg.sender == admin, "not admin");
        require(to != address(0), "zero to");

        uint256 bal = address(this).balance;
        require(bal > 0, "empty");
        (bool ok, ) = to.call{value: bal}("");
        require(ok, "transfer failed");

        emit Withdrawn(to, bal);
    }

    function contractBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
