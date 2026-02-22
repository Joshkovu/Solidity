// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Precompiles} from "./Precompiles.sol";

/**
 * @title PrecompileCallerSafe
 * @author Joash Kuteesa
 * @notice This contract demonstrates a safer way to call a precompile, with proper checks and configurability.
 *         EXPECTED: auditor should recognize this as a safer pattern for calling precompiles compared to the unsafe version.
 */
contract PrecompileCallerSafe {
    address public immutable systemPrecompile;
    uint256 public immutable expectedChainId;

    constructor(address _systemPrecompile, uint256 _expectedChainId) {
        systemPrecompile = _systemPrecompile;
        expectedChainId = _expectedChainId;
    }

    function getVersion() external view returns (string memory) {
        // Optionally gate by chainId (configurable for local/fork tests)
        require(expectedChainId == 0 || block.chainid == expectedChainId, "Wrong chain");

        (bool success, bytes memory data) = systemPrecompile.staticcall(abi.encodeWithSignature("version()"));
        require(success, "Precompile call failed");
        require(data.length >= 32, "Invalid return data");
        return abi.decode(data, (string));
    }
}
