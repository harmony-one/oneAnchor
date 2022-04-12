// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import './IUniswapV2Router02.sol';
import './Reserves.sol';
import './WrappedUST.sol';

contract Deposit is Ownable {

    address private uniswapV2Router02;
    address private wUST;
    address private wONE;
    address private chainLink;
    address private reserves;

    int public exchangeRate;

    AggregatorV3Interface internal priceFeed;
    IUniswapV2Router02 internal router;
    WrappedUST internal wust;
    Reserves internal reserve;

    constructor() {
        
        chainLink = 0xcEe686F89bc0dABAd95AEAAC980aE1d97A075FAD;
        uniswapV2Router02 = 0x8Dc67adCeCC140E12E838D185FDF4ebc2979B365;
        wUST = 0x224e64ec1BDce3870a6a6c777eDd450454068FEC;
        wONE = 0xcF664087a5bB0237a0BAd6742852ec6c8d69A27a;
        priceFeed = AggregatorV3Interface(chainLink);
        router = IUniswapV2Router02(uniswapV2Router02);
        wust = WrappedUST(wUST);
        reserve = Reserves(reserves);

        address[] memory path = new address[](2);
        path[0] = wONE;
        path[1] = wUST;
    }

   /*
     * This function allows users to send ONE and receive aUST
     */
    function deposit() public payable {
        address[] memory path = new address[](2);
        uint[] memory finalValues = router.swapExactETHForTokens{value: msg.value}(1000, path, reserves, block.timestamp + 120 seconds);
        uint finalUSTValue = finalValues[1];
        require(finalUSTValue != 0);
        bool didTRansfer = wust.transferFrom(address(this), reserves, finalUSTValue);
        require(didTRansfer == true);
        reserve.addToUSTReserve(finalUSTValue);
    }


    /*
     * This function allows users to send aUST and receive ONE
     * through oneAnchor
     */
    function withdrawal(uint amount) public payable {
        // depositedAmount -= amount;
        // exchangeRate = getExchangeRate();
        // int amount_in_one = int(msg.value) * exchangeRate;
        // ubONE(ubONEAddress).transferFrom(msg.sender, address(this), amount);
        // ubONE(ubONEAddress).burn(amount);
        // payable(msg.sender).transfer(uint(amount));
    }

    /**
     * Returns ONE/USD exchange rate
     */
    function getExchangeRate() public view returns (int) {
        (
            , 
            int price,
            ,
            ,
            
        ) = priceFeed.latestRoundData();
        return price;
    }

    function sendViaCall(address payable _to, uint256 amount) internal {
        (bool sent, ) = _to.call{value: amount}("");
        require(sent, "Failed to send Ether");
    }

}