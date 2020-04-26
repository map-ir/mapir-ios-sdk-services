//
//  UIViewController+AlertAdditions.swift
//  MapirServices Swift Example
//
//  Created by Alireza Asadi on 6/2/1399 AP.
//  Copyright © 1399 AP Map. All rights reserved.
//

import UIKit

extension UIViewController {
    func showAlert(title: String, message: String, dismissCompletionHandler: ((UIAlertAction) -> Void)? = nil ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Dismiss", style: .default, handler: dismissCompletionHandler)

        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
}
