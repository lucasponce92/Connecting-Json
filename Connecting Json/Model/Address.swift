//
//  Address.swift
//  Connecting Json
//
//  Created by Lucas Ponce on 28-06-21.
//

import Foundation

class Address: Codable{
    
    var street: String
    var number: String
    
    init?(street:String,number:String){
        self.street = street
        self.number = number
    }
    
    convenience init(){
        self.init(street:"", number: "")!
    }
    
    enum CodingKeys: CodingKey {
        case street,number
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(street, forKey: .street)
        try container.encode(number, forKey: .number)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        street = try container.decode(String.self, forKey: .street)
        number = try container.decode(String.self, forKey: .number)
    }
}
