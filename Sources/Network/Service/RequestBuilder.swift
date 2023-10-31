//
//  RequestBuilder.swift
//
//
//  Created by Cesar Silva on 31/10/23.
//

import Foundation

protocol RequestBuilderProtocol: AnyObject {
    func buildRequest(with endpoint: Endpoint, url: URL) -> URLRequest
}

public class RequestBuilder: RequestBuilderProtocol {
    func buildRequest(with endpoint: Endpoint, url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        
        request.httpMethod = endpoint.method.rawValue
        request.allHTTPHeaderFields = endpoint.headers
        
        if let parameters = endpoint.parameters {
            switch parameters {
            case .dictionary(let dictionary):
                request.httpBody = try? JSONSerialization.data(withJSONObject: dictionary, options: .fragmentsAllowed)
            case .encodable(let encodable):
                request.httpBody = try? JSONEncoder().encode(encodable)
            }
        }

        return request
    }
}
