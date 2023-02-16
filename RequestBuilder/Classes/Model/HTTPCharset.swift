//
//  HTTPCharset.swift
//  RequestBuilder
//
//  Created by Nayanda Haberty on 16/2/23.
//

import Foundation

public enum HTTPCharset {
    case ascii
    case win1252
    case iso8859
    case iso88591
    case symbols
    case utf8
    case any(String, String.Encoding)
    
    var stringRepresentation: String {
        switch self {
        case .ascii:
            return "ASCII"
        case .win1252:
            return "WIN-1252"
        case .iso8859:
            return "ISO-8859"
        case .iso88591:
            return "ISO-8859-1"
        case .symbols:
            return "Symbols"
        case .utf8:
            return "UTF-8"
        case .any(let string, _):
            return string
        }
    }
    
    var encoding: String.Encoding {
        switch self {
        case .ascii, .iso8859, .iso88591:
            return .ascii
        case .win1252:
            return .windowsCP1252
        case .symbols:
            return .symbol
        case .utf8:
            return .utf8
        case .any(_, let encoding):
            return encoding
        }
    }
}
