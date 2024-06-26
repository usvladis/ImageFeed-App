//
//  ViewController.swift
//  WeddingApp
//
//  Created by Владислав Усачев on 24.05.2024.
//

import UIKit

class WeddingViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    private var photos: [UIImage] = []
    private var photoItems: [PhotoItems] = []
    @IBOutlet private var tableView: UITableView!
    private let refreshControl = UIRefreshControl()
    
    private var photoService = PhotoService.shared
    private var deleteService = DeleteService.shared
    private var alertPresenter: AlertPresenter?
    
    private let userHash = UserDefaults.standard.integer(forKey: "userHash")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        alertPresenter = AlertPresenter(viewController: self)
        UIBlockingProgressHUD.show()
        setUpTableView()
        fetchPhotosFromServer()
        
    }
    
    private func setUpTableView() {
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        tableView.dataSource = self
        tableView.delegate = self
        
        refreshControl.addTarget(self, action: #selector(refreshPhotoData(_:)), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        //Реализуем показ диалогового окна при долгом нажатии на ячейку
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        tableView.addGestureRecognizer(longPressGesture)
    }
    
    func configCell(for cell: TableViewCell, with indexPath: IndexPath) {
        guard indexPath.row < photos.count else {
            return
        }
        let image = photos[indexPath.row]
        cell.cellImage.image = image
    }
    
    
    @IBAction func didAddPhotoButtonTapped(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @objc private func refreshPhotoData(_ sender: Any) {
        fetchPhotosFromServer()
    }
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        
        let point = gesture.location(in: tableView)
        if let indexPath = tableView.indexPathForRow(at: point) {
            alertPresenter?.showAlert { [weak self] in
                self?.deletePhoto(at: indexPath)
            }
        }
    }
    
}

extension WeddingViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCell.reuseIdentifire, for: indexPath)
        guard let imageListCell = cell as? TableViewCell else {
            return UITableViewCell()
        }
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
}
extension WeddingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard indexPath.row < photos.count else {
            return 0
        }
        let image = photos[indexPath.row]
        let imageViewHeight = tableView.bounds.width / image.size.width * image.size.height
        let totalCellHeight = imageViewHeight
        return totalCellHeight
    }
}
extension WeddingViewController {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            UploadService.shared.uploadPhoto(image: pickedImage, createdByName: "YourName", userHash: userHash) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let response):
                        print("Photo uploaded successfully: \(response)")
                        self.fetchPhotosFromServer()
                    case .failure(let error):
                        print("Error uploading photo: \(error)")
                    }
                }
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func fetchPhotosFromServer() {
        photoService.fetchPhoto(userHash: userHash) { result in
            DispatchQueue.main.async {
            switch result {
            case .success(let photoData):
                self.photoItems = photoData.items
                self.downloadPhotos()
            case .failure(let error):
                print("Error fetching photos: \(error)")
                    self.refreshControl.endRefreshing()
                }
            }
        }
    }
    func downloadPhotos() {
        photos.removeAll()  // Очищаем текущий массив фотографий перед загрузкой новых
        let baseURL = "http://45.137.105.74"
        let dispatchGroup = DispatchGroup()
        var newPhotos: [UIImage?] = Array(repeating: nil, count: photoItems.count)
        
        for (index, item) in photoItems.enumerated() {
            let fullURL = baseURL + item.rawLink
            dispatchGroup.enter()
            photoService.downloadPhoto(from: fullURL) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let image):
                        UIBlockingProgressHUD.dismiss()
                        newPhotos[index] = image
                    case .failure(let error):
                        UIBlockingProgressHUD.dismiss()
                        print("Error downloading photo: \(error)")
                    }
                    dispatchGroup.leave()
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            self.photos = newPhotos.compactMap { $0 }
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
        }
    }
    
    private func deletePhoto(at indexPath: IndexPath) {
        let photoItem = photoItems[indexPath.row]
        
        deleteService.deletePhoto(userHash: userHash, fileId: photoItem.id) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success():
                    self?.photos.remove(at: indexPath.row)
                    self?.photoItems.remove(at: indexPath.row)
                    self?.tableView.deleteRows(at: [indexPath], with: .automatic)
                    print("Photo deleted successfully.")
                case .failure(let error):
                    self?.alertPresenter?.showErrorAlert()
                    print("Error deleting photo: \(error)")
                    // Optionally, show an alert to the user about the failure
                }
            }
        }
    }
}
