//
//  structs.swift
//  File with all the structs required
//  by oneAnchor libraries
//
//  Created by Boris Polania on 4/22/22.
//

import Foundation

/// struct for decoding the data coming from Anchor Earn API GET response
struct StableCoinInfo: Codable {
    var stable_denom: String
    var liquid_terra: String
    var exchange_rate: String
    var last_updated: Int
    var borrowed_terra: String
    var utilization_ratio: String
    var current_apy: String
}
/// constants struct
struct K {
    struct config {
        static let defaults = UserDefaults.standard
        static let key = "contractAddress"
    }
    struct trx {
        static let contractAddress = "contractAddress"
        static let txData = "txData"
        static let value = "value"
    }
    struct selector {
        static let deposit = "0xd0e30db0"
        static let withdraw = "0x835fc6ca"
        static let getBalance = "0x12065fe0"
    }
    
    struct anchor {
        static let endpoint = "https://eth-api.anchorprotocol.com/api/v1/stablecoin_info/uusd"
    }
}
