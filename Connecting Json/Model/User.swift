//
//  User.swift
//  Connecting Json
//
//  Created by Lucas Ponce on 28-06-21.
//

import Foundation

class User: Codable{
    
    var name : String
    var lastName : String
    var email : String
    var address : Address

    init?(name:String,lastName:String,email:String,address:Address){
        
        self.name = name
        self.lastName = lastName
        self.email = email
        self.address = address
    }
    
    convenience init(){
        self.init(name:"", lastName:"", email:"",address:Address())!
    }
    
    enum CodingKeys: CodingKey {
        case name, last_name, email, address
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(name, forKey: .name)
        try container.encode(lastName, forKey: .last_name)
        try container.encode(email, forKey: .email)
        try container.encode(address, forKey: .address)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        name = try container.decode(String.self, forKey: .name)
        lastName = try container.decode(String.self, forKey: .last_name)
        email = try container.decode(String.self, forKey: .email)
        address = try container.decode(Address.self, forKey: .address)
    }
}
