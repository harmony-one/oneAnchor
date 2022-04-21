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

//On solidity 8 and above safe math is build in so no need for .(operation) functions
//Use unchecked if you want to not use safemath

contract OneAnchor is Reserve {
    using SafeMathUpgradeable for uint256;

    address private uniswapV2Router02;
    address private wONE;
    address private clONEUSD;
    address private clUSTaUST;
    address private sushiSwapLPToken;

    AggregatorV3Interface internal priceFeedOneUsd;
    AggregatorV3Interface internal priceFeedUstaUst;
    IUniswapV2Router02 internal router;
    ISushiSwapLPToken internal lpToken;

    address[] path;

    //should an initializing function be external?
    function __OneAnchor_init() external onlyInitializing {
        // addresses
        clONEUSD = 0xcEe686F89bc0dABAd95AEAAC980aE1d97A075FAD;
        clUSTaUST = 0xcEe686F89bc0dABAd95AEAAC980aE1d97A075FAD; //Same address as above?
        uniswapV2Router02 = 0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506;
        wONE = 0xcF664087a5bB0237a0BAd6742852ec6c8d69A27a;
        sushiSwapLPToken = 0x4dABF6C57A8beA012F1EAa1259Ceed2a62AC7df2;
        //contracts
        priceFeedOneUsd = AggregatorV3Interface(clONEUSD);
        priceFeedUstaUst = AggregatorV3Interface(clUSTaUST);
        router = IUniswapV2Router02(uniswapV2Router02);
        /*
        ** Remove these if we go with OneAnchor inheriting reserve
        wust = IERC20Upgradeable(wUST);
        waust = IERC20Upgradeable(waUST); //waUST does not seem to exist here
        reserve = Reserve(_reserve);
        */

        __Reserve_init(
            0x224e64ec1BDce3870a6a6c777eDd450454068FEC, //Ust Address
            0x0000000000000000000000000000000000000000 //@TODO find real waust address here
        );

        lpToken = ISushiSwapLPToken(sushiSwapLPToken);

        path = new address[](2);
        path[0] = wONE;
        path[1] = address(wUST);
    }

    event Deposit(address indexed _from, uint256 _one, uint256 _aust);
    event Withdrawal(address indexed _from, uint256 _one, uint256 _ust);

    // TODO: add clearing and payments events

    /*
    * This function allows users to send ONE and receive aUST
    * Swap ONE for UST on DEX
    * Swap UST for aUST using this pool
     */
    function deposit() public payable nonReentrant{
        uint256 value = msg.value;
        // Get UST Reserves in LP
        (uint256 USTReserves, , ) = lpToken.getReserves();
        require(
            USTReserves > 0,
            "There are not enough UST reserves in the Liquidity Pool"
        );
        // Get the amount of UST being deposited and check that
        // there are enough reserves to clear the transacion
        uint256 OneAmountInUST = getForwardValueFromOracle(value, priceFeedOneUsd);
        //This require wont tell the full story since slippage will move the pool when a swap happens
        //But it seems to be ok since there is a later require for this
        require(
            OneAmountInUST < USTReserves,
            "There are not enough UST reserves in the Liquidity Pool"
        );
        // Swap ONE for wrapped UST in Sushi
        // Set min out to 95% of value
        uint256[] memory finalValues = router.swapExactETHForTokens{
            value: value
        }(
            finalUSTValue * 95 / 100,
            path,
            address(this),
            block.timestamp + 120 seconds
        );
        uint256 finalUSTValue = finalValues[1];

        //Double check slippage, probably redundant
        require(
            finalUSTValue * 95 / 100 >  OneAmountInUST,
            "Slippage on Swap Too Large"
        );

        // Calculate the number of aUST that must be sent to the user
        // to the user and send them to it
        uint256 USTAmountInaUST = getBackwardValueFromOracle(finalUSTValue, priceFeedUstaUst);

        payAUST(msg.sender, USTAmountInaUST);

    }


    /*
     * This function allows users to send aUST and receive ONE
     * through oneAnchor
     * Swap aUST for UST using this contract
     * Facilitate a swap UST to ONE using a dex, then give user ONE
    */
    function withdrawal(uint256 amount) public payable nonReentrant{
        require(amount > 0, "Withdrawal amount must be greater than 0");

        uint256 ustFromAust = getForwardValueFromOracle(amount, priceFeedUstaUst);
        takeAUST(msg.sender, amount);

        uint256 predictedWithdrawValueInOne = getForwardValueFromOracle(ustFromAust, priceFeedOneUsd);

        address[] memory inversePath = new address[](2);
        inversePath[0] = path[1];
        inversePath[1] = path[0];

        wUST.approve(address(router), ustFromAust);

        uint256[] memory finalValues = router.swapExactTokensForETH(
            ustFromAust,
            predictedWithdrawValueInOne * 95 / 100, //maximum 5% slippage
            inversePath,
            address(this),
            block.timestamp + 120 seconds
        );

        uint256 finalONEValue = finalValues[1];

        bool didSend = sendViaCall(payable(msg.sender), finalONEValue);

        require(
            didSend,
            "ONE send failed"
        );
    }



    function swap(uint256 amount, address inputToken)
        public
        nonReentrant
    {
        require(
            inputToken == address(wUST) || inputToken == address(wAUST),
            "ONEANCHOR: Invalid Input Token for Swap"
        );

        uint256 outputTokenAmount;

        if(inputToken == address(wUST)){
            outputTokenAmount = getBackwardValueFromOracle(amount, priceFeedUstaUst);
            takeUST(msg.sender, amount);
            payAUST(msg.sender, outputTokenAmount);
        }
        else{
            outputTokenAmount = getForwardValueFromOracle(amount, priceFeedUstaUst);
            takeAUST(msg.sender, amount);
            payUST(msg.sender, outputTokenAmount);
        }
    }


    /**
     * Returns Pair exchange rate
     */

    function getForwardValueFromOracle(uint256 _amountOther, AggregatorV3Interface cl)
        public
        view
        returns(uint256)
    {
        uint8 oracleDecimals = cl.decimals();
        (, int256 price, , , ) = cl.latestRoundData();
        return _amountOther * uint256(price) / 10 ** uint256(oracleDecimals);
    }

    function getBackwardValueFromOracle(uint256 _amountUST, AggregatorV3Interface cl)
        public
        view
        returns(uint256)
    {
        uint8 oracleDecimals = cl.decimals();
        (, int256 price, , , ) = cl.latestRoundData();
        return _amountUST / uint256(price) * 10 ** uint256(oracleDecimals);
    }

    function getRebalanceAmount()
        external
        view
        returns (uint256[2] memory)
    {

        uint256 aUSTAmountInUST =  getForwardValueFromOracle(aUSTBalance, priceFeedUstaUst);

        if(aUSTAmountInUST > USTBalance){
            uint256 difference = aUSTAmountInUST - USTBalance;
            return [difference/2, 0];
        }
        else{
            uint256 difference =  USTBalance - aUSTAmountInUST;
            return [0 , difference/2];
        }

    }

}
