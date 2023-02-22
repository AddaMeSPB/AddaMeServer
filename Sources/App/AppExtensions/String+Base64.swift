//
//  String+Base64.swift
//  
//
//  Created by Alif on 10/7/20.
//

import Foundation

extension String {

    public func base64Encoded() -> String? {
        return data(using: .utf8)?.base64EncodedString()
    }

    public func base64Decoded() -> String? {
        guard let data = Data(base64Encoded: self) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}

