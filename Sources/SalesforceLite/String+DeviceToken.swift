//
//  File.swift
//  
//
//  Created by PJ on 16/03/2023.
//

import Foundation

public extension String {
    init(deviceToken: Data) {
        self = deviceToken.map { String(format: "%.2hhx", $0)}.joined()
    }
}
