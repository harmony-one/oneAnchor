// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/Context.sol';
import './interfaces/IWrappedaUST.sol';


contract Reserves is Context, Ownable {

    IWrappedaUST internal waust;

    uint private USTBalance;
    uint private aUSTBalance;

    address private UST;
    address private aUST;

    int public exchangeRate;

    
    constructor() {
        USTBalance = 0;
        aUSTBalance = 0;
    }

    function addToUSTReserve(uint amount) external view {}

    function removeFromUSTReserve() external view {}

    function getUSTBalance() external view returns (uint) {
        return USTBalance;
    }

    function payaUST(address to, uint amount) external returns (bool) {
        return waust.transferFrom(address(this), to, amount);
    }
    function payONE(address to, uint amount) external returns (bool)  {
        return sendViaCall(payable(to), amount);
    }

    function sendViaCall(address payable _to, uint256 amount) internal returns (bool) {
        (bool sent, ) = _to.call{value: amount}("");
        return sent;
    }


}