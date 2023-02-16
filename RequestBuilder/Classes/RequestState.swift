//
//  File.swift
//  
//
//  Created by Nayanda Haberty on 15/2/23.
//

import Foundation

public enum RequestState<Body: Equatable>: Equatable {
    case completed(URLRequestResponse<Body>)
    case fail(URLRequestResponse<Body>)
    case onProgress
    case cancelled
    case suspended
}
