//
//  DatabaseHandler.swift
//  Connect
//
//  Created by Dino Martan on 24/07/2021.
//

import Foundation
import Firebase

enum CollectionsConstants: String {
    
    case projects = "projects"
    case userDetails = "userDetails"
    
}

enum DatabaseFieldNameConstants: String {
    
    case needTags = "needTags"
    case ownerId = "ownerId"
    case ownerImage = "ownerImage"
    case ownerName = "ownerName"
    
}

enum DatabaseImagePathContants: String {
    
    case profileImages = "images/profile"
    
}

enum DocumentIdType {
    
    case custom(id: String)
    case random
    
}

final class DatabaseHandler {
    
    //MARK: - Public properties

    static let shared = DatabaseHandler()
    
    //MARK: - Private properties

    private let db = Firestore.firestore()
    private let storageRef = Storage.storage().reference()
    
    //MARK: - Public non generic methods
    
    
    //MARK: - Public generic methods
    
    func getDataWhere<T: Codable>(type: T.Type, collection: CollectionsConstants, whereField: DatabaseFieldNameConstants, isEqualTo: Any, success: @escaping (([DatabaseDocument]) -> Void), failure: @escaping ((Error) -> Void)) {
        
        db.collection(collection.rawValue).whereField(whereField.rawValue, isEqualTo: isEqualTo).getDocuments() { (querySnapshot, error) in
            if let error = error { failure(error) }
            else {
                var databaseResponses: [DatabaseDocument] = []
                for document in querySnapshot!.documents {
                    guard let object = document.getObject(type: T.self) else { continue }
                    let databaseResponse = DatabaseDocument(id: document.documentID, object: object)
                    databaseResponses.append(databaseResponse)
                }
                success(databaseResponses)
            }
        }
    }
    
    func getDataWhereArrayContains<T: Codable>(type: T.Type, collection: CollectionsConstants, whereField: DatabaseFieldNameConstants, contains: Any, success: @escaping (([DatabaseDocument]) -> Void), failure: @escaping ((Error) -> Void)) {
        
        db.collection(collection.rawValue).whereField(whereField.rawValue, arrayContains: contains).getDocuments() { (querySnapshot, error) in
            if let error = error { failure(error) }
            else {
                var databaseResponses: [DatabaseDocument] = []
                for document in querySnapshot!.documents {
                    guard let object = document.getObject(type: T.self) else { continue }
                    let databaseResponse = DatabaseDocument(id: document.documentID, object: object)
                    databaseResponses.append(databaseResponse)
                }
                success(databaseResponses)
            }
        }
    }
    
    func getObjectByDocumentId<T: Codable>(type: T.Type, collection: CollectionsConstants, documentId: String, success: @escaping ((T?) -> Void), failure: @escaping ((Error?) -> Void)) {
        db.collection(collection.rawValue).document(documentId).getDocument { (data, error) in
            if data == nil || data?.data() == nil {
                success(nil)
                return
            }
            if error == nil {
                let data = data?.data()
                guard let document = getObject(type: T.self, data: data) else {
                    failure(nil)
                    return
                }
                success(document)
            }
            else { failure(error) }
        }
    }
    
    func getAllDocumentsFromCollection<T: Codable>(type: T.Type, collection: CollectionsConstants, success: @escaping (([DatabaseDocument]) -> Void), failure: @escaping ((Error) -> Void)) {
        var databaseResponses: [DatabaseDocument] = []
        db.collection(collection.rawValue).getDocuments() { (querySnapshot, error) in
            if let error = error {
                failure(error)
            } else {
                for document in querySnapshot!.documents {
                    guard let object = document.getObject(type: T.self) else { continue }
                    let databaseResponse = DatabaseDocument(id: document.documentID, object: object)
                    databaseResponses.append(databaseResponse)
                }
                success(databaseResponses)
            }
        }
    }
    
    func addDocument<T: Codable>(object: T, collection: CollectionsConstants, documentIdType: DocumentIdType, success: @escaping (() -> Void), failure: @escaping ((Error?) -> Void)) {
        var documentId = ""
        switch documentIdType {
        case .custom(let id):
            documentId = id
        case .random:
            documentId = String.randomString(length: 15)
        }
        db.collection(collection.rawValue).document(documentId).setData(object.toDictionnary!) { error in
            if error == nil { success() }
            else { failure(error) }
        }
    }
    
