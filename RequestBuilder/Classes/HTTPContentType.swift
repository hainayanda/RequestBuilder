//
//  HTTPContentType.swift
//  RequestBuilder
//
//  Created by Nayanda Haberty on 16/2/23.
//

import Foundation

public enum HTTPContentType {
    case text(TextHTTPContentSubtype)
    case application(ApplicationHTTPContentSubtype)
    case audio(AudioHTTPContentSubtype)
    case image(ImageHTTPContentSubtype)
    case multipart(MultipartHTTPContentSubtype)
    case video(VideoHTTPContentSubtype)
    case any(String)
    
    var stringRepresentation: String {
        switch self {
        case .text(let subtype):
            return "text/\(subtype.stringRepresentation)"
        case .application(let subtype):
            return "application/\(subtype.stringRepresentation)"
        case .audio(let subtype):
            return "audio/\(subtype.stringRepresentation)"
        case .image(let subtype):
            return "image/\(subtype.stringRepresentation)"
        case .multipart(let subtype):
            return "multipart/\(subtype.stringRepresentation)"
        case .video(let subtype):
            return "video/\(subtype.stringRepresentation)"
        case .any(let type):
            return type
        }
    }
}

public enum TextHTTPContentSubtype {
    case html
    case plain
    case css
    case csv
    case xml
    case any(String)
    
    var stringRepresentation: String {
        switch self {
        case .html:
            return "html"
        case .plain:
            return "plain"
        case .css:
            return "css"
        case .csv:
            return "csv"
        case .xml:
            return "xml"
        case .any(let type):
            return type
        }
    }
}

public enum ApplicationHTTPContentSubtype {
    case ediX12
    case ediFact
    case javascript
    case octetStream
    case ogg
    case pdf
    case msword
    case xhtmlXml
    case xShockwaveFlash
    case json
    case ldJson
    case xml
    case zip
    case xWwwFormUrlencoded
    case vndOasisOpendocumentText
    case vndOasisOpendocumentSpreadsheet
    case vndOasisOpendocumentPresentation
    case vndOasisOpendocumentGraphics
    case vndOpenxmlformatsOfficedocumentSpreadsheetmlSheet
    case vndOpenxmlformatsOfficedocumentPresentationmlPresentation
    case vndOpenxmlformatsOfficedocumentWordprocessingmlDocument
    case vndMsExcel
    case vndMsPowerpoint
    case vncMozillaXulXml
    case any(String)
    
    var stringRepresentation: String {
        switch self {
        case .ediX12:
            return "EDI-X12"
        case .ediFact:
            return "EDIFACT"
        case .javascript:
            return "javascript"
        case .octetStream:
            return "octet-stream"
        case .ogg:
            return "ogg"
        case .pdf:
            return "pdf"
        case .xhtmlXml:
            return "xhtml+xml"
        case .xShockwaveFlash:
            return "x-shockwave-flash"
        case .json:
            return "json"
        case .ldJson:
            return "ld+json"
        case .xml:
            return "xml"
        case .zip:
            return "zip"
        case .xWwwFormUrlencoded:
            return "x-www-form-urlencoded"
        case .vndOasisOpendocumentText:
            return "vnd.oasis.opendocument.text"
        case .vndOasisOpendocumentSpreadsheet:
            return "vnd.oasis.opendocument.spreadsheet"
        case .vndOasisOpendocumentPresentation:
            return "vnd.oasis.opendocument.presentation"
        case .vndOasisOpendocumentGraphics:
            return "vnd.oasis.opendocument.graphics"
        case .vndOpenxmlformatsOfficedocumentSpreadsheetmlSheet:
            return "vnd.openxmlformats-officedocument.spreadsheetml.sheet"
        case .vndOpenxmlformatsOfficedocumentPresentationmlPresentation:
            return "vnd.openxmlformats-officedocument.presentationml.presentation"
        case .vndOpenxmlformatsOfficedocumentWordprocessingmlDocument:
            return "vnd.openxmlformats-officedocument.wordprocessingml.document"
        case .msword:
            return "msword"
        case .vndMsExcel:
            return "vnd.ms-excel"
        case .vndMsPowerpoint:
            return "vnd.ms-powerpoint"
        case .vncMozillaXulXml:
            return "vnd.mozilla.xul+xml"
        case .any(let type):
            return type
        }
    }
}

public enum AudioHTTPContentSubtype {
    case mpeg
    case xMsWma
    case vndRnRealaudio
    case xWav
    case any(String)
    
    var stringRepresentation: String {
        switch self {
        case .mpeg:
            return "mpeg"
        case .xMsWma:
            return "x-ms-wma"
        case .vndRnRealaudio:
            return "vnd.rn-realaudio"
        case .xWav:
            return "x-wav"
        case .any(let type):
            return type
        }
    }
}

public enum ImageHTTPContentSubtype {
    case gif
    case jpeg
    case png
    case tiff
    case vndMicrosoftIcon
    case xIcon
    case vndDjvu
    case svgXml
    case any(String)
    
    var stringRepresentation: String {
        switch self {
        case .gif:
            return "gif"
        case .jpeg:
            return "jpeg"
        case .png:
            return "png"
        case .tiff:
            return "tiff"
        case .vndMicrosoftIcon:
            return "vnd.microsoft.icon"
        case .xIcon:
            return "x-icon"
        case .vndDjvu:
            return "vnd.djvu"
        case .svgXml:
            return "svg+xml"
        case .any(let type):
            return type
        }
    }
}

public enum MultipartHTTPContentSubtype {
    case mixed
    case alternative
    case related
    case formData
    case any(String)
    
    var stringRepresentation: String {
        switch self {
        case .mixed:
            return "mixed"
        case .alternative:
            return "alternative"
        case .related:
            return "related"
        case .formData:
            return "form-data"
        case .any(let type):
            return type
        }
    }
}

public enum VideoHTTPContentSubtype {
    case mpeg
    case mp4
    case quicktime
    case xMsWmv
    case xMsvideo
    case xFlv
    case webm
    case any(String)
    
    var stringRepresentation: String {
        switch self {
        case .mpeg:
            return "mpeg"
        case .mp4:
            return "mp4"
        case .quicktime:
            return "quicktime"
        case .xMsWmv:
            return "x-ms-wmv"
        case .xMsvideo:
            return "x-msvideo"
        case .xFlv:
            return "x-flv"
        case .webm:
            return "webm"
        case .any(let type):
            return type
        }
    }
}
