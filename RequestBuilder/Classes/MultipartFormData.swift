//
//  MultipartFormData.swift
//  RequestBuilder
//
//  Created by Nayanda Haberty on 16/2/23.
//

import Foundation

public struct MultipartFormData {
    public let boundary: String
    public let formData: Data
    
    public init(boundary: String = UUID().uuidString) {
        self.boundary = boundary
        self.formData = Data()
    }
    
    init(boundary: String, formData: Data) {
        self.boundary = boundary
        self.formData = formData
    }
    
    public func added(
        _ text: String,
        named name: String,
        contentType: HTTPContentType = .text(.plain),
        charset: HTTPCharset = .utf8,
        contentTransferEncoding: HTTPContentTransferEncoding = .bit8) throws -> MultipartFormData {
            let encoding = charset.encoding
            guard let textData = text.data(using: encoding) else {
                throw URLRequestBuilderError.stringEncodeFail(text, encoding)
            }
            return try added(
                textData,
                named: name,
                contentType: contentType,
                charset: charset,
                contentTransferEncoding: contentTransferEncoding
            )
        }
    
    public func added(
        _ data: Data,
        named name: String,
        contentType: HTTPContentType = .text(.plain),
        charset: HTTPCharset? = nil,
        contentTransferEncoding: HTTPContentTransferEncoding? = nil) throws -> MultipartFormData {
            var preText = "--\(boundary)\r\nContent-Disposition: form-data; name=\"\(name)\"\r\n"
            + "Content-Type: \(contentType.stringRepresentation)"
            if let charset {
                preText += "; charset=\(charset.stringRepresentation)\r\n"
            } else {
                preText += "\r\n"
            }
            if let contentTransferEncoding {
                preText += "Content-Transfer-Encoding: \(contentTransferEncoding.stringRepresentation)\r\n"
            }
            preText += "\r\n"
            guard let preTextData = preText.data(using: .utf8) else {
                throw URLRequestBuilderError.stringEncodeFail(preText, .utf8)
            }
            let postText = "\r\n"
            guard let postTextData = postText.data(using: .utf8) else {
                throw URLRequestBuilderError.stringEncodeFail(postText, .utf8)
            }
            var newContent = self.formData
            newContent.append(preTextData)
            newContent.append(data)
            newContent.append(postTextData)
            return MultipartFormData(boundary: boundary, formData: newContent)
        }
}
