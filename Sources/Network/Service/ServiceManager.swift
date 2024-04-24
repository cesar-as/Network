//
//  NetworkService.swift
//  
//
//  Created by Cesar Silva on 31/10/23.
//

import Foundation

protocol ServiceManagerProtocol: AnyObject {
    func request<T: Decodable>(with endpoint: Endpoint, decodeType: T.Type, completionHandler: @escaping(Result<T, NetworkError>) -> Void)
}

public class ServiceManager: ServiceManagerProtocol {
        
    static var shared: ServiceManager = ServiceManager()
    
    private var urlSession: URLSession
    private var requestBuilder: RequestBuilderProtocol
    
    init(urlSession: URLSession = URLSession.shared, requestBuilder: RequestBuilderProtocol = RequestBuilder()) {
        self.urlSession = urlSession
        self.requestBuilder = requestBuilder
    }
    
    func request<T>(with endpoint: Endpoint, decodeType: T.Type, completionHandler: @escaping (Result<T, NetworkError>) -> Void) where T : Decodable {
                
        guard let url = URL(string: endpoint.url) else {
            completionHandler(.failure(.invalidURL(url: endpoint.url)))
            return
        }
        
        let request = requestBuilder.buildRequest(with: endpoint, url: url)
        
        let task = urlSession.dataTask(with: request) { data, response, error in
            
            DispatchQueue.main.async {
                if let error {
                    completionHandler(.failure(.networkFailure(error)))
                    return
                }
                
                guard let data else {
                    completionHandler(.failure(.noData))
                    return
                }
                
                guard let response = response as? HTTPURLResponse, 200...299 ~= response.statusCode else {
                    completionHandler(.failure(.invalidResponse))
                    return
                }
                
                do {
                    let object: T = try JSONDecoder().decode(T.self, from: data)
                    completionHandler(.success(object))
                } catch {
                    completionHandler(.failure(.decodingError(error)))
                }
                
            }
        }
        
        task.resume()
    }
}
