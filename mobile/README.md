## oneAnchor Mobile Libraries

### Configuration

A contract address must be set in the user dafaults, use the `config` 
method to set this value, otherwise it will throw an error

### Implementation

Just pull the `oneAnchor` group into your project

The followng methods are the ones intended for any project implementing
the oneAnchor mobile libraries

```
/// config - sets the oneAnchor.sol contract address in mainnet
///
/// - Parameter contractAddress: String with a valid Harmony address
func config(contractAddress: String) 

/// deposit - builds a deposit transaction
///
/// - Parameter args: Array of String with the encoding of each argument value of the contract's function
/// - Parameter value: String with the value of msg.value
/// - Parameter callback: gets the JSON string of the deposit transaction
func deposit(args: [String], value: String, callback: (String)->())

/// withdraw - builds a deposit transaction
///
/// - Parameter args: Array of String with the encoding of each argument value of the contract's function
/// - Parameter callback: gets the JSON string of the withdraw transaction
func withdraw(args: [String], callback: (String)->())

/// getBalance - gets the accounts deposited balance
///
/// - Parameter callback: gets ta string with the balance
func getBalance(callback: (String)->()) 

/// getAPY - gets the current Anchor Earn APY
///
/// - Parameter callback: gets ta string with the current APY
func getAPY(callback: @escaping (String)->())
```

### Testing

Currently, the following contract has been deployed inb Harmony mainnet, it can be used 
to test the libraries:

`0x883D61425C6684dE7b2f977373d21A7E7661A47d`

Also, the repo has a basic app that runs all the transactions and outputs into the console
