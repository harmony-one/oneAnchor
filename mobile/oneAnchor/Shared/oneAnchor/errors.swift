//
//  errors.swift
//  File with all the errors required
//  by oneAnchor libraries
//
//  Created by Boris Polania on 4/22/22.
//

import Foundation

/// error thrown when the contracts address has
/// not been set as a UserDefault configuration
enum NoAddressError: Error {
    case AddressNotSet
}

