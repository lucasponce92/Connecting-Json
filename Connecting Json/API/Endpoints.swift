//
//  Endpoints.swift
//  Connecting Json
//
//  Created by Lucas Ponce on 29-06-21.
//

import Foundation

class Endpoints{
    
    static var urlPath = "https://jsonkeeper.com/b/"
    
    class func getEndpointUser(id:String?) -> String {
        
        if id != nil {
            return "\(urlPath)\(id!)/"
        }else{
            return "some other url"
        }
    }
}
