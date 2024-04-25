//
//  File.swift
//  
//
//  Created by Cesar Silva on 24/04/24.
//

import Foundation
import OSLog

struct NetworkLogger {
    
    private static let logger = Logger()
    
    static func log(request: URLRequest?, response: URLResponse?, data: Data?, error: Error?, verbose: Bool = true) {
        logger.debug("-------- REQUEST START --------")
        
        if let url = request?.url {
            logger.debug("Request URL: \(url.absoluteString)")
        }
        
        if let httpMethod = request?.httpMethod {
            logger.debug("HTTP Method: \(httpMethod)")
        }
        
        if verbose, let headers = request?.allHTTPHeaderFields {
            logger.debug("Headers: \(headers)")
        }
        
        if verbose, let body = request?.httpBody, let bodyString = String(data: body, encoding: .utf8) {
            logger.debug("Body Request: \(bodyString)")
        }
        
        if let httpResponse = response as? HTTPURLResponse {
            let statusCode = httpResponse.statusCode
            let statusIcon = (200...299).contains(statusCode) ? "✅" : "❌"
            logger.debug("Status Code: \(statusCode) \(statusIcon)")
        } else if let error {
            logger.error("Error: \(error.localizedDescription)")
        } else {
            logger.error("Error: No Response and No Error")
        }
        
        if verbose, let headers = (response as? HTTPURLResponse)?.allHeaderFields as? [String: Any] {
            logger.debug("Response Headers: \(headers)")
        }
        
        if let data = data {
            do {
                let jsonObject = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
                
                if let jsonStr = String(data: jsonData, encoding: .utf8) {
                    logger.debug("JSON Response: ⬇️\n\(jsonStr)")
                }
            } catch let serializationError {
                logger.error("Error: Failed to serialize JSON: \(serializationError)")
            }
        }

        logger.debug("-------- REQUEST END --------\n")
    }
    
    static func logError(error: NetworkError) {
        logger.error("Error: \(error.errorDescription ?? "")")
    }
}
