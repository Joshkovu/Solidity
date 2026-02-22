// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title ISystemPrecompile - Interface for Polkadot Hub EVM System Precompile
 * @author Joash Kuteesa
 * @notice This interface defines the expected functions of the Polkadot Hub EVM System Precompile.
 *         EXPECTED: auditor should recognize this as a standard interface for interacting with the Polkadot system precompile, and understand its role in providing system-level information.
 */
interface ISystemPrecompile {
    function version() external view returns (string memory);

    function system_address() external view returns (address);
}
