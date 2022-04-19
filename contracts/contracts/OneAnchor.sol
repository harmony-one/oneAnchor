// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/interfaces/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "./interfaces/IUniswapV2Router02.sol";
import "./interfaces/ISushiSwapLPToken.sol";
import "./Reserve.sol";

contract OneAnchor is OwnableUpgradeable, AccessControlUpgradeable {
    using SafeMathUpgradeable for uint256;

    address private uniswapV2Router02;
    address private wONE;
    address private wUST;
    address private waUST;
    address private clONEUSD;
    address private clUSTaUST;
    address private reserves;
    address private sushiSwapLPToken;

    uint256 public stakedAmount;

    AggregatorV3Interface internal priceFeedOneUsd;
    AggregatorV3Interface internal priceFeedUstaUst;
    IUniswapV2Router02 internal router;
    IERC20Upgradeable internal wust;
    IERC20Upgradeable internal waust;
    Reserve internal reserve;
    ISushiSwapLPToken internal lpToken;

    address[] path;
    uint256[] deposits;
    uint256[] withdrawals;

    bytes32 public constant CLEARING_ROLE = keccak256("CLEARING_ROLE");

    function __OneAnchor_init(address _reserve) external onlyInitializing {
        __Ownable_init();
        // addresses
        clONEUSD = 0xcEe686F89bc0dABAd95AEAAC980aE1d97A075FAD;
        clUSTaUST = 0xcEe686F89bc0dABAd95AEAAC980aE1d97A075FAD;
        uniswapV2Router02 = 0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506;
        wUST = 0x224e64ec1BDce3870a6a6c777eDd450454068FEC;
        wONE = 0xcF664087a5bB0237a0BAd6742852ec6c8d69A27a;
        sushiSwapLPToken = 0x4dABF6C57A8beA012F1EAa1259Ceed2a62AC7df2;
        //contracts
        priceFeedOneUsd = AggregatorV3Interface(clONEUSD);
        priceFeedUstaUst = AggregatorV3Interface(clUSTaUST);
        router = IUniswapV2Router02(uniswapV2Router02);
        wust = IERC20Upgradeable(wUST);
        waust = IERC20Upgradeable(waUST);
        reserve = Reserve(_reserve);
        lpToken = ISushiSwapLPToken(sushiSwapLPToken);

        path = new address[](2);
        path[0] = wONE;
        path[1] = wUST;
    }

    event Deposit(address indexed _from, uint256 _one, uint256 _aust);
    event Withdrawal(address indexed _from, uint256 _one, uint256 _ust);

    // TODO: add clearing and payments events

    /*
     * This function allows users to send ONE and receive aUST
     */
    function deposit() public payable {
        uint256 value = msg.value;
        // Get UST Reserves in LP
        (uint256 USTReserves, , ) = lpToken.getReserves();
        require(
            USTReserves > 0,
            "There are not enough UST reserves in the Liquidity Pool"
        );
        // Get the amount of UST being deposited and check that
        // there are enough reserves to clear the transacion
        uint256 OneAmountInUST = uint256(getExchangeRate(priceFeedOneUsd)).mul(
            value
        );
        //This require wont tell the full story since slippage will move the pool when a swap happens
        //But it seems to be ok since there is a later require for this
        require(
            OneAmountInUST < USTReserves,
            "There are not enough UST reserves in the Liquidity Pool"
        );
        // Swap ONE for wrapped UST in Sushi
        // Why are we hard coding our min out to 1000? I guess its in wei so it wont really matter but still
        // Since reserves is the to value tokens will get transfered directly to reserves contract
        uint256[] memory finalValues = router.swapExactETHForTokens{
            value: value
        }(1000, path, reserves, block.timestamp + 120 seconds);
        uint256 finalUSTValue = finalValues[1];

        //Replace the check for above 0 with this, check for minimum of 75% of expected UST value swapped
        require(
            finalUSTValue * 75 / 100 >  OneAmountInUST,
            "Slippage on Swap Too Large"
        );

        // Calculate the number of aUST that must be sent to the user
        // to the user and send them to it
        uint256 USTAmountInaUST = uint256(getExchangeRate(priceFeedUstaUst))
            .mul(finalUSTValue);
        bool didPay = pay(msg.sender, uint256(USTAmountInaUST), 0);
        require(didPay == true, "aUST were not transfer to the user");
        // move the USTs to the reserves contract
        bool didTransfer = wust.transferFrom(
            address(this),
            reserves,
            finalUSTValue
        );
        require(
            didTransfer == true,
            "Deposited amount could not be transfered to reserves"
        );
        // add the deposited amount to th stake queue
        stake(msg.sender, int256(finalUSTValue));
        // emit the event
        emit Deposit(msg.sender, msg.value, USTReserves);
    }

    /*
     * This function allows users to send aUST and receive ONE
     * through oneAnchor
     */
    function withdrawal(uint256 amount) public payable {
        require(amount > 0, "Withdrawal amount must be greater than 0");
        // Get aUST Reserves in LP
        (, uint256 aUSTReserves, ) = lpToken.getReserves();
        require(
            aUSTReserves > 0,
            "There are not enough aUST reserves in the Liquidity Pool"
        );
        // Calculate the number of ONEs that must be sent to user
        // and send them to it
        uint256 aUSTAmountInUST = uint256(getExchangeRate(priceFeedUstaUst))
            .div(amount);
        uint256 aUSTAmountInONE = uint256(getExchangeRate(priceFeedOneUsd)).div(
            aUSTAmountInUST
        );
        bool didPay = pay(msg.sender, uint256(aUSTAmountInONE), 1);
        require(didPay == true, "ONE were not transfer to the user");
        // move the aUSTs to the reserves contract
        bool didTransfer = waust.transferFrom(address(this), reserves, amount);
        require(
            didTransfer == true,
            "Deposited amount could not be transfered to reserves"
        );
        // add the deposited amount to th stake queue
        unstake(msg.sender, int256(amount));
        // emit the event
        emit Withdrawal(msg.sender, msg.value, aUSTAmountInUST);
    }

    /*
     * This function adds this deposit to the queue
     */
    function stake(address account, int256 amount) internal {
        deposits.push(uint256(amount));
        reserve.updateBalance(account, amount);
    }

    /*
     * This function adds this deposit to the queue
     */
    function unstake(address account, int256 amount) internal {
        withdrawals.push(uint256(amount));
        reserve.updateBalance(account, -1 * amount);
    }

    /*
     * This function sends aUST after user deposits ONE
     */
    function pay(
        address to,
        uint256 amount,
        uint256 asset
    ) internal returns (bool) {
        bool didTransfer = false;
        if (asset == 0) {
            didTransfer = reserve.payaUST(to, amount);
            return didTransfer;
        } else if (asset == 1) {
            didTransfer = reserve.payONE(to, amount);
            return didTransfer;
        } else {
            return false;
        }
    }

    /**
     * Returns Pair exchange rate
     */
    function getExchangeRate(AggregatorV3Interface cl)
        internal
        view
        returns (int256)
    {
        (, int256 price, , , ) = cl.latestRoundData();
        return price;
    }

    /**
     * get the value of the next transaction in the queue
     */
    function getNextTransaction(uint256 action)
        external
        view
        returns (uint256)
    {
        require(
            hasRole(CLEARING_ROLE, msg.sender),
            "Caller cannot access this information"
        );
        if (action == 0) {
            return deposits[0];
        } else if (action == 1) {
            return withdrawals[0];
        } else {
            return 0;
        }
    }

    /**
     * clear the next transaction in the queue
     */
    function clearNextTransaction(uint256 action) external {
        require(
            hasRole(CLEARING_ROLE, msg.sender),
            "Caller cannot clear transactions"
        );
        if (action == 0) {
            reserve.withdrawUST(deposits[0]);
        } else if (action == 1) {
            reserve.withdrawaUST(deposits[0]);
        }
        dequeue(action);
    }

    /**
     * remove a transaction fro the queue
     */
    function dequeue(uint256 action) internal {
        if (action == 0) {
            delete deposits[0];
        }
        if (action == 1) {
            delete withdrawals[0];
        }
    }

    /**
     * Return `true` if the `account` belongs to the community.
     */
    function isMember(address account) public view virtual returns (bool) {
        return hasRole(CLEARING_ROLE, account);
    }

    /**
     * set the clearing role (intended for reserves contract)
     */
    function setClearingRole(address admin) external onlyOwner {
        _setupRole(CLEARING_ROLE, admin);
    }
}
