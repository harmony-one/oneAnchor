import {getData, updateAUST, updateUST} from '../../data'
import {getUST, getAUST} from './funding'
import {getBalanceReserves} from './balancing'
import {log} from '../logs'

var data = getData();

// check if there are funds that need
// to be sent to reserves
export function checkForPendingLoad() {
    log("calling checkForPendingLoad",null);
    if (data.ust > 0) {
        getUST(data.ust);
    }
    if (data.aust > 0) {
        getAUST(data.aust);
    }
}

export function balanceReserves() {
    log("calling balanceReserves",null);
    let reserves = getBalanceReserves();
    if (reserves[0] > 0) {
        //aUSTs reserves need to be balanced
        updateAUST(reserves[0]);
    } else if (reserves[1] > 0) {
        //USTs reserves need to be balanced
        updateUST(reserves[1]);
    }
}


