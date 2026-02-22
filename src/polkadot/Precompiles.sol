// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title Precompiles - Polkadot Hub EVM Precompile Addresses
 * @author Joash Kuteesa
 * @notice EXPECTED: auditor should detect usage of precompiles and flag unsafe patterns in unsafe contracts.
 @dev SYSTEM_PRECOMPILE is Polkadot-specific. Standard EVM precompiles (1..9) included for reference.
 */
library Precompiles {
    // Polkadot System Precompile (Polkadot Hub EVM)
    address constant SYSTEM_PRECOMPILE =
        0x0000000000000000000000000000000000000900;

    // Standard EVM precompiles (for reference)
    address constant EC_RECOVER = 0x0000000000000000000000000000000000000001;
    address constant SHA256 = 0x0000000000000000000000000000000000000002;
    address constant RIPEMD160 = 0x0000000000000000000000000000000000000003;
    address constant IDENTITY = 0x0000000000000000000000000000000000000004;
    address constant MODEXP = 0x0000000000000000000000000000000000000005;
    address constant BN128ADD = 0x0000000000000000000000000000000000000006;
    address constant BN128MUL = 0x0000000000000000000000000000000000000007;
    address constant BN128PAIR = 0x0000000000000000000000000000000000000008;
    address constant BLAKE2F = 0x0000000000000000000000000000000000000009;
}
