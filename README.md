# JSON and Swift project
In this project I'm sharing with you the way I approach connecting my mobile apps with APIs using webservices and Json data
In addition you'll be seeing some MVC (model-view-controller) practices, if you're not familiar with MVC I highly recommend you to study a little bit and implement it into your programming.

## Introduction

pending...

## Classes

The first thing we'll do is to define our classes. We will work with User and Address, I wanted to show you how to consume a webservice and decode Json data into classes, using one class inside another class, since I've never seen a tutorial covering this.

### User

```swift
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
```

### Address

```swift
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
```

## Endpoints

I highly recomend to separate your code, so in this case I will have a file just to get the endpoints (urls) for my webservices

```swift
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
```

## Webservices

The JSON data I'm getting from the webservice is this one: 
"{"name":"John","last_name":"Doe","email":"johndoe@mail.com","address":{"street":"the best street","number":"321"}}" 

I generated it using this website https://jsonkeeper.com/ and it generated this link https://jsonkeeper.com/b/F7P0 which is supposed to host my JSON data but I don't know for how long, so if at the moment you're trying to use this code, you're not getting anything from the link, just generate some new JSON data copying the string above and using the website I just mentioned

```swift
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
```

## Usage

```swift
class ViewController: UIViewController {
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var lastName: UILabel!
    @IBOutlet weak var email: UILabel!
    
    @IBOutlet weak var street: UILabel!
    @IBOutlet weak var number: UILabel!
    
    var user_id = "F7P0"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // SOME LOADING VIEW
        Webservice.invoke(urlPath: Endpoints.getEndpointUser(id: user_id), encoded: nil, httpMethod: HttpMethod.GET, finished: { data, status, mensaje in
            OperationQueue.main.addOperation {
                
                if status {
                    
                    let decodedUser = try! JSONDecoder().decode(User.self, from: data! )
                    
                    self.name.text = "name: \(decodedUser.name)"
                    self.lastName.text = "last_name: \(decodedUser.lastName)"
                    self.email.text = "email: \(decodedUser.email)"
                    self.street.text = "street: \(decodedUser.address.street)"
                    self.number.text = "numbre: \(decodedUser.address.number)"
                
                } else {
                    print("unable to complete webservice")
                }
                
                //END LOADING VIEW
            }
        })
    }
}
```
