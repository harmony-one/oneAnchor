// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol';
import '@openzeppelin/contracts/access/Ownable.sol';


contract Reserves is Ownable {

    int private USTBalance;
    int private aUSTBalance;

    address private UST;
    address private aUST;

    int public exchangeRate;
    
    constructor() {
        USTBalance = 0;
        aUSTBalance = 0;
    }

    function addToUSTReserve(uint amount) external view onlyOwner {}

    function removeFromUSTReserve() external view onlyOwner {}


}