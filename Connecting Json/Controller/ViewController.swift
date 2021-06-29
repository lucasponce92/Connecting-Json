//
//  ViewController.swift
//  Connecting Json
//
//  Created by Lucas Ponce on 28-06-21.
//

import UIKit

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

