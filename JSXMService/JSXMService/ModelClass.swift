//
//  ModelClass.swift
//  JSXMService
//
//  Created by New on 2025-01-15.
//

import Combine
import Foundation

final class ModelClass: BaseViewModel {
    
    func fetchJSONData() {
            NetworkService.requestJSON(endpoint: "https://jsonplaceholder.typicode.com/posts/1/comments", method: "GET") { (result: Result<JSONModel, RESTError>) in
                switch result {
                case .success(let data):
                    print("JSON Response:", data)
                case .failure(let error):
                    print("Error:", error.localizedDescription)
                }
            }
        }
        
        func fetchXMLData() {
            // API Endpoint
                    let endpoint = "https://mocktarget.apigee.net/xml"

                   
            NetworkService.requestXML(endpoint: endpoint, method: "POST") { result in
                switch result {
                case .success(let data):
                    print("XML Response:", String(data: data, encoding: .utf8) ?? "No Data")
                case .failure(let error):
                    print("Error:", error.localizedDescription)
                }
            }
        }
    
}

open class BaseViewModel: ObservableObject {
    @Published public var hasError = false
    @Published public var alert: FloatingAlert? = nil
    @Published public var hudMessage = ""
    @Published public var showHud = false
    
    public init() {
    }

    public func showPrograssHud() {
        DispatchQueue.main.async {
            self.showHud = true
        }
    }
    
    public func hidePrograssHud() {
        DispatchQueue.main.async {
            self.showHud = false
        }
    }
    
    public func changeHud(_ message: String) {
        self.hudMessage = message
    }
}


public enum FloatingAlertType {
    case success
    case error
}

public struct FloatingAlert {
    public let message: String
    public let type: FloatingAlertType
    
    public init(message: String, type: FloatingAlertType) {
        self.message = message
        self.type = type
    }
}


// MARK: - JSONModelElement
struct JSONModelElement: Codable {
    let postID, id: Int
    let name, email, body: String

    enum CodingKeys: String, CodingKey {
        case postID = "postId"
        case id, name, email, body
    }
}

typealias JSONModel = [JSONModelElement]


