// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/interfaces/IERC20Upgradeable.sol";

/*
    So what we essentially want is a service that will migrate UST to tera and
    return with aUST, and the opposite, take aUST from harmony, bridge to tera and return
    with UST.

    2 ways to accomplish this
    1. individual model, operators move funds equal to users requests, then return later with
        the funds and the tokens get transferred to the users.

    2. Some sort of liquidity model, where there are UST and aUST in the pool, and
        the operators go back and forth as the ratio changes
        this is basically the same as a normal dex liquidity pool with incentives, so
        this probably is not what we need here since that already exists

    So then with #1, we need to keep track of all desired orders and track when and how
    they get furfilled.

    So then control flow could work like this : Operator takes a batch of requests,
    takes either UST or aUST, migrates to tera, then returns with the other asset

    We could even build in an internal order book system to just settle people who want
    UST with aUST and vice versa with each other, provided sufficient volume
        -Maybe just leave that to the dexes

*/


contract Reserve is AccessControlUpgradeable, OwnableUpgradeable {

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

    modifier onlyOperator() {
        require(
            hasRole(OPERATOR_ROLE, msg.sender),
            "Caller is not an Operator"
        );
        _;
    }

    constructor(address _wAUST, address _wUST)
    {
        __Ownable_init();
        wAUST = IERC20Upgradeable(_wAUST);
        wUST = IERC20Upgradeable(_wUST);
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
     * Pay users.
     * Send assets to users when they deposit
     */
    function payaUST(address to, uint256 amount) external onlyOperator returns (bool) {
        bool didTransfer = wAUST.transferFrom(address(this), to, amount);
        require(didTransfer == true, "Payment failed");
        removeFromaUSTReserve(amount);
        return didTransfer;
    }

    function payONE(address to, uint256 amount) external onlyOperator returns (bool) {
        bool didTransfer = sendViaCall(payable(to), amount);
        require(didTransfer == true, "Payment failed");
        removeFromONEReserve(amount);
        return didTransfer;
    }

    function withdrawUSTOperator(uint256 amount)
        external
        onlyOperator
        returns (bool)
    {
        bool didTransfer = wUST.transferFrom(
            address(this),
            msg.sender,
            amount
        );
        require(didTransfer == true, "Transfer failed");

        removeFromUSTReserve(amount);
        return didTransfer;
    }

    function withdrawAUSOperatorT(uint256 amount)
        external
        onlyOperator
    {

    }

    function depositUSTOperator(uint256 amount)
        external
        onlyOperator
    {

    }

    function depositAUSTOperator(uint256 amount)
        external
        onlyOperator
    {

    }

    /*
     * Pay users.
     * Send assets to users when they withdraw
     */
    function withdrawaUST(uint256 amount)
        external
        onlyOperator
        returns (bool)
    {
        bool didTransfer = wAUST.transferFrom(
            address(this),
            earnAccount,
            amount
        );
        require(didTransfer == true, "Transfer failed");
        removeFromaUSTReserve(amount);
        return didTransfer;
    }

    function withdrawUST(uint256 amount)
        external
        onlyOperator
        returns (bool)
    {
        bool didTransfer = wAUST.transferFrom(
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
        return hasRole(OPERATOR_ROLE, account);
    }

    /**
     * set the owner role (intended for oneAnchor contract)
     */
    function setOperatorRole(address owner) external onlyOwner {
        _setupRole(OPERATOR_ROLE, owner);
    }
}
