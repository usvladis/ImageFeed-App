//
//  AlertPresenter.swift
//  WeddingApp
//
//  Created by Владислав Усачев on 26.06.2024.
//

import UIKit

class AlertPresenter {
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func showAlert(deleteHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: "Удалить фотографию?", message: "Вы уверены, что хотите удалить эту фотографию?", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        let delete = UIAlertAction(title: "Удалить", style: .destructive) { _ in
            deleteHandler()
        }
        
        alert.addAction(cancel)
        alert.addAction(delete)
        viewController?.present(alert, animated: true, completion: nil)
        
    }
    
    func showErrorAlert() {
        let alert = UIAlertController(title: "Упс!", message: "Вы не можете удалить эту фотографию, так как не являетесь ее автором!", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Понятно", style: .cancel, handler: nil)
        
        alert.addAction(cancel)
        viewController?.present(alert, animated: true, completion: nil)
        
    }
    
}
