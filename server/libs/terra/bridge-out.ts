import { LCDClient, MnemonicKey, Fee, MsgExecuteContract, MsgSend } from '@terra-money/terra.js'
import { buildBridgeResponse } from '../responses'
import {log} from '../logs'
import dotenv from 'dotenv'
import { decrypt } from '../aws'

dotenv.config()

export async function bridgeaUSTToHarmony(amount: string, account: string) {
  try {
    var m = await decrypt("mnemonic") as string;
    const mnemonic = new MnemonicKey({
        mnemonic: m,
    })
    const terra = new LCDClient({
      URL: 'https://lcd.terra.dev',
      chainID: 'columbus-5',
    });
    const wallet = terra.wallet(mnemonic)
    const executeContract = new MsgExecuteContract(
      process.env.HMY_UST_HOLDER_CONTRACT || '',
      process.env.TERRA_AUST_CONTRACT || '',
      {
        transfer: {
          recipient: process.env.HMY_MAINNET_CONTRACT || '',
          amount: amount,
        },
      },
      []
    )
    var hash = ''
    await wallet
    .createAndSignTx({
      msgs: [executeContract],
      memo: account,
    })
    .then(tx => terra.tx.broadcast(tx))
    .then(result => {
      console.log(`Earn TX hash: ${result.txhash}`)
      hash = result.txhash
    });
    return new Promise(function(resolve, reject) {
      log("aUST bridged to smart contract", [["amount",amount.toString(),"number"]]);
      const result = buildBridgeResponse('success', hash, '')
      resolve(result)
    })
  } catch(error) {
    console.log(error)
  }  
}

export async function bridgeUSTToHarmony(amount: string, account: string) {
  try {
    var m = await decrypt("mnemonic") as string;
    const mnemonic = new MnemonicKey({
        mnemonic: m,
    })
    const terra = new LCDClient({
      URL: 'https://lcd.terra.dev',
      chainID: 'columbus-5',
    });
    const wallet = terra.wallet(mnemonic)
    const msgSend = new MsgSend(
      process.env.HMY_UST_HOLDER_CONTRACT || '', 
      process.env.HMY_MAINNET_CONTRACT || '', {
      uusd: amount,
    })
    var hash = ''
    await wallet
    .createAndSignTx({
      msgs: [msgSend],
      memo: account,
    })
    .then(tx => terra.tx.broadcast(tx))
    .then(result => {
      console.log(`Earn TX hash: ${result.txhash}`)
      hash = result.txhash
    })
    return new Promise(function(resolve, reject) {
      const fee = Math.max(1000000,parseFloat(amount)*0.10)
      const result = buildBridgeResponse('success', hash, '')
      log("UST bridged to smart contract", [["amount",amount.toString(),"number"]]);
      resolve(result)
    })
  } catch(error) {
    console.log(error)
  }  
}