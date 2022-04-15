// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/interfaces/IERC20Upgradeable.sol";

contract Reserves is OwnableUpgradeable, AccessControlUpgradeable {
    bytes32 public constant OWNER_ROLE = keccak256("OWNER_ROLE");
    bytes32 public constant EARN_ROLE = keccak256("EARN_ROLE");

    IERC20Upgradeable internal waust;

    uint256 private USTBalance;
    uint256 private aUSTBalance;
    uint256 private ONEBalance;

    mapping(address => int256) private balances;

    address private earnAccount;

    constructor() {
        USTBalance = 0;
        aUSTBalance = 0;
        ONEBalance = 0;
    }

    /*
     * Modify Reserve amounts.
     * Add or remove from the different assets balances
     */
    function addToUSTReserve(uint256 amount) internal {
        USTBalance += amount;
    }

    function removeFromUSTReserve(uint256 amount) internal {
        USTBalance -= amount;
    }

    function addToaUSTReserve(uint256 amount) internal {
        aUSTBalance += amount;
    }

    function removeFromaUSTReserve(uint256 amount) internal {
        aUSTBalance -= amount;
    }

    function addToONEReserve(uint256 amount) internal {
        ONEBalance += amount;
    }

    function removeFromONEReserve(uint256 amount) internal {
        ONEBalance -= amount;
    }

    /*
     * Get Reserve amounts.
     * Get the balance of the different assets balances
     */
    function getUSTBalance() external view returns (uint256) {
        require(
            hasRole(OWNER_ROLE, msg.sender),
            "Caller does not have access to this function"
        );
        return USTBalance;
    }

    function getaUSTBalance() external view returns (uint256) {
        require(
            hasRole(OWNER_ROLE, msg.sender),
            "Caller does not have access to this function"
        );
        return aUSTBalance;
    }

    function getONEBalance() external view returns (uint256) {
        require(
            hasRole(OWNER_ROLE, msg.sender),
            "Caller does not have access to this function"
        );
        return ONEBalance;
    }

    /*
     * Pay users.
     * Send assets to users when they deposit
     */
    function payaUST(address to, uint256 amount) external returns (bool) {
        require(
            hasRole(OWNER_ROLE, msg.sender),
            "Caller does not own these reserves"
        );
        bool didTransfer = waust.transferFrom(address(this), to, amount);
        require(didTransfer == true, "Payment failed");
        removeFromaUSTReserve(amount);
        return didTransfer;
    }

    function payONE(address to, uint256 amount) external returns (bool) {
        require(
            hasRole(OWNER_ROLE, msg.sender),
            "Caller does not own these reserves"
        );
        bool didTransfer = sendViaCall(payable(to), amount);
        require(didTransfer == true, "Payment failed");
        removeFromONEReserve(amount);
        return didTransfer;
    }

    /*
     * Pay users.
     * Send assets to users when they withdraw
     */
    function withdrawaUST(uint256 amount) external returns (bool) {
        require(
            hasRole(OWNER_ROLE, msg.sender),
            "Caller does not own these reserves"
        );
        bool didTransfer = waust.transferFrom(
            address(this),
            earnAccount,
            amount
        );
        require(didTransfer == true, "Transfer failed");
        removeFromaUSTReserve(amount);
        return didTransfer;
    }

    function withdrawUST(uint256 amount) external returns (bool) {
        require(
            hasRole(OWNER_ROLE, msg.sender),
            "Caller does not own these reserves"
        );
        bool didTransfer = waust.transferFrom(
            address(this),
            earnAccount,
            amount
        );
        require(didTransfer == true, "Transfer failed");
        removeFromaUSTReserve(amount);
        return didTransfer;
    }

    /*
     * Update Accountholders balances
     */
    function updateBalance(address account, int256 amount) public {
        balances[account] += amount;
    }

    /*
     * Send ONEs to address.
     */
    function sendViaCall(address payable _to, uint256 amount)
        internal
        returns (bool)
    {
        (bool sent, ) = _to.call{value: amount}("");
        return sent;
    }

    /**
     * set the account that will deposit into Anchor Earn
     */
    function setEarnAddress(address account) external onlyOwner {
        earnAccount = account;
    }

    /**
     * Return `true` if the `account` belongs to the community.
     */
    function isMember(address account) public view virtual returns (bool) {
        return hasRole(OWNER_ROLE, account);
    }

    /**
     * set the owner role (intended for oneAnchor contract)
     */
    function setOnwerRole(address owner) external onlyOwner {
        _setupRole(OWNER_ROLE, owner);
    }
}
