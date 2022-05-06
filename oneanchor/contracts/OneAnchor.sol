// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "./interfaces/IUniswapV2Router02.sol";
import "./interfaces/ISushiSwapLPToken.sol";
import "./Reserve.sol";

//On solidity 8 and above safe math is build in so no need for .(operation) functions
//Use unchecked if you want to not use safemath

/*
@TODO for next version
Look at some statistics to see if we think pool will get drained over time because of no swap fees, or be ok due to aUST appreciation
Look at making operators decentralized, and post a bond/have some incentive for balancing pool
*/

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

    function initialize() external initializer {
        __OneAnchor_init();
    }

    function __OneAnchor_init() internal onlyInitializing {
        // addresses
        clONEUSD = 0xdCD81FbbD6c4572A69a534D8b8152c562dA8AbEF;
        clUSTaUST = 0xDa543b5eC7353C289A633aF289c0e5a7321f8b0f;
        uniswapV2Router02 = 0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506;
        wONE = 0xcF664087a5bB0237a0BAd6742852ec6c8d69A27a;
        sushiSwapLPToken = 0x4dABF6C57A8beA012F1EAa1259Ceed2a62AC7df2;
        //contracts
        priceFeedOneUsd = AggregatorV3Interface(clONEUSD);
        priceFeedUstaUst = AggregatorV3Interface(clUSTaUST);
        router = IUniswapV2Router02(uniswapV2Router02);

        __Reserve_init(
            0x224e64ec1BDce3870a6a6c777eDd450454068FEC, //wUst Address
            0x4D9d9653367FD731Df8412C74aDA3E1c9694124a   //waust address
        );

        lpToken = ISushiSwapLPToken(sushiSwapLPToken);

        path = new address[](2);
        path[0] = wONE;
        path[1] = address(wUST);
    }

    event Deposit(address indexed _from, uint256 _one, uint256 _aust);
    event Withdrawal(address indexed _from, uint256 _aust, uint256 _one);

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
            OneAmountInUST * 95 / 100,
            path,
            address(this),
            block.timestamp + 120 seconds
        );
        uint256 finalUSTValue = finalValues[1];

        //Double check slippage, probably redundant
        require(
            finalUSTValue >= OneAmountInUST * 95 / 100,
            "Slippage on Swap Too Large"
        );

        // Calculate the number of aUST that must be sent to the user
        // to the user and send them to it
        uint256 USTAmountInaUST = getBackwardValueFromOracle(finalUSTValue, priceFeedUstaUst);

        payAUST(msg.sender, USTAmountInaUST);
        emit Deposit(msg.sender, msg.value, finalUSTValue);
    }
    /*
     * This function allows users to send aUST and receive ONE
     * through oneAnchor
     * Swap aUST for UST using this contract
     * Facilitate a swap UST to ONE using a dex, then give user ONE
    */
    function withdrawal(uint256 amount) public nonReentrant{
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
        emit Withdrawal(msg.sender, amount, finalONEValue);
    }
    /*
    * Exchanges aUST and UST based on the price feed values
    * Since this happens through oracles, we need to make sure gains form aUST outpace drainage
    * Also consider adding a swap fee is necessary to maintain pool liquidity
    */
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
     * Forward means that if a pair is TOKENA / TOKENB,
     * This function takes input of TOKENB and gives output of equivant TOKENA
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
    /**
     * Inverse price operation on a price feed oracle
     * Backward means that if a pair is TOKENA / TOKENB,
     * This function takes input of TOKENA and gives output of equivant TOKENB
     */
    function getBackwardValueFromOracle(uint256 _amountUST, AggregatorV3Interface cl)
        public
        view
        returns(uint256)
    {
        uint8 oracleDecimals = cl.decimals();
        (, int256 price, , , ) = cl.latestRoundData();
        return  _amountUST * (10 ** uint256(oracleDecimals)) / uint256(price);
    }
    /**
     * This function will output the correct amount of tokens required to rebalance the pool to 50/50 USD value
     * The first value in the return array represents the amount of aUST to bridge, and the second the amount of UST to bridge
     * One of these 2 return values should always be 0
     */
    function getRebalanceAmount()
        external
        view
        returns (uint256[2] memory)
    {

        uint256 aUSTAmountInUST =  getForwardValueFromOracle(aUSTBalance, priceFeedUstaUst);

        if(aUSTAmountInUST > USTBalance){
            uint256 difference = aUSTAmountInUST - USTBalance;
            uint256 aUST2Bridge = getBackwardValueFromOracle(difference, priceFeedUstaUst);
            return [aUST2Bridge/2, 0];
        }
        else{
            uint256 difference =  USTBalance - aUSTAmountInUST;
            return [0 , difference/2];
        }
    }
     /**
     * This function will output the total 
     * deposited amount an account has in One
     */
    function getBalance() public view returns(uint) {
        uint balance = wAUST.balanceOf(msg.sender);
        // Calculate the amount of UST that the user has deposited
        uint256 aUSTAmountInUST =  getForwardValueFromOracle(balance, priceFeedUstaUst);
        // Calculate the amount of ONE that the user has deposited
        uint256 USTAmountInOne =  getForwardValueFromOracle(aUSTAmountInUST, priceFeedOneUsd);
        return USTAmountInOne;
    }

}
