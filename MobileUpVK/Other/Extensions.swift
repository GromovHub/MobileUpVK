//
//  Project name: MobileUpVK
//  File name: Extensions.swift
//
//  Copyright © Gromov V.O., 2024
//

import UIKit

// for showing base alert everywhere
extension UIViewController {
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { alert in
            self.dismiss(animated: true)
        }))
        present(alert, animated: true, completion: nil)
    }
}

// format VK timestamp to Figma date template
extension Int {
    func toDateString(format: String = "d MMMM yyyy") -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(self))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date)
    }
}
