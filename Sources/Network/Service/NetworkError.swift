//
//  NetworkError.swift
//  
//
//  Created by Cesar Silva on 31/10/23.
//

import Foundation

public enum NetworkError: Error {
    case invalidURL(url: String)
    case noData
    case invalidResponse
    case decodingError(Error)
    case networkFailure(Error)
}

extension NetworkError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidURL(let url):
            return "Invalid URL: \(url)"
        case .noData:
            return "Data not received from API"
        case .invalidResponse:
            return "Invalid response from API"
        case .decodingError(let error):
            return "Decoding failure: \(error.localizedDescription)"
        case .networkFailure(let error):
            return "Network failure: \(error.localizedDescription)"
        }
    }
}
