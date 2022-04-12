// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/math/SafeMath.sol';
import './interfaces/IUniswapV2Router02.sol';
import './interfaces/IWrappedUST.sol';
import './interfaces/IWrappedaUST.sol';
import './interfaces/ISushiSwapLPToken.sol';
import './Reserves.sol';

contract OneAnchor is Ownable {

    using SafeMath for uint;

    address private uniswapV2Router02;
    address private wONE;
    address private wUST;
    address private waUST;
    address private clONEUSD;
    address private clUSTaUST;
    address private reserves;
    address private sushiSwapLPToken;

    uint public stakedAmount;

    AggregatorV3Interface internal priceFeedOneUsd;
    AggregatorV3Interface internal priceFeedUstaUst;
    IUniswapV2Router02 internal router;
    IWrappedUST internal wust;
    IWrappedaUST internal waust;
    Reserves internal reserve;
    ISushiSwapLPToken internal lpToken;

    address[] path;
    uint[] deposits;
    uint[] withdrawals;
    uint totalDeposits;

    constructor() {
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
        wust = IWrappedUST(wUST);
        waust = IWrappedaUST(waUST);
        reserve = Reserves(reserves);
        lpToken = ISushiSwapLPToken(sushiSwapLPToken);

        path = new address[](2);
        path[0] = wONE;
        path[1] = wUST;
    }
    
    event Deposit(address indexed _from, uint _one, uint _aust);
    event Withdrawal(address indexed _from, uint _one, uint _ust);

    /*
     * This function allows users to send ONE and receive aUST
     */
    function deposit() public payable {
        uint value = msg.value;
        // Get total reserves of 
        (uint USTReserves,,) = lpToken.getReserves();
        require(USTReserves > 0, "There are not enough UST reserves in the Liquidity Pool");
        uint OneAmountInUST = uint(getExchangeRate(priceFeedOneUsd)).mul(USTReserves);
        require(OneAmountInUST < USTReserves, "There are not enough UST reserves in the Liquidity Pool");
        uint[] memory finalValues = router.swapExactETHForTokens{value: value}(1000, path, reserves, block.timestamp + 120 seconds);
        uint finalUSTValue = finalValues[1];
        stake(finalUSTValue);
        require(finalUSTValue > 0, "ONE/UST Failed");
        uint USTAmountInaUST = uint(getExchangeRate(priceFeedUstaUst)).mul(finalUSTValue);
        bool didPay = pay(msg.sender, uint(USTAmountInaUST), 0);
        require(didPay == true, "aUST were not transfer to the user");
        bool didTransfer = wust.transferFrom(address(this), reserves, finalUSTValue);
        require(didTransfer == true, "Deposited amount could not be transfered to reserves");
        emit Deposit(msg.sender, msg.value, USTReserves);
    }
    /*
     * This function allows users to send aUST and receive ONE
     * through oneAnchor
     */
    function withdrawal(uint amount) public payable {
        require(amount > 0, "Withdrawal amount must be greater than 0");
        totalDeposits -= amount;
        uint aUSTAmountInUST = uint(getExchangeRate(priceFeedUstaUst)).div(amount);
        bool didPay = pay(msg.sender, uint(aUSTAmountInUST), 1);
        require(didPay == true, "UST were not transfer to the user");
        emit Withdrawal(msg.sender, msg.value, aUSTAmountInUST);
    }
    /*
     * This function adds this deposit to the queue
     */
    function stake(uint amount) internal {
        totalDeposits += amount;
        deposits.push(amount);
    }
    /*
     * This function adds this deposit to the queue
     */
    function unstake(uint amount) internal {
        totalDeposits -= amount;
        withdrawals.push(amount);
    }
    /*
     * This function sends aUST after user deposits ONE
     */
    function pay(address to, uint amount, uint asset) internal returns (bool) {
        bool didTransfer = false;
        if (asset == 0) {
            didTransfer = waust.transferFrom(reserves, to, amount);
            return didTransfer;
        } else if (asset == 1) {
            didTransfer = wust.transferFrom(reserves, to, amount);
            return didTransfer;
        } else {
            return false;
        }
    }
    

    /**
     * Returns Pair exchange rate
     */
    function getExchangeRate(AggregatorV3Interface cl) public view returns (int) {
        (
            , 
            int price,
            ,
            ,
            
        ) = cl.latestRoundData();
        return price;
    }

    function sendViaCall(address payable _to, uint256 amount) internal {
        (bool sent, ) = _to.call{value: amount}("");
        require(sent, "Failed to send Ether");
    }

}