//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title SignatureReplay (INTENTIONALLY VULNERABLE)
 * @author Joash Kuteesa
 * @notice Demo contract for signature replay vulnerabilities
 *
 * EXPECTED:
 * - Auditor flags "signature replay/missing nonce" (and/or missing domain separation) in any function that accepts signatures for authorization.
 * - An attacker can replay a valid signature multiple times to perform unauthorized actions.
 *
 * VULNERABILITY:
 * - No nonce or timestamp is used to prevent replaying signatures.
 * - No domain separation is used, so signatures could potentially be replayed across different contexts.
 */
contract SignatureReplay {
    address public immutable I_SIGNER;
    mapping(address => uint256) public claimedTotal;

    error SignatureReplay__InvalidSignature();

    event Claimed(address indexed user, uint256 amount, uint256 newTotal);

    constructor(address trustedSigner) {
        require(trustedSigner != address(0), "Trusted signer cannot be zero address");
        I_SIGNER = trustedSigner;
    }

    /**
     * @notice Claim rewards by providing a valid signature from the trusted signer.
     * @param amount The amount to claim (must be > 0)
     * @param signature The signature from the trusted signer authorizing this claim
     */
    function claim(uint256 amount, bytes memory signature) public {
        require(amount > 0, "Amount must be greater than zero");

        bytes32 messageHash = keccak256(abi.encodePacked(msg.sender, amount));
        bytes32 ethSignedMessageHash = _toEthSignedMessageHash(messageHash);

        (bytes32 r, bytes32 s, uint8 v) = splitSignature(signature);
        address recoveredSigner = ecrecover(ethSignedMessageHash, v, r, s);
        if (recoveredSigner != I_SIGNER) {
            revert SignatureReplay__InvalidSignature();
        }

        claimedTotal[msg.sender] += amount;
        emit Claimed(msg.sender, amount, claimedTotal[msg.sender]);
    }

    function _toEthSignedMessageHash(bytes32 messageHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash));
    }

    function splitSignature(bytes memory sig) internal pure returns (bytes32 r, bytes32 s, uint8 v) {
        require(sig.length == 65, "Invalid signature length");
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
        if (v < 27) {
            v += 27;
        }
        return (r, s, v);
    }
}
