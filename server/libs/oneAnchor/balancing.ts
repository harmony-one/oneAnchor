import { decodeTerraAddressOnEtherBase} from '../terra'
import { ethers } from 'ethers'
import { log } from '../logs'
import abi from './abi/oneAnchor.json';
import 'dotenv/config'

const provider = new ethers.providers.JsonRpcProvider(process.env.HMY_RPC_PROVIDER)
const signer = new ethers.Wallet(process.env.HMY_PK, provider);
let contractAddress = process.env.HMY_ONE_ANCHOR_CONTRACT_ADDRESS;
let contract = new ethers.Contract(contractAddress, abi, provider);

export async function getBalanceReserves() {
    log("calling getBalanceReserves",null);
    return contract.getRebalanceAmount();
}

export async function withdrawAUSTFromReserves(amount: number) {
    log("calling withdrawAUSTToReserves", [["amount",amount.toString(),"number"]]);
    var terraAddress = decodeTerraAddressOnEtherBase(process.env.TERRA_MAIN_ACCOUNT_ADDRESS);
    return contract.withdrawAUSTOperator(amount, terraAddress);
}