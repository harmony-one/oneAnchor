import dotenv from 'dotenv'
import { TxResult } from '@terra-money/wallet-provider';
import abi from '../../consts/abi/abi.json'
import bech32 from 'bech32'
import { BigNumber } from '@ethersproject/bignumber'
import { LCDClient, MnemonicKey, Fee, MsgExecuteContract, MsgSend } from '@terra-money/terra.js'
import { buildBridgeResponse } from '../responses'
import { ethers, providers } from 'ethers'

dotenv.config()

const privateKey = process.env.ONE_ANCHOR_RESERVE_HMY_ACCOUNT_PK;
const wrappedUST = process.env.HMY_WRAPPED_UST_CONTRACT;
const wrappedaUST = process.env.HMY_WRAPPED_AUST_CONTRACT;
const terraAccount = process.env.ONE_ANCHOR_TERRA_ACCOUNT;
const hmnyRpcNode = process.env.HMY_RPC_ENDPOINT;
const signer = new ethers.providers.JsonRpcProvider(hmnyRpcNode);
const wallet = new ethers.Wallet(privateKey, signer);

/* bech32 */
const decodeTerraAddressOnEtherBase = (address: string): string => {
  try {
    const { words } = bech32.bech32.decode(address)
    const data = bech32.bech32.fromWords(words)
    return '0x' + Buffer.from(data).toString('hex')
  } catch (error) {
    return ''
  }
}

const getEtherBaseContract = ({
  token,
  }: {
    token: string
  }): ethers.Contract | undefined => {
    try {
      // if token is empty, error occurs
      return token
        ? new ethers.Contract(token, abi, wallet)
        : undefined
    } catch(error) {
      console.log(error)
    }
}

async function bridgeToTerra(token, amount) {
  const contract = getEtherBaseContract({ token: token});
  if (!wallet) {
    return;
  }
  try {
    if (contract) {
      const vaultContractSigner = contract.connect(signer)
      const decoded = decodeTerraAddressOnEtherBase(terraAccount)
      console.log(decoded)
      vaultContractSigner?.burn(amount, decoded.padEnd(66, '0'))
              .then( (tx: any) => {
                console.log(JSON.stringify(tx))
                return new Promise(function(resolve, reject) {
                  const result = buildBridgeResponse('success',tx.hash,'')
                  resolve(result)
                })
              })
    }
  } catch(error) {
    console.log(error);
    return buildBridgeResponse('fail','',error)
  }
}

export async function bridgeWrappedUSTtoTerra(amount) {
  const wrappedUST = process.env.HMY_WRAPPED_UST_CONTRACT;
  return bridgeToTerra(wrappedUST, amount)
}

export async function bridgeWrappedaUSTtoTerra(amount) {
  const wrappedaUST = process.env.HMY_WRAPPED_AUST_CONTRACT;
  return bridgeToTerra(wrappedaUST, amount)
}

