//
//  URLSession+Request.swift
//  NStackSDK
//
//  Created by Dominik Hadl on 25/09/2018.
//  Copyright © 2018 Nodes ApS. All rights reserved.
//

import Foundation

extension URLSession {
    func request(_ urlString: String,
                 method: HTTPMethod = .get,
                 parameters: [String: Any]? = nil,
                 headers: [String: String]? = nil) -> URLRequest {
        let url: URL
        var request: URLRequest
        if method == .get {
            url = URL(string: urlString + "?" + generateQueryString(from: parameters))!
            request = URLRequest(url: url)
        } else {
            url = URL(string: urlString)!
            request = URLRequest(url: url)
            request.httpBody = generateQueryString(from: parameters).data(using: .utf8)
        }

        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        return request
    }

    func dataTask<T>(with request: URLRequest,
                     completionHandler: @escaping (Result<T>) -> Void) -> URLSessionDataTask {
        let handler = dataHandler(handler: completionHandler)
        let task = dataTask(with: request, completionHandler: handler)
        return task
    }

    @discardableResult
    func startDataTask<T>(with request: URLRequest,
                          completionHandler: @escaping (Result<T>) -> Void) -> URLSessionDataTask {
        let task = dataTask(with: request, completionHandler: completionHandler)
        task.resume()
        return task
    }

    func dataTask<T: Codable>(with request: URLRequest,
                              convertFromSnakeCase: Bool = false,
                              completionHandler: @escaping (Result<T>) -> Void) -> URLSessionDataTask {
        let handler = dataHandler(convertFromSnakeCase: convertFromSnakeCase, handler: completionHandler)
        let task = dataTask(with: request, completionHandler: handler)
        return task
    }

    @discardableResult
    func startDataTask<T: Codable>(with request: URLRequest,
                                   convertFromSnakeCase: Bool = false,
                                   completionHandler: @escaping (Result<T>) -> Void) -> URLSessionDataTask {
        let task = dataTask(with: request, convertFromSnakeCase: convertFromSnakeCase, completionHandler: completionHandler)
        task.resume()
        return task
    }

    func dataTask<T: WrapperModelType>(with request: URLRequest,
                                       wrapperType: T.Type,
                                       convertFromSnakeCase: Bool = false,
                                       completionHandler: @escaping (Result<T.ModelType>) -> Void) -> URLSessionDataTask {
        let handler = dataHandler(convertFromSnakeCase: convertFromSnakeCase, handler: completionHandler, wrapperType: wrapperType)
        let task = dataTask(with: request, completionHandler: handler)
        return task
    }

    @discardableResult
    func startDataTask<T: WrapperModelType>(with request: URLRequest,
                                            wrapperType: T.Type,
                                            convertFromSnakeCase: Bool = false,
                                            completionHandler: @escaping (Result<T.ModelType>) -> Void) -> URLSessionDataTask {
        let task = dataTask(with: request, wrapperType: wrapperType, convertFromSnakeCase: convertFromSnakeCase, completionHandler: completionHandler)
        task.resume()
        return task
    }

    private func dataHandler<T>(handler: @escaping (Result<T>) -> Void) -> ((Data?, URLResponse?, Error?) -> Void) {
        return { data, response, error in
            do {
                let data = try self.validate(data, response, error)
                let decoded = try JSONSerialization.jsonObject(with: data, options: [])

                guard let model = decoded as? T else {
                    // FIXME: Fix this
                    throw NSError(domain: "", code: 10, userInfo: nil)
                }
                handler(Result.success(model))

            } catch {
                handler(.failure(error))
            }
        }
    }

    private func dataHandler<T: Codable>(convertFromSnakeCase: Bool = false, handler: @escaping (Result<T>) -> Void) -> ((Data?, URLResponse?, Error?) -> Void) {
        return { data, response, error in
            do {
                let data = try self.validate(data, response, error)
                let decoder = JSONDecoder()
                if convertFromSnakeCase {
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                }

                let decoded = try decoder.decode(T.self, from: data)
                handler(Result.success(decoded))
            } catch {
                handler(.failure(error))
            }
        }
    }

    private func dataHandler<T: WrapperModelType>(convertFromSnakeCase: Bool = false,
                                                  handler: @escaping (Result<T.ModelType>) -> Void,
                                                  wrapperType: T.Type) -> ((Data?, URLResponse?, Error?) -> Void) {
        return { data, response, error in
            do {
                let data = try self.validate(data, response, error)
                let decoder = JSONDecoder()
                if convertFromSnakeCase {
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                }

                let parentData = try decoder.decode(wrapperType, from: data)
                handler(Result.success(parentData.model))
            } catch {
                handler(.failure(error))
            }
        }
    }

    private func validate(_ data: Data?, _ response: URLResponse?, _ error: Error?) throws -> Data {
        // FIXME: Finish this
        guard let response = response as? HTTPURLResponse else {
            throw NSError(domain: "", code: 0, userInfo: nil)
        }

        switch HTTPStatusCode(rawValue: response.statusCode)! {
        case .ok, .created: // Success
            guard let data = data else {
                throw NSError(domain: "", code: 0, userInfo: nil)
            }

            return data

        default:
            let error = NSError(domain: "", code: 0, userInfo: nil)
            throw error
        }
    }

    // MARK: - Helper function

    private func generateQueryString(from parameters: [String: Any?]?) -> String {
        guard let parameters = parameters else { return "" }
        var queryString = ""
        parameters.forEach { item in
            if let value = item.value {
                queryString += "\(item.key)=\(value)&"
            }
        }
        if queryString.last != nil { queryString.removeLast() }
        // plus was turning into white space when turned into data
        queryString = queryString.replacingOccurrences(of: "+", with: "%2B")

        return queryString
    }
}
