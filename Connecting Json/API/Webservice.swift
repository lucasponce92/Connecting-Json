//
//  Webservice.swift
//  Connecting Json
//
//  Created by Lucas Ponce on 28-06-21.
//

import Foundation

class Webservice{
    
    class func invoke(urlPath: String, encoded: Data?, httpMethod: String, finished: @escaping (_ isSuccess: Data?, Bool, String?)-> Void) {
        
        if let endpoint = URL(string: "\(urlPath)") {
            
            var request = URLRequest(url: endpoint)
            request.httpMethod = httpMethod
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            if httpMethod != HttpMethod.GET && encoded != nil {
                request.httpBody = encoded
            }
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                
                do {
                    if let httpResponse = response as? HTTPURLResponse {
                        
                        if httpResponse.statusCode == HttpStatus.ok.rawValue {
                            
                            guard let readableJson = try JSONSerialization.jsonObject(with: data ?? Data(), options:[]) as? NSDictionary else {
                                return
                            }
                            
                            print(readableJson)
                            
                            finished (data!, true, nil)
                        }
                        
                        if httpResponse.statusCode == HttpStatus.created.rawValue { finished (data!, true, nil) }
                        
                        if httpResponse.statusCode == HttpStatus.noContent.rawValue { finished (nil, true, nil) }
                        
                        if httpResponse.statusCode == HttpStatus.movedPermanently.rawValue { finished (nil, false, "App needs update") }
                        
                        if httpResponse.statusCode == HttpStatus.badRequest.rawValue {
                            
                            guard let readableJson = try JSONSerialization.jsonObject(with: data ?? Data(), options:[]) as? NSDictionary else {
                                return
                            }
                            
                             print(readableJson)
                            
                            finished (data!, false, "Complete all fields")
                        }
                        
                        if httpResponse.statusCode == HttpStatus.unauthorized.rawValue { finished (nil, false, "Session expired") }
                        
                        if httpResponse.statusCode == HttpStatus.forbidden.rawValue { finished (nil, false, "No tienes los permisos para realizar esta operación") }
                        
                        if httpResponse.statusCode == HttpStatus.notFound.rawValue { finished (nil, false, "not found URL") }
                        
                        if httpResponse.statusCode == HttpStatus.unsupportedMediaType.rawValue { finished (nil, false, "App needs update") }
                        
                        if httpResponse.statusCode == HttpStatus.internalServerError.rawValue { finished (nil, false, "Error occurred") }
                        
                        if httpResponse.statusCode == HttpStatus.badGateway.rawValue { finished (nil, false, "Error occurred") }
                        
                        if httpResponse.statusCode == HttpStatus.gatewayTimeout.rawValue { finished (nil, false, "gateway Timeout") }
                        
                    }
                    
                    print(data ?? "No data")
                    
                } catch let error as NSError {
                    print(error.debugDescription)
                }
            }.resume()
        }
    }
}
