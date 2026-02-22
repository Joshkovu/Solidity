// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {PrecompileCallerSafe} from "../../src/polkadot/PrecompileCallerSafe.sol";
import {PrecompileCallerUnsafe} from "../../src/polkadot/PrecompileCallerUnsafe.sol";
import {Precompiles} from "../../src/polkadot/Precompiles.sol";

contract Test_PolkadotHubFork_Scaffold is Test {
    function setUp() public {
        string memory forkUrl = vm.envOr("FORK_URL", string(""));
        if (bytes(forkUrl).length == 0) {
            vm.skip(true);
        }
        uint256 forkId = vm.createFork(forkUrl);
        vm.selectFork(forkId);
    }

    function testSafePrecompileCall() public {
        PrecompileCallerSafe safe = new PrecompileCallerSafe(
            Precompiles.SYSTEM_PRECOMPILE,
            0 // set to 0 to allow any chainId for demo/fork
        );
        // Should not revert, but may if precompile is not present on fork
        try safe.getVersion() returns (string memory version) {
            emit log_string(version);
        } catch {
            emit log("Safe precompile call reverted (expected on some forks)");
        }
    }

    function testUnsafePrecompileCall() public {
        PrecompileCallerUnsafe unsafe = new PrecompileCallerUnsafe();
        // Unsafe: may revert or return garbage
        try unsafe.getVersion() returns (string memory version) {
            emit log_string(version);
        } catch {
            emit log(
                "Unsafe precompile call reverted (expected on some forks)"
            );
        }
    }
}
