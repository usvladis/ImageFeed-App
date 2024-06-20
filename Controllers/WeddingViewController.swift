//
//  ViewController.swift
//  WeddingApp
//
//  Created by Владислав Усачев on 24.05.2024.
//

import UIKit
import ProgressHUD
import Kingfisher

class WeddingViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    private var photos: [UIImage] = []
    private var photoItems: [PhotoItems] = []
    @IBOutlet private var tableView: UITableView!
    private let refreshControl = UIRefreshControl()
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
        fetchPhotosFromServer()
        
    }
    
    private func setUpTableView() {
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        tableView.dataSource = self
        tableView.delegate = self
        
        refreshControl.addTarget(self, action: #selector(refreshPhotoData(_:)), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    func configCell(for cell: TableViewCell, with indexPath: IndexPath) {
        let image = photos[indexPath.row]
        cell.cellImage.image = image
    }
    
    func configCell1(for cell: TableViewCell, with indexPath: IndexPath) {
        let image = photos[indexPath.row]
        cell.cellImage.image = image
    }
    
    @IBAction func didAddPhotoButtonTapped(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }
    func fetchPhotosFromServer() {
        let userHash = "123"
        PhotoService.shared.fetchPhoto(userHash: userHash) { result in
            switch result {
            case .success(let photoData):
                self.photoItems = photoData.items
                self.downloadPhotos()
            case .failure(let error):
                print("Error fetching photos: \(error)")
                DispatchQueue.main.async {
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
            PhotoService.shared.downloadPhoto(from: fullURL) { result in
                switch result {
                case .success(let image):
                    newPhotos[index] = image
                case .failure(let error):
                    print("Error downloading photo: \(error)")
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            self.photos = newPhotos.compactMap { $0 }
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
        }
    }
    
    @objc private func refreshPhotoData(_ sender: Any) {
        fetchPhotosFromServer()
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
        let image = photos[indexPath.row]
        let imageViewHeight = tableView.bounds.width / image.size.width * image.size.height
        let totalCellHeight = imageViewHeight
        return totalCellHeight
    }
}
extension WeddingViewController {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            UploadService.shared.uploadPhoto(image: pickedImage, createdByName: "YourName", userHash: "123") { result in
                switch result {
                case .success(let response):
                    print("Photo uploaded successfully: \(response)")
                    self.fetchPhotosFromServer()
                case .failure(let error):
                    print("Error uploading photo: \(error)")
                }
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
