import { getData } from '../../data'
import { getUST, getAUST } from './funding'
import { ethers } from 'ethers'
import { log } from '../logs'
import abi from './abi/oneAnchor.json';
import 'dotenv/config'

const provider = new ethers.providers.JsonRpcProvider(process.env.HMY_RPC_PROVIDER)
let contractAddress = process.env.HMY_ONE_ANCHOR_CONTRACT_ADDRESS;
let contract = new ethers.Contract(contractAddress!, abi, provider);

// check if there are funds that need
// to be sent to reserves
function checkForPendingLoad() {
    var data = getData();
    log("calling checkForPendingLoad");
    if (data.ust > 0) {
        getUST(data.ust);
    }
    if (data.aust > 0) {
        getAUST(data.aust);
    }
}

export function setListeners(){
    contract.on("Deposit", (_from, _one, _aust) => {
        checkForPendingLoad();
    });
    contract.on("Withdrawal", (_from, _aust, _one) => {
        checkForPendingLoad();
    });
}