    func updateDocument<T: Codable>(type: T.Type, databaseDocument: DatabaseDocument, collection: CollectionsConstants, success: @escaping (() -> Void), failure: @escaping ((Error?) -> Void)) {
        guard let object = databaseDocument.object as? T else {
            failure(nil)
            return
        }
        db.collection(collection.rawValue).document(databaseDocument.id).updateData(object.toDictionnary!) { error in
            if error == nil { success() }
            else { failure(error) }
        }
    }
    
    func updateDocument(documentId: String, dictionary: [String: Any], collection: CollectionsConstants, success: @escaping (() -> Void), failure: @escaping ((Error?) -> Void)) {
        db.collection(collection.rawValue).document(documentId).updateData(dictionary) { error in
            if error == nil { success() }
            else { failure(error) }
        }
    }
    
    /// In databaseDocument, UserDetails object is expected
    func updateUserDetails(databaseDocument: DatabaseDocument, success: @escaping (() -> Void), failure: @escaping ((Error?) -> Void)) {
        guard let document = databaseDocument.object as? UserDetails else {
            failure(nil)
            return
        }
        // update user details in collection userDetails
        updateDocument(type: UserDetails.self, databaseDocument: databaseDocument, collection: .userDetails) {
            // get all projects where updating user is the owner
            self.getDataWhere(type: Project.self, collection: .projects, whereField: .ownerId, isEqualTo: databaseDocument.id) { databaseDocuments in
                let dictionary = [
                    "ownerImage": document.profileImage,
                    "ownerName": document.name
                ]
                let group = DispatchGroup()
                // update every project with owner details
                for databaseDocument in databaseDocuments {
                    group.enter()
                    guard databaseDocument.object is Project else {
                        group.leave()
                        continue
                    }
                    self.updateDocument(documentId: databaseDocument.id, dictionary: dictionary as [String : Any], collection: .projects) {
                        group.leave()
                    } failure: { _ in
                        group.leave()
                    }
                }
                group.notify(queue: .main) {
                    success()
                }
                
            } failure: { error in
                failure(error)
            }
        } failure: { error in
            failure(error)
        }
    }
    
    func deleteDocument(documentId: String, collection: CollectionsConstants, success: @escaping (() -> Void), failure: @escaping ((Error?) -> Void)) {
        db.collection(collection.rawValue).document(documentId).delete() { error in
            if error == nil { success() }
            else { failure(error) }
        }
    }
    
    func uploadImage(image: UIImage, path: DatabaseImagePathContants, imageQuality: UIImage.ImageQuality, success: @escaping ((String) -> Void), failure: @escaping ((Error?) -> Void)) {
        guard let file = image.compress(to: imageQuality).pngData() else {
            failure(nil)
            return
        }
        let name = String.randomString(length: 30)
        let postsRef = storageRef.child("\(path.rawValue)\(name).jpg")
        
        postsRef.putData(file, metadata: nil) { (metadata, error) in
            if metadata == nil { failure(error) }
 
            postsRef.downloadURL { (url, error) in
                if url == nil { failure(error) }
                else { success(url!.absoluteString) }
            }
        }
    }
    
}

extension QueryDocumentSnapshot {
    
    func getObject<T: Codable>(type: T.Type) -> T? {
        let data = self.data()
        do {
            let json = try JSONSerialization.data(withJSONObject: data)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let decoded = try decoder.decode(type, from: json)
            return decoded
        } catch {
            return nil
        }
    }
    
}

extension Encodable {
    
    var toDictionnary: [String : Any]? {
        guard let data =  try? JSONEncoder().encode(self) else {
            return nil
        }
        return try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
    }
    
}

extension String {
    
    static func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
}

func getObject<T: Codable, D>(type: T.Type, data: D) -> T? {
    do {
        let json = try JSONSerialization.data(withJSONObject: data)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let decoded = try decoder.decode(type, from: json)
        return decoded
    } catch {
        return nil
    }
}
