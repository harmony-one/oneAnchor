import * as blockchain from './blockchain'
export type FilterType = 'gt' | 'gte' | 'lt' | 'lte' | 'eq'
export type FilterProperty = 'number' | 'block_number' | 'address'

export type TransactionQueryField = 'block_number' | 'block_hash' | 'hash' | 'hash_harmony'
export type StakingTransactionQueryField = 'block_number' | 'block_hash' | 'hash'
export type TransactionQueryValue =
  | blockchain.BlockNumber
  | blockchain.BlockHash
  | blockchain.TransactionHash

export type FilterEntry = {
  type: FilterType
  property: FilterProperty
  value: number | string
}

export type FilterOrderBy = 'number' | 'block_number'

export type FilterOrderDirection = 'asc' | 'desc'
export type Filter = {
  offset: number
  limit?: number
  orderDirection: FilterOrderDirection
  orderBy: FilterOrderBy
  filters: FilterEntry[]
}
export type DepositResponse = {
  status: string
  aUST: string
  errorMessage: string
}

export type WithdrawResponse = {
  status: string
  UST: string
  errorMessage: string
}

export type BridgeResponse = {
  status: string
  hash: string
  errorMessage: string
}

export type EndPointResponse = {
  status: string
  EarnHash: string
  amount: string
  errorMessage: string
}