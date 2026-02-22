// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title PrecompileCallerUnsafe - Example of unsafe precompile usage (for testing detection)
 * @author Joash Kuteesa
 * @notice This contract demonstrates an unsafe way to call a precompile, without proper checks or configurability.
 *         EXPECTED: auditor should flag this as an unsafe pattern for calling precompiles, especially compared to the safer version in PrecompileCallerSafe.
 */
contract PrecompileCallerUnsafe {
    // Hardcoded precompile address (bad)
    address constant SYSTEM_PRECOMPILE = 0x0000000000000000000000000000000000000900;

    function getVersion() external returns (string memory) {
        // Unsafe: low-level call, no proper success check, decodes without checking return length
        (bool success, bytes memory data) = SYSTEM_PRECOMPILE.call(abi.encodeWithSignature("version()"));
        require(success, "Precompile call failed");
        // BAD: does not check success or data length
        return abi.decode(data, (string));
    }
}
