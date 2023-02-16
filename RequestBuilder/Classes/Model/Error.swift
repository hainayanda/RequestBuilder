//
//  File.swift
//  
//
//  Created by Nayanda Haberty on 15/2/23.
//

import Foundation

public enum URLRequestBuilderError: Error {
    case stringEncodeFail(String, String.Encoding)
    case jsonEncodeFail(Encodable, Error)
}

public enum URLRequestResponseError: Error {
    case noData
}

public enum AsyncRequestError: Error {
    case requestSuspended
    case requestCancelled
}
