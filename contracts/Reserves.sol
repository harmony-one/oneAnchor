// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/access/AccessControl.sol';
import './interfaces/IWrappedaUST.sol';


contract Reserves is Ownable, AccessControl {

    bytes32 public constant OWNER_ROLE = keccak256("OWNER_ROLE");
    bytes32 public constant EARN_ROLE = keccak256("EARN_ROLE");

    IWrappedaUST internal waust;

    uint private USTBalance;
    uint private aUSTBalance;
    uint private ONEBalance;

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
    function addToUSTReserve(uint amount) internal {
        USTBalance += amount;
    }
    function removeFromUSTReserve(uint amount) internal {
        USTBalance -= amount;
    }
    function addToaUSTReserve(uint amount) internal {
        aUSTBalance += amount;
    }
    function removeFromaUSTReserve(uint amount) internal {
        aUSTBalance -= amount;
    }
    function addToONEReserve(uint amount) internal {
        ONEBalance += amount;
    }
    function removeFromONEReserve(uint amount) internal {
        ONEBalance -= amount;
    }
    /*
     * Get Reserve amounts.
     * Get the balance of the different assets balances
     */
    function getUSTBalance() external view returns (uint) {
        require(hasRole(OWNER_ROLE, msg.sender), "Caller does not have access to this function");
        return USTBalance;
    }
    function getaUSTBalance() external view returns (uint) {
        require(hasRole(OWNER_ROLE, msg.sender), "Caller does not have access to this function");
        return aUSTBalance;
    }
    function getONEBalance() external view returns (uint) {
        require(hasRole(OWNER_ROLE, msg.sender), "Caller does not have access to this function");
        return ONEBalance;
    }
    /*
     * Pay users.
     * Send assets to users
     */
    function payaUST(address to, uint amount) external returns (bool) {
        require(hasRole(OWNER_ROLE, msg.sender), "Caller does not own these reserves");
        bool didTransfer = waust.transferFrom(address(this), to, amount);
        require(didTransfer == true, "Payment failed");
        removeFromaUSTReserve(amount);
        return didTransfer;

    }
    function payONE(address to, uint amount) external returns (bool)  {
        require(hasRole(OWNER_ROLE, msg.sender), "Caller does not own these reserves");
        bool didTransfer = sendViaCall(payable(to), amount);
        require(didTransfer == true, "Payment failed");
        removeFromONEReserve(amount);
        return didTransfer;
    }
    /*
     * Pay users.
     * Send assets to users
     */
    function withdrawaUST(uint amount) external returns (bool) {
        require(hasRole(OWNER_ROLE, msg.sender), "Caller does not own these reserves");
        bool didTransfer = waust.transferFrom(address(this), earnAccount, amount);
        require(didTransfer == true, "Transfer failed");
        removeFromaUSTReserve(amount);
        return didTransfer;
    }
    function withdrawUST(uint amount) external returns (bool) {
        require(hasRole(OWNER_ROLE, msg.sender), "Caller does not own these reserves");
        bool didTransfer = waust.transferFrom(address(this), earnAccount, amount);
        require(didTransfer == true, "Transfer failed");
        removeFromaUSTReserve(amount);
        return didTransfer;
    }
    /*
     * Send ONEs to address.
     */
    function sendViaCall(address payable _to, uint256 amount) internal returns (bool) {
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
     * set the owner role (intended for oneAnchor contract)
     */
    function setOnwerRole(address owner) external onlyOwner {
        _setupRole(OWNER_ROLE, owner);
    }
}