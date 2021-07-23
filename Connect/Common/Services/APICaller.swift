//
//  APICaller.swift
//  Connect
//
//  Created by Dino Martan on 23/07/2021.
//

import Foundation
import Alamofire

enum ApiUrl: String {
    
    case githubAccountDetails = "https://api.github.com/user"
    
}

final class ApiCaller {
    
    //MARK: - Public properties
    
    static let shared = ApiCaller()
    
    //MARK: - Private properties
    
    let alamofire = AF
    
    func getRequest<T: Codable>(type: T.Type, apiUrl: ApiUrl, headers: HTTPHeaders?, success: @escaping ((T) -> Void), failure: @escaping ((Error?) -> Void)) {
        guard let url = URL(string: apiUrl.rawValue) else {
            failure(nil)
            return
        }
        alamofire.request(url, method: .get, headers: headers).responseDecodable(of: T.self) { response in
            switch response.result {
            case .success(let data):
                success(data)
            case .failure(let error):
                failure(error)
            }
        }
    }
    
}
