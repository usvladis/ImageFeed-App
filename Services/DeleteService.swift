//
//  DeleteService.swift
//  WeddingApp
//
//  Created by Владислав Усачев on 25.06.2024.
//

import Foundation


class DeleteService{
    static let shared = DeleteService()
    private init() {}
    
    func deletePhoto (userHash: Int, fileId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let url = URL(string: "http://45.137.105.74/api/v1/storage/file")!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("text/plain", forHTTPHeaderField: "Accept")
        request.setValue(Constants.accessToken, forHTTPHeaderField: "Authentication")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "userHash": String(userHash),
            "fileId": fileId
        ]
        
        do{
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) {data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to delete photo"])
                completion(.failure(error))
                return
            }
            
            completion(.success(()))
        }.resume()
    }
}
