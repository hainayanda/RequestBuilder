//
//  FormDataBuilder.swift
//  RequestBuilder
//
//  Created by Nayanda Haberty on 16/2/23.
//

import Foundation

@resultBuilder
public struct FormDataBuilder {
    public typealias Expression = FormDataConvertible?
    public typealias Component = FormDataConvertibles
    
    // Provide contextual expression to partial result
    public static func buildExpression(_ expression: Expression) -> Component {
        guard let expression else { return [] }
        return [expression]
    }
    
    // Provide ability to have if-else condition and switch
    @inlinable public static func buildEither(first component: Component) -> Component {
        component
    }
    
    // Provide ability to have if-else condition and switch
    @inlinable public static func buildEither(second component: Component) -> Component {
        component
    }
    
    // Provide ability to have if without else
    @inlinable public static func buildOptional(_ component: Component?) -> Component {
        component ?? []
    }
    
    // Provide ability to have for loop
    @inlinable public static func buildArray(_ components: [Component]) -> Component {
        components.flatMap { $0 }
    }
    
    // required to combined all of the expression into one component
    @inlinable public static func buildBlock(_ components: Component...) -> Component {
        buildArray(components)
    }
}

public extension BareHTTPURLRequestBuilding {
    
    func multipartFormBody(boundary: String = UUID().uuidString, @FormDataBuilder formBuilder: () -> FormDataConvertibles) throws -> PayloadedBuilder {
        let contentType = HTTPContentType.multipart(.formData)
        let formData = try formBuilder().reduce(Data()) { partialResult, convertible in
            var nextResult = partialResult
            nextResult.append(try convertible.formData(using: boundary))
            return nextResult
        }
        return addHeaders(value: "\(contentType.stringRepresentation); boundary=\(boundary)", forField: "Content-Type")
            .httpBody(formData)
    }
}
