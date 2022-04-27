import {updateAUST, updateUST} from '../../data'
import {log} from '../logs'

async function getExchangeRate() {
    return 0;
}

async function getAUSTbalance() {
    return 0;
}

async function getUSTbalance() {
    return 0;
}

export async function getAUST(amount: number) {
    log("calling getAUST", [["amount",amount.toString(),"number"]]);
    let aUSTbalance = await getAUSTbalance();
    let exchangeRate = await getExchangeRate();
    if (amount * 0.75 > aUSTbalance) { // there are enough aUST in Anchor 
        log("bridging aUST to smart contract", [["amount",amount.toString(),"number"]]);
        // bridge from terra aUST to wrapped aUST
        // in the reserves contract wallet
        updateAUST(amount * -1); //on success
    } else if (amount * 0.75 > aUSTbalance * exchangeRate) { // there is enough UST in Anchor
        log("Making deposit in anchor", [["amount",amount.toString(),"number"]]);
        // deposit in Anchor
    } else {
        // burn wrapper aUST into terra account
    } 
}

export async function getUST(amount: number) {
    log("calling getUST", [["amount",amount.toString(),"number"]]);
    let USTbalance = await getUSTbalance();
    let exchangeRate = await getExchangeRate();
    if (amount * 0.75 > USTbalance) { // there are enough UST in Anchor 
        log("bridging UST to smart contract", [["amount",amount.toString(),"number"]]);
        // bridge from Terra to Harmony contract
        updateUST(amount * -1); //on success
    } else if (amount * 0.75 > USTbalance * exchangeRate) { // there is enough aUST in Anchor
        log("Withdrawing from anchor", [["amount",amount.toString(),"number"]]);
        // withdraw in Anchor
    } 
}
