// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "./interfaces/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

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


contract Reserve is AccessControlUpgradeable, OwnableUpgradeable, ReentrancyGuardUpgradeable {

    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");

    IERC20Upgradeable wAUST;
    IERC20Upgradeable wUST;

    //Making these public will make it easier to write the operator bot
    //Also anyone could just call balanceOf(contractAddress) on the erc20 tokens that underly the reserves
    //So there really is no point in even obscuring it either
    uint256 public USTBalance;
    uint256 public aUSTBalance;

    event Payment(address indexed _to, string asset, uint256 _amount);
    event TransferToReserve(address indexed _from, string asset, uint256 _amount);
    event OperatorWithdraw(address indexed _to, string asset, uint256 _amount);
    event OperatorDeposit(address indexed _to, string asset, uint256 _amount);
    event SentOne(address indexed _to, uint256 _amount);
    event OperatorRoleSet(address indexed _to);

    modifier onlyOperator() {
        require(
            hasRole(OPERATOR_ROLE, msg.sender),
            "Caller is not an Operator"
        );
        _;
    }
    function __Reserve_init(address _wAUST, address _wUST)
        internal
        onlyInitializing
    {
        __Ownable_init();
        __ReentrancyGuard_init();
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
    /*
     * Pay users.
     * Send assets to users when they deposit
     */
    function payAUST(address to, uint256 amount) internal returns (bool) {
        bool didTransfer = wAUST.transferFrom(address(this), to, amount);
        require(didTransfer == true, "Payment failed");
        removeFromaUSTReserve(amount);
        emit Payment(to, "aust", amount);
        return didTransfer;
    }
    function payUST(address to, uint256 amount) internal returns (bool) {
        bool didTransfer = wUST.transferFrom(address(this), to, amount);
        require(didTransfer == true, "Payment failed");
        removeFromaUSTReserve(amount);
        emit Payment(to, "ust", amount);
        return didTransfer;
    }
    function takeAUST(address from, uint256 amount) internal returns (bool) {
        bool didTransfer = wAUST.transferFrom(from, address(this), amount);
        require(didTransfer == true, "Payment failed");
        addToaUSTReserve(amount);
        emit TransferToReserve(from, "aust", amount);
        return didTransfer;
    }
    function takeUST(address from, uint256 amount) internal returns (bool) {
        bool didTransfer = wUST.transferFrom(from, address(this), amount);
        require(didTransfer == true, "Payment failed");
        addToUSTReserve(amount);
        emit TransferToReserve(from, "ust", amount);
        return didTransfer;
    }

    function withdrawUSTOperator(uint256 amount, bytes32 terraAddress)
        external
        onlyOperator
        returns (bool)
    {
        wUST.burn(
            amount,
            terraAddress
        );
        removeFromUSTReserve(amount);
        emit OperatorWithdraw(address(uint160(uint256(terraAddress))), "ust", amount);
        return true;
    }
    function withdrawAUSTOperator(uint256 amount, bytes32 terraAddress)
        external
        onlyOperator
        returns (bool)
    {
        wAUST.burn(
            amount,
            terraAddress
        );
        removeFromaUSTReserve(amount);
        emit OperatorWithdraw(address(uint160(uint256(terraAddress))), "aust", amount);
        return true;
    }
    //These deposit functions will require that the operators have approved this contract
    function depositUSTOperator(uint256 amount)
        external
        onlyOperator
        returns (bool)
    {
        bool didTransfer = wUST.transferFrom(
            msg.sender,
            address(this),
            amount
        );
        require(didTransfer == true, "Transfer failed");
        addToUSTReserve(amount);
        emit OperatorDeposit(msg.sender, "ust", amount);
        return didTransfer;
    }
    function depositAUSTOperator(uint256 amount)
        external
        onlyOperator
        returns (bool)
    {
        bool didTransfer = wUST.transferFrom(
            msg.sender,
            address(this),
            amount
        );
        require(didTransfer == true, "Transfer failed");
        addToaUSTReserve(amount);
        emit OperatorDeposit(msg.sender, "aust", amount);
        return didTransfer;
    }
    /*
     * Send ONEs to address.
     */
    function sendViaCall(address payable _to, uint256 _amount)
        internal
        returns (bool)
    {
        (bool sent, ) = _to.call{value: _amount}("");
        emit SentOne(_to, _amount);
        return sent;
    }
    /**
     * Return `true` if the `account` belongs to the community.
     */
    function isOperator(address account) public view returns (bool) {
        return hasRole(OPERATOR_ROLE, account);
    }
    /**
     * set the owner role (intended for oneAnchor contract)
     */
    function setOperatorRole(address owner) external onlyOwner {
        _setupRole(OPERATOR_ROLE, owner);
        emit OperatorRoleSet(owner);
    }
}
