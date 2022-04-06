// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import './ubONE.sol';

contract Deposit is Ownable {

    address private ubONEAddress;
    address private oneAnchor;

    uint public depositedAmount;
    int public exchangeRate;

    AggregatorV3Interface internal priceFeed;

    constructor() {
        priceFeed = AggregatorV3Interface(0xcEe686F89bc0dABAd95AEAAC980aE1d97A075FAD);
        oneAnchor = 0x8Dc67adCeCC140E12E838D185FDF4ebc2979B365;
    }

   /*
     * This function allows users to send ONE and receive ubONE
     */
    function deposit() public payable {
        depositedAmount += msg.value;
        // int amount = int(msg.value) / exchangeRate;
        mint(msg.sender, msg.value);
        sendViaCall(payable(oneAnchor),msg.value);
    }

    function mint(address to, uint amount) internal {
        ubONE token = ubONE(ubONEAddress);
        token.mint(to, amount);
    }

    /*
     * This function allows users to send ubONE and receive ONE
     * through oneAnchor
     */
    function withdrawal(uint amount) public payable {
        depositedAmount -= amount;
        // exchangeRate = getExchangeRate();
        // int amount_in_one = int(msg.value) * exchangeRate;
        ubONE(ubONEAddress).transferFrom(msg.sender, address(this), amount);
        ubONE(ubONEAddress).burn(amount);
        payable(msg.sender).transfer(uint(amount));
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

    function setubONEAddress(address a) public onlyOwner {
        ubONEAddress = a;
    }

    function getubONEAddress() public virtual view onlyOwner returns (address) {
        return ubONEAddress;
    }
}