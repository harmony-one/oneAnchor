import dotenv from 'dotenv'
import { LCDClient, MnemonicKey, Fee, MsgExecuteContract, MsgSend } from '@terra-money/terra.js'
import { buildBridgeResponse } from '../responses'

dotenv.config()

export async function bridgeaUSTToHarmony(amount: string, account: string) {

  try {
    const mnemonic = new MnemonicKey({
        mnemonic: process.env.MNEMONIC,
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
      const result = buildBridgeResponse('success', hash, '')
      resolve(result)
    })
  } catch(error) {
    console.log(error)
  }  
}

export async function bridgeUSTToHarmony(amount: string, account: string) {

  try {
    const mnemonic = new MnemonicKey({
        mnemonic: process.env.MNEMONIC,
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
      resolve(result)
    })
  } catch(error) {
    console.log(error)
  }  
}