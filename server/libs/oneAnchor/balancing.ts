import { BridgeResponse, DepositResponse, WithdrawResponse } from '../types'
import { bridgeaUSTToHarmony, bridgeUSTToHarmony } from '../terra'
import {ethers} from 'ethers'
import 'dotenv/config'

const { abi } = require('./abi/oneAnchor.json');
import {log} from '../logs'

const provider = new ethers.providers.JsonRpcProvider(process.env.HMY_RPC_PROVIDER)
const signer = new ethers.Wallet(process.env.HMY_PK, provider);
let contractAddress = process.env.HMY_ONE_ANCHOR_CONTRACT_ADDRESS;
let contract = new ethers.Contract(contractAddress, abi, provider);

export async function getBalanceReserves() {
    log("calling getBalanceReserves",null);
    return contract.getRebalanceAmount();
}

export async function depositToReserves(amount: number) {
    log("calling depositToReserves", [["amount",amount.toString(),"number"]]);
}

export async function withdrawToReserves(amount: number) {
    log("calling withdrawToReserves", [["amount",amount.toString(),"number"]]);

}


// export async function deposit(value) {
//     await deposit(value).then(result => {
//         const amount = Number((result as unknown as DepositResponse).aUST)
//         bridgeaUSTToHarmony(amount.toString(), originAddress).then(r => {
//             const hash = (r as BridgeResponse).hash
//             res.send(buildEndpointResponse('success',hash,amount.toString(),''))
//         })
//     })

// }

// async function withdraw(value) {
//     await withdraw(value).then(result => {
//         var amount = Number((result as unknown as WithdrawResponse).UST)
//         bridgeUSTToHarmony(amount.toString(), originAddress).then(r => {
//             const response = r as BridgeResponse
//             const hash = response.hash
//             amount = amount - Number(response.fee)
//         })
//     })
    
// }