//
//  NetworkClient.swift
//  WeddingApp
//
//  Created by Владислав Усачев on 31.05.2024.
//

import Foundation
import UIKit
struct PhotoData: Codable{
    var items: [PhotoItems]
}

struct PhotoItems: Codable{
    let id: String
    let createdByName: String
    let rawLink: String
    let created: String
    var liked: Bool
    var likesCount: Int
}

class PhotoService{
    static let shared = PhotoService()
    private init() {}
    
    let baseURL = "http://45.137.105.74/api/v1/storage/pagination"
    
    func fetchPhoto(userHash: String, page: Int = 1, onPage: Int = 50, completion: @escaping (Result<PhotoData, Error>) -> Void)  {
        guard var urlComponents = URLComponents(string: baseURL) else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        urlComponents.queryItems = [
            URLQueryItem(name: "userHash", value: userHash),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "onPage", value: String(onPage))
        ]
        guard let url = urlComponents.url else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL components"])))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("wyrTQzHUQZyu8WQrg9BmyDrMS8VdqKFW7q61Tede", forHTTPHeaderField: "Authentication")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let photoData = try decoder.decode(PhotoData.self, from: data)
                completion(.success(photoData))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func downloadPhoto(from url: String, completion: @escaping (Result<UIImage, Error>) -> Void) {
        guard let url = URL(string: url) else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data, let image = UIImage(data: data) else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No image data received"])))
                return
            }
            
            completion(.success(image))
        }.resume()
    }
}
