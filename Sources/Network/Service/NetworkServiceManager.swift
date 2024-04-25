//
//  NetworkService.swift
//  
//
//  Created by Cesar Silva on 31/10/23.
//

import Foundation

protocol NetworkServiceManagerProtocol: AnyObject {
    func request<T: Decodable>(with endpoint: Endpoint, decodeType: T.Type, completionHandler: @escaping(Result<T, NetworkError>) -> Void)
}

public class NetworkServiceManager: NetworkServiceManagerProtocol {
        
    public static var shared: NetworkServiceManager = NetworkServiceManager()
    
    private var urlSession: URLSession
    private var requestBuilder: RequestBuilderProtocol
    private var decoder: JSONDecoder
    
    init(urlSession: URLSession = URLSession.shared, requestBuilder: RequestBuilderProtocol = RequestBuilder(), decoder: JSONDecoder = JSONDecoder()) {
        self.urlSession = urlSession
        self.requestBuilder = requestBuilder
        self.decoder = decoder
    }
    
    public func request<T>(with endpoint: Endpoint, decodeType: T.Type, completionHandler: @escaping (Result<T, NetworkError>) -> Void) where T : Decodable {
                
        guard let url = URL(string: endpoint.url) else {
            NetworkLogger.logError(error: .invalidURL(url: endpoint.url))
            completionHandler(.failure(.invalidURL(url: endpoint.url)))
            return
        }
        
        let request = requestBuilder.buildRequest(with: endpoint, url: url)
        
        let task = urlSession.dataTask(with: request) { data, response, error in
            NetworkLogger.log(request: request, response: response, data: data, error: error)
            
            DispatchQueue.main.async {
                if let error {
                    NetworkLogger.logError(error: .networkFailure(error))
                    completionHandler(.failure(.networkFailure(error)))
                    return
                }
                
                guard let data else {
                    NetworkLogger.logError(error: .noData)
                    completionHandler(.failure(.noData))
                    return
                }
                
                guard let response = response as? HTTPURLResponse, 200...299 ~= response.statusCode else {
                    NetworkLogger.logError(error: .invalidResponse)
                    completionHandler(.failure(.invalidResponse))
                    return
                }
                
                do {
                    let object: T = try self.decoder.decode(T.self, from: data)
                    completionHandler(.success(object))
                } catch {
                    NetworkLogger.logError(error: .decodingError(error))
                    completionHandler(.failure(.decodingError(error)))
                }
                
            }
        }
        
        task.resume()
    }
}
