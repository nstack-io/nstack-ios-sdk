//
//  MultipartBuilder.swift
//  NStackSDK
//
//  Created by Tiago Bras on 01/11/2019.
//  Copyright © 2019 Nodes ApS. All rights reserved.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

class MultipartBuilder {
    struct Part: Hashable {
        var name: String
        var data: Data
        var filename: String?
        var contentType: String?
    }

    private var boundary: String
    private var parts = Set<Part>()

    init(boundary: String) {
        self.boundary = boundary
    }

    #if canImport(UIKit)
    /// Appends image field if value != nil. If there's already field with the same name,
    /// that field will be replaced.
    /// - Parameter name: field's name.
    @discardableResult
    func append(name: String, image: UIImage?, jpegQuality: CGFloat) -> MultipartBuilder {
        guard let data = image?.jpegData(compressionQuality: jpegQuality) else { return self }

        parts.insert(Part(
            name: name,
            data: data,
            filename: "\(UUID().uuidString).jpeg",
            contentType: "image/jpeg"))

        return self
    }
    #endif
    

    /// Appends field if value != nil. If there's already field with the same name,
    /// that field will be replaced.
    /// - Parameter name: field's name.
    /// - Parameter value: field's value.
    @discardableResult
    func append(name: String, value: String?) -> MultipartBuilder {
        guard let data = value?.data(using: .utf8) else { return self }

        parts.insert(Part(name: name, data: data))

        return self
    }

    /// Joins all parts into one, ready to be passed to a request.
    func build() -> Data {
        var data = Data()

        for part in parts {
            data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)

            let filename = part.filename.map({ "; filename=\"\($0)\"" }) ?? ""

            let contentDisposition = "Content-Disposition: form-data; name=\"\(part.name)\"\(filename)\r\n"

            data.append(contentDisposition.data(using: .utf8)!)

            if let contentType = part.contentType {
                data.append("Content-Type: \(contentType)\r\n\r\n".data(using: .utf8)!)
            } else {
                data.append("\r\n".data(using: .utf8)!)
            }

            data.append(part.data)
        }

        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

        return data
    }
}
