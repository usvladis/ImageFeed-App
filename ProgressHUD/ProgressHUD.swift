//
//  ProgressHUD.swift
//  WeddingApp
//
//  Created by Владислав Усачев on 25.06.2024.
//

import ProgressHUD
import UIKit

final class UIBlockingProgressHUD{
    private static var window: UIWindow? {
        return UIApplication.shared.windows.first
    }
    
    static func show() {
        DispatchQueue.main.async {
            window?.isUserInteractionEnabled = false
            ProgressHUD.show()
        }
    }
    
    static func dismiss() {
        DispatchQueue.main.async {
            window?.isUserInteractionEnabled = true
            ProgressHUD.dismiss()
        }
    }
}
