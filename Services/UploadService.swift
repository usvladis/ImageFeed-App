//
//  UploadService.swift
//  WeddingApp
//
//  Created by Владислав Усачев on 01.06.2024.
//

import Foundation
import UIKit

class UploadService {
    static let shared = UploadService()
    private init() {}
    
    let uploadURL = "http://45.137.105.74/api/v1/storage/upload"
    
    func uploadPhoto(image: UIImage, createdByName: String, userHash: Int, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: uploadURL) else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("multipart/form-data", forHTTPHeaderField: "Content-Type")
        request.setValue("wyrTQzHUQZyu8WQrg9BmyDrMS8VdqKFW7q61Tede", forHTTPHeaderField: "Authentication")
        
        let boundary = UUID().uuidString
        let fullData = createBody(with: image, boundary: boundary, createdByName: createdByName, userHash: String(userHash))
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.uploadTask(with: request, from: fullData) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data, let responseString = String(data: data, encoding: .utf8) else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            completion(.success(responseString))
        }.resume()
    }
    
    private func createBody(with image: UIImage, boundary: String, createdByName: String, userHash: String) -> Data {
        var body = Data()
        
        guard let imageData = image.jpegData(compressionQuality: 1) else { return body }
        
        let filename = "photo.jpg"
        let mimetype = "image/jpeg"
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"files\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"createdByName\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(createdByName)\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"userHash\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(userHash)\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        return body
    }
}
