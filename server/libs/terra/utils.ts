import bech32 from 'bech32'
import axios from 'axios'
import { LCDClient } from '@terra-money/terra.js'
import { log } from '../logs'
import 'dotenv/config'

export function getLCDClient() {
  const lcd = new LCDClient({
      URL: 'https://lcd.terra.dev',
      chainID: 'columbus-5',
    });
  return lcd;
}

const terraApiGetEndpoint = process.env.TERRA_API_GET_ENDPOINT;

export async function getExchangeRate(): Promise<number> {
    axios.get(terraApiGetEndpoint!)
  .then(function (response) {
    // handle success
    console.log(response);
    log("calling getExchangeRate with response " + response.data.exchange_rate);
    return response.data.exchange_rate;
  })
  .catch(function (error) {
    // handle error
    console.log(error);
    log("call to getExchangeRate failed ");
    return -1;
  })
  return -1;
}

export async function getUSTbalance(): Promise<number> {
  const terra = getLCDClient()
  const address = process.env.TERRA_MAIN_ACCOUNT_ADDRESS;
  const [balance] = await terra.bank.balance(address!);
  console.log(balance.toData());
  return Number(balance.toData());
}

export async function getAUSTbalance(): Promise<number> {
  const terra = getLCDClient()
  const tokenAddress = process.env.TERRA_AUST_CONTRACT;
  const walletAddress = process.env.TERRA_MAIN_ACCOUNT_ADDRESS;
  const response = await terra.wasm.contractQuery(tokenAddress!, { balance: { address: walletAddress }});
  console.log(response);
  return Number(response);
}

/* bech32 */
export function decodeTerraAddressOnEtherBase(address: string) {
  try {
    const { words } = bech32.bech32.decode(address)
    const data = bech32.bech32.fromWords(words)
    return '0x' + Buffer.from(data).toString('hex')
  } catch (error) {
    return ''
  }
}
