// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol';
import './ubONE.sol';

contract Deposit {

    address public ubONEAddress;
    address public oneAnchor;

    uint public depositedAmount;
    int public exchangeRate;

    AggregatorV3Interface internal priceFeed;

    constructor() {
        priceFeed = AggregatorV3Interface(0xcEe686F89bc0dABAd95AEAAC980aE1d97A075FAD);
        oneAnchor = 0x8Dc67adCeCC140E12E838D185FDF4ebc2979B365;
        ubONEAddress = 0x8Dc67adCeCC140E12E838D185FDF4ebc2979B365;
    }

    /*
     * This function allows users to send ONE and receive ubONE
     */
    function deposit() public payable {
        depositedAmount += msg.value;
        int amount = int(msg.value) / exchangeRate;
        ubONE(ubONEAddress).mint(msg.sender, uint(amount));
        sendViaCall(payable(oneAnchor));
    }

    /*
     * This function allows users to send ubONE and receive ONE
     * through oneAnchor
     */
    function withdrawal(uint amount) public payable {
        depositedAmount -= amount;
        exchangeRate = getExchangeRate();
        int amount_in_one = int(msg.value) * exchangeRate;
        ubONE(ubONEAddress).transferFrom(msg.sender, address(this), amount);
        ubONE(ubONEAddress).burn(amount);
        payable(msg.sender).transfer(uint(amount_in_one));
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

    // Send ones
    function sendViaCall(address payable _to) public payable {
        // Call returns a boolean value indicating success or failure.
        // This is the current recommended method to use.
        (bool sent, ) = _to.call{value: msg.value}("");
        require(sent, "Failed to send ONE");
    }
}