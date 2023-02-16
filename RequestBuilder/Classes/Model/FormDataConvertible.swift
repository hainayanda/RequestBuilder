//
//  FormDataConvertible.swift
//  RequestBuilder
//
//  Created by Nayanda Haberty on 16/2/23.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

// MARK: FormDataConvertible

public protocol FormDataConvertible {
    func formData(using boundary: String) throws -> Data
}

// MARK: FormDataConvertibles

public typealias FormDataConvertibles = [FormDataConvertible]

// MARK: AnyFormData

open class AnyFormData: FormDataConvertible {
    private let _data: Data
    open var data: Data {
        get throws {
            _data
        }
    }
    let name: String
    let contentType: HTTPContentType
    let charset: HTTPCharset?
    let contentTransferEncoding: HTTPContentTransferEncoding?
    
    public init(
        data: Data,
        name: String,
        contentType: HTTPContentType,
        charset: HTTPCharset? = nil,
        contentTransferEncoding: HTTPContentTransferEncoding? = nil) {
            self._data = data
            self.name = name
            self.contentType = contentType
            self.charset = charset
            self.contentTransferEncoding = contentTransferEncoding
        }
    
    open func formData(using boundary: String) throws -> Data {
        var preText = "--\(boundary)"
        + .newLine
        + "Content-Disposition: form-data; name=\"\(name)\""
        + .newLine
        + "Content-Type: \(contentType.stringRepresentation)"
        if let charset {
            preText += "; charset=\(charset.stringRepresentation)" + .newLine
        } else {
            preText += .newLine
        }
        if let contentTransferEncoding {
            preText += "Content-Transfer-Encoding: \(contentTransferEncoding.stringRepresentation)" + .newLine
        }
        preText += .newLine
        guard let preTextData = preText.data(using: .utf8) else {
            throw URLRequestBuilderError.stringEncodeFail(preText, .utf8)
        }
        let postText: String = .newLine
        guard let postTextData = postText.data(using: .utf8) else {
            throw URLRequestBuilderError.stringEncodeFail(postText, .utf8)
        }
        var mutableData = preTextData
        mutableData.append(try data)
        mutableData.append(postTextData)
        return mutableData
    }
}

// MARK: Private Extensions

private extension String {
    static var newLine: String { "\r\n" }
}

// MARK: TextData

public class TextData: AnyFormData {
    
    let text: String
    
    public override var data: Data {
        get throws {
            let encoding = charset?.encoding ?? .utf8
            guard let textData = text.data(using: encoding) else {
                throw URLRequestBuilderError.stringEncodeFail(text, encoding)
            }
            return textData
        }
    }
    
    public init(
        text: String,
        named name: String,
        type: TextHTTPContentSubtype = .plain,
        charset: HTTPCharset = .utf8,
        contentTransferEncoding: HTTPContentTransferEncoding = .bit8) {
            self.text = text
            super.init(
                data: Data(),
                name: name,
                contentType: .text(type),
                charset: charset,
                contentTransferEncoding: contentTransferEncoding
            )
        }
}

// MARK: ApplicationData

public class ApplicationData: AnyFormData {
    
    public init(
        data: Data,
        name: String,
        type: ApplicationHTTPContentSubtype,
        charset: HTTPCharset? = nil,
        contentTransferEncoding: HTTPContentTransferEncoding? = nil) {
            super.init(
                data: data,
                name: name,
                contentType: .application(type),
                charset: charset,
                contentTransferEncoding: contentTransferEncoding
            )
        }
}

// MARK: JSONData

public class JSONData<Object: Encodable>: ApplicationData {
    
    let object: Object
    let encoder: JSONEncoder
    
    public override var data: Data {
        get throws {
            do {
                return try encoder.encode(object)
            }
            catch {
                throw URLRequestBuilderError.jsonEncodeFail(object, error)
            }
        }
    }
    
    public init(
        _ object: Object,
        name: String,
        encoder: JSONEncoder = JSONEncoder()) {
            self.object = object
            self.encoder = encoder
            super.init(
                data: Data(),
                name: name,
                type: .json
            )
        }
}

// MARK: AudioData

public class AudioData: AnyFormData {
    
    public init(
        data: Data,
        name: String,
        type: AudioHTTPContentSubtype,
        charset: HTTPCharset? = nil,
        contentTransferEncoding: HTTPContentTransferEncoding? = nil) {
            super.init(
                data: data,
                name: name,
                contentType: .audio(type),
                charset: charset,
                contentTransferEncoding: contentTransferEncoding
            )
        }
}

// MARK: ImageData

public class ImageData: AnyFormData {
    
    public init(
        data: Data,
        name: String,
        type: ImageHTTPContentSubtype,
        charset: HTTPCharset? = nil,
        contentTransferEncoding: HTTPContentTransferEncoding? = nil) {
            super.init(
                data: data,
                name: name,
                contentType: .image(type),
                charset: charset,
                contentTransferEncoding: contentTransferEncoding
            )
        }
    
#if canImport(UIKit)
    public init(
        image: UIImage,
        name: String,
        type: ImageHTTPContentSubtype = .png,
        charset: HTTPCharset? = nil,
        contentTransferEncoding: HTTPContentTransferEncoding? = nil) {
            let data: Data
            switch type {
            case .jpeg:
                data = UIImageJPEGRepresentation(image, 1.0) ?? Data()
            case .png:
                data = UIImagePNGRepresentation(image) ?? Data()
            default:
                data = Data()
            }
            super.init(
                data: data,
                name: name,
                contentType: .image(type),
                charset: charset,
                contentTransferEncoding: contentTransferEncoding
            )
        }
#endif
}

// MARK: VideoData

public class VideoData: AnyFormData {
    
    public init(
        data: Data,
        name: String,
        type: VideoHTTPContentSubtype,
        charset: HTTPCharset? = nil,
        contentTransferEncoding: HTTPContentTransferEncoding? = nil) {
            super.init(
                data: data,
                name: name,
                contentType: .video(type),
                charset: charset,
                contentTransferEncoding: contentTransferEncoding
            )
        }
}
