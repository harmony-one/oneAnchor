import {updateAUST, updateUST} from '../../data'
import {log} from '../logs'
import {bridgeaUSTToHarmony, bridgeUSTToHarmony} from '../terra'
import {deposit, withdraw} from '../anchor'
import {withdrawAUSTFromReserves} from './balancing'
import {getExchangeRate, getAUSTbalance, getUSTbalance} from '../terra'
import 'dotenv/config'

const hmyOneAnchorContractAddress = process.env.HMY_ONE_ANCHOR_CONTRACT_ADDRESS;

export async function getAUST(amount: number) {
    log("calling getAUST", [["amount",amount.toString(),"number"]]);
    let aUSTbalance = await getAUSTbalance();
    let exchangeRate = await getExchangeRate();
    if (amount * 0.75 > aUSTbalance) { // there are enough aUST in Anchor 
        // bridge from terra aUST to wrapped aUST
        // in the reserves contract wallet
        bridgeaUSTToHarmony(amount.toString(), hmyOneAnchorContractAddress!);
        updateAUST(amount * -1); //on success
    } else if (amount * 0.75 > aUSTbalance * exchangeRate) { // there is enough UST in Anchor
        log("Making deposit in anchor", [["amount",amount.toString(),"number"]]);
        // deposit in Anchor
        deposit(amount.toString());
    } else {
        // burn wrapper aUST into terra account
        withdrawAUSTFromReserves(amount);
    } 
}

export async function getUST(amount: number) {
    log("calling getUST", [["amount",amount.toString(),"number"]]);
    let USTbalance = await getUSTbalance();
    let exchangeRate = await getExchangeRate();
    if (amount * 0.75 > USTbalance) { // there are enough UST in Anchor 
        log("bridging UST to smart contract", [["amount",amount.toString(),"number"]]);
        // bridge UST from Terra to Harmony contract
        bridgeUSTToHarmony(amount.toString(), hmyOneAnchorContractAddress!);
        updateUST(amount * -1); //on success
    } else if (amount * 0.75 > USTbalance / exchangeRate) { // there is enough aUST in Anchor
        log("Withdrawing from anchor", [["amount",amount.toString(),"number"]]);
        // withdraw in Anchor
        withdraw(amount.toString());
    } 
}
