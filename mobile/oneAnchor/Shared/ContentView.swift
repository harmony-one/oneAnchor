//
//  ContentView.swift
//  Shared
//
//  Created by Boris Polania on 4/22/22.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        
        Text("Hello oneAnchor!")
            .padding().onAppear {
                // set address
                oneAnchor.config(contractAddress: "0x883D61425C6684dE7b2f977373d21A7E7661A47d")
                do {
                    // build deposit trx
                    try oneAnchor.deposit(args: [], value: "1") { result in
                        print(result)
                    }
                    // build withdraw trx
                    try oneAnchor.withdraw(args: ["2"]) { result in
                        print(result)
                    }
                    // get account deposited balance
                    try oneAnchor.getBalance() { result in
                        print(result)
                    }
                    // get current APY
                    oneAnchor.getAPY() { result in
                        print(result)
                    }
                } catch {
                    print("Error")
                }
                
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
