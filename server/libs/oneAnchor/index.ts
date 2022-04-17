import { BridgeResponse, DepositResponse, WithdrawResponse } from '../types'
import { bridgeaUSTToHarmony, bridgeUSTToHarmony } from '../terra'

export async function deposit(value) {
    await deposit(value).then(result => {
        const amount = Number((result as unknown as DepositResponse).aUST)
        // bridgeaUSTToHarmony(amount.toString(), originAddress).then(r => {
        //     const hash = (r as BridgeResponse).hash
        //     res.send(buildEndpointResponse('success',hash,amount.toString(),''))
        // })
    })

}

async function withdraw(value) {
    await withdraw(value).then(result => {
        var amount = Number((result as unknown as WithdrawResponse).UST)
        // bridgeUSTToHarmony(amount.toString(), originAddress).then(r => {
        //     const response = r as BridgeResponse
        //     const hash = response.hash
        //     amount = amount - Number(response.fee)
        // })
    })
    
}