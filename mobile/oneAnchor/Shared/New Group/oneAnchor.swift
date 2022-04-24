//
//  oneAnchor.swift
//  oneAnchor libraries generate transactions to interact
//  with oneAnchor.sol contract in Harmony protocol
//
//  Created by Boris Polania on 4/20/22.
//

import Foundation

/// Util methods (internal)
///
/// These methods are intended to be uses by other methods
/// of the oneAnchor library

/// config - sets the oneAnchor.sol contract address in mainnet
///
/// - Parameter contractAddress: String with a valid Harmony address
func config(contractAddress: String) {
    K.config.defaults.set(contractAddress, forKey: K.config.key)
}
/// buildTxData - builds a string with the value of txData
///
/// - Parameter selector: String with the keccak encoding of the contract's function
/// - Parameter args: Array of String with the encoding of each argument value of the contract's function
/// - Returns: a String with the encoded txData value
func buildTxData(selector: String, args: [String]) -> String {
    var txData = selector
    if !args.isEmpty {
        for arg in args {
            txData += String(arg.padding(toLength: 64, withPad: "0", startingAt: 0).reversed())
        }
    }
    return txData
}
/// getTransaction - builds a generic transaction
///
/// - Parameter selector: String with the keccak encoding of the contract's function
/// - Parameter args: Array of String with the encoding of each argument value of the contract's function
/// - Parameter value: String with the value of msg.value
/// - Returns: JSON string of the transaction
func getTransaction(selector: String, args: [String], value: String) -> String {
    var tx : [String:String] = [String:String]()
    tx[K.trx.contractAddress] = K.config.defaults.string(forKey: K.config.key)
    tx[K.trx.txData] = buildTxData(selector: selector, args: args)
    tx[K.trx.value] = String(value.padding(toLength: 19, withPad: "0", startingAt: value.count - 1).reversed())
    let resultData = try! JSONSerialization.data(withJSONObject: tx)
    return String(data: resultData, encoding: .utf8)!
}

/// SDK methods (external)
///
/// These are the methods that intended to be called by anyone
/// implementing the oneAnchor libraries

/// deposit - builds a deposit transaction
///
/// - Parameter args: Array of String with the encoding of each argument value of the contract's function
/// - Parameter value: String with the value of msg.value
/// - Parameter callback: gets the JSON string of the deposit transaction
func deposit(args: [String], value: String, callback: (String)->()) throws {
    if K.config.defaults.string(forKey: K.config.key) == nil {
        throw NoAddressError.AddressNotSet
    }
    callback(getTransaction(selector: K.selector.deposit,args: args, value: value))
}
/// withdraw - builds a deposit transaction
///
/// - Parameter args: Array of String with the encoding of each argument value of the contract's function
/// - Parameter callback: gets the JSON string of the withdraw transaction
func withdraw(args: [String], callback: (String)->()) throws {
    if K.config.defaults.string(forKey: K.config.key) == nil {
        throw NoAddressError.AddressNotSet
    }
    callback(getTransaction(selector: K.selector.withdraw, args: args, value: "0"))
}
/// getBalance - gets the accounts deposited balance
///
/// - Parameter callback: gets ta string with the balance
func getBalance(callback: (String)->()) throws {
    if K.config.defaults.string(forKey: K.config.key) == nil {
        throw NoAddressError.AddressNotSet
    }
    callback(getTransaction(selector: K.selector.getBalance, args: [], value: "0"))
}
/// getAPY - gets the current Anchor Earn APY
///
/// - Parameter callback: gets ta string with the current APY
func getAPY(callback: @escaping (String)->()) {
    let url = URL(string: K.anchor.endpoint)!
    let request = URLRequest(url: url)
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Error: \(error)")
            callback("error")
        }
        let decoder = JSONDecoder()
        do {
            let stableCoinInfo = try decoder.decode(StableCoinInfo.self, from: data!)
            callback(stableCoinInfo.current_apy)
        } catch {
            print("Error: \(error)")
        }
    }
    task.resume()
}
