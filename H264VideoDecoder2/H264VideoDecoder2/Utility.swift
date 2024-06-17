//
//  Utility.swift
//  H264VideoDecoder2
//
//  Created by Ravi Chokshi on 17/06/24.
//

import Foundation

import Foundation
import UIKit
import CoreLocation

class Utility {
    
    static func showAlert(vc: UIViewController,
                          title:String?, message:String?, buttons: [String] = ["Ok"],
                          buttonStyle:[UIAlertAction.Style] = [.default], completion:((_ index:Int) -> Void)? = nil) -> Void{
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        for index in 0..<buttons.count {
            
            let action = UIAlertAction(title: buttons[index], style: buttonStyle[index]) {_ in
                completion?(index)
            }
            alertController.addAction(action)
        }
        
        DispatchQueue.main.async {
            vc.present(alertController, animated: true, completion: nil)
        }
    }
}
