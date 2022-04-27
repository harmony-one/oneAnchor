import dotenv from 'dotenv'
import abi from '../../consts/abi/abi.json';
import {ethers} from 'ethers';
import {buildBridgeResponse} from '../responses';
import {decodeTerraAddressOnEtherBase} from './utils';

dotenv.config()

const privateKey = process.env.ONE_ANCHOR_RESERVE_HMY_ACCOUNT_PK;
const terraAccount = process.env.ONE_ANCHOR_TERRA_ACCOUNT;
const hmnyRpcNode = process.env.HMY_RPC_ENDPOINT;
const signer = new ethers.providers.JsonRpcProvider(hmnyRpcNode);
const wallet = new ethers.Wallet(privateKey, signer);

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

