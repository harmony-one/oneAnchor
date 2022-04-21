// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/interfaces/IERC20Upgradeable.sol";
import "./ReserveDeclarations.sol";

contract ReserveDeclarations is OwnableUpgradeable {
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
    bytes32 public constant EARN_ROLE = keccak256("EARN_ROLE");

    IERC20Upgradeable wAUST;
    IERC20Upgradeable wUST;

    //Making these public will make it easier to write the operator bot
    //Also anyone could just call balanceOf(contractAddress) on the erc20 tokens that underly the reserves
    //So there really is no point in even obscuring it either
    uint256 public USTBalance;
    uint256 public aUSTBalance;
    uint256 public ONEBalance;

    mapping(address => int256) private balances;

    address private earnAccount;

}