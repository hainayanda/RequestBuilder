//
//  HTTPContentTransferEncoding.swift
//  RequestBuilder
//
//  Created by Nayanda Haberty on 16/2/23.
//

import Foundation

public enum HTTPContentTransferEncoding {
    case base64
    case bit8
    case bit7
    case binary
    case xToken
    case quotedPrintable
    case any(String)
    
    var stringRepresentation: String {
        switch self {
        case .base64:
            return "base64"
        case .bit8:
            return "8bit"
        case .bit7:
            return "7bit"
        case .binary:
            return "binary"
        case .xToken:
            return "x-token"
        case .quotedPrintable:
            return "quoted-printable"
        case .any(let string):
            return string
        }
    }
}
