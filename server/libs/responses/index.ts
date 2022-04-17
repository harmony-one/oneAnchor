import { BridgeResponse, DepositResponse, EndPointResponse, WithdrawResponse } from '../types'

export function buildEndpointResponse(status: string, earnHash: string, amount: string, errorMessage: string ) {
    const result = {status: status, EarnHash: earnHash, amount: amount, errorMessage: errorMessage} as EndPointResponse
    return result
}

export function buildBridgeResponse(status: string, hash: string, errorMessage: string) {
    const result = {status: status, hash: hash, errorMessage: errorMessage} as BridgeResponse
    return result
}

export function buildDepositResponse(status: string, aUST: string, errorMessage: string) {
    const result = {status: status, aUST: aUST, errorMessage: errorMessage} as DepositResponse
    return result
}

export function buildWithdrawResponse(status: string, UST: string, errorMessage: string) {
    const result = {status: status, UST: UST, errorMessage: errorMessage} as WithdrawResponse
    return result
}