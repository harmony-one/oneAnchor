import dotenv from 'dotenv';
import { MnemonicKey, AnchorEarn, CHAINS, NETWORKS, DENOMS, TxOutput, TxDetails, MarketOutput, MarketEntry } from '@anchor-protocol/anchor-earn'
import { BigNumber } from 'bignumber.js';
import { TxLog  } from '@terra-money/terra.js'
import { buildDepositResponse, buildWithdrawResponse } from '../responses'
import { getLCDClient } from '../terra'
import { decrypt } from '../aws'

dotenv.config()

async function getMintedaUST(logs: Object) {
    var mintAmount
    const events = JSON.parse(JSON.stringify(logs))[0]['events']
    for (const event in events) {        
        if (events[event]['type'] == 'from_contract') {
            const attributes = events[event]['attributes']
            for (const attribute in attributes) {                
                if (attributes[attribute]['key'] == 'mint_amount') {
                    mintAmount = attributes[attribute]['value']
                }
            }
        }
    }
    return mintAmount
}

async function getUST(logs: Object) {
    var ust;
    const events = JSON.parse(JSON.stringify(logs))[0]['events']
    for (const event in events) {        
        if (events[event]['type'] == 'from_contract') {
            const attributes = events[event]['attributes']
            for (const attribute in attributes) {                
                if (attributes[attribute]['key'] == 'amount') {
                    ust = attributes[attribute]['value']
                }
            }
        }
    }
    return ust
}

export async function deposit(amount: string) {
    const bn_amount = new BigNumber(amount).shiftedBy(-18);
    var txDetails = new Object as TxDetails[];
    var txOutput = new Object as TxOutput;
    var logs = new Object as TxLog[];
    var mnemonic = await decrypt("mnemonic") as string;

    try {
        const account = new MnemonicKey({
            mnemonic: mnemonic,
        });
        const anchorEarn = new AnchorEarn({
            chain: CHAINS.TERRA,
            network: NETWORKS.COLUMBUS_5,
            privateKey: account.privateKey,
          });
        const deposit = await anchorEarn.deposit({
            amount: bn_amount.toString(), // amount in natural decimal e.g. 100.5. The amount will be handled in macro.
            currency: DENOMS.UST,
            log: (data) => {
                txOutput = data as TxOutput
                txDetails = txOutput.txDetails
            }
        })
        if (txDetails) {
            const txDetail = txOutput.txDetails[0] as TxDetails
            const terra = getLCDClient()
            await terra.tx.txInfo(txDetail.txHash)
                .then(res => {
                    logs = res.logs as TxLog[]
            }) 
            const aUSTvalue = await getMintedaUST(logs)
            console.log(`aUST amount: ${aUSTvalue}`)
            return new Promise(function(resolve, reject) {
                const result = buildDepositResponse(deposit.status, aUSTvalue, '')
                resolve(result)
            })
        }
    } catch(error) {
        let errorMessage = "Failed to do something exceptional"
        if (error instanceof Error) {
            errorMessage = error.message
        }
        return new Promise(function(resolve, reject) {
            const result = buildDepositResponse('fail', '0', errorMessage)
            reject(result)
        })
        
    }
}

export async function withdraw(amount: string) {
    const bn_amount = new BigNumber(amount).shiftedBy(-18);
    var txDetails = new Object as TxDetails[];
    var txOutput = new Object as TxOutput;
    var logs = new Object as TxLog[];
    var mnemonic = await decrypt("mnemonic") as string;
    try {
        const account = new MnemonicKey({
            mnemonic: mnemonic,
        });
        const anchorEarn = new AnchorEarn({
            chain: CHAINS.TERRA,
            network: NETWORKS.COLUMBUS_5,
            privateKey: account.privateKey,
          });
          const withdraw = await anchorEarn.withdraw({
            amount: bn_amount.toString(), // amount in natural decimal e.g. 100.5. The amount will be handled in macro.
            currency: DENOMS.AUST,
            log: (data) => {
                txOutput = data as TxOutput
                txDetails = txOutput.txDetails
            }
        })
        if (txDetails) {
            const txDetail = txOutput.txDetails[0] as TxDetails
            const terra = getLCDClient()
            await terra.tx.txInfo(txDetail.txHash)
                .then(res => {
                    logs = res.logs as TxLog[]
            }) 
            const USTvalue = await getUST(logs)
            console.log(`UST amount: ${USTvalue}`)
            return new Promise(function(resolve, reject) {
                const result = buildWithdrawResponse(withdraw.status, USTvalue, '')
                resolve(result)
            })
        }

    } catch(error) {
        let errorMessage = "Failed to do something exceptional"
        if (error instanceof Error) {
            errorMessage = error.message
        }
        return new Promise(function(resolve, reject) {
            const result = buildWithdrawResponse('fail', '0', errorMessage)
            reject(result)
        })
        
    }
}

export async function apy() {
    var mnemonic = await decrypt("mnemonic") as string;
    try {
        const account = new MnemonicKey({
            mnemonic: mnemonic,
        });
        const anchorEarn = new AnchorEarn({
            chain: CHAINS.TERRA,
            network: NETWORKS.COLUMBUS_5,
            privateKey: account.privateKey,
          });
          const marketInfo = await anchorEarn.market({
            currencies: [
              DENOMS.UST
            ],
          }) as MarketOutput
          const market = marketInfo.markets[0] as MarketEntry
          const apy = market.APY
          console.log(apy)
          return apy
    } catch(error) {
        console.log(error)
    }
}


