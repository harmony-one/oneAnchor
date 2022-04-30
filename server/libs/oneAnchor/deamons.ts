import {updateAUST, updateUST} from '../../data'
import {getBalanceReserves} from './balancing'
import {log} from '../logs'

export async function balanceReserves() {
    log("calling balanceReserves");
    let reserves = await getBalanceReserves();
    if (reserves[0] > 0) {
        //aUSTs reserves need to be balanced
        updateAUST(reserves[0]);
    } else if (reserves[1] > 0) {
        //USTs reserves need to be balanced
        updateUST(reserves[1]);
    }
}


