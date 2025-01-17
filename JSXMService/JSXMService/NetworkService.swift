//
//  Untitled.swift
//  JSXMService
//
//  Created by New on 2025-01-15.
//

import Foundation

public class NetworkService {
    private init() {}

    // MARK: - JSON Request
    @discardableResult
    public static func requestJSON<T: Decodable>(
        endpoint: String,
        method: String = "GET",
        parameters: [String: Any]? = nil,
        headers: [String: String]? = nil,
        completion: @escaping (Result<T, RESTError>) -> Void
    ) -> URLSessionDataTask {
        guard let url = URL(string: endpoint) else {
            print("Error: Invalid URL")
            completion(.failure(.badRequest))
            return URLSessionDataTask()
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        if let headers = headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }

        if let parameters = parameters {
            request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Request Error:", error.localizedDescription)
                completion(.failure(.custom(error.localizedDescription)))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("Error: Invalid HTTP Response")
                completion(.failure(.somethingWentWrong))
                return
            }

            if !(200...299).contains(httpResponse.statusCode) {
                let errorBody = String(data: data ?? Data(), encoding: .utf8) ?? "No response body"
                print("HTTP Error \(httpResponse.statusCode): \(errorBody)")
                completion(.failure(.custom("HTTP \(httpResponse.statusCode)")))
                return
            }

            guard let data = data else {
                print("Error: No Data Received")
                completion(.failure(.somethingWentWrong))
                return
            }

            do {
                let decodedData = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedData))
            } catch DecodingError.keyNotFound(let key, let context) {
                print("Key '\(key.stringValue)' not found:", context.debugDescription)
            } catch DecodingError.typeMismatch(let type, let context) {
                print("Type mismatch for type \(type):", context.debugDescription)
            } catch DecodingError.valueNotFound(let type, let context) {
                print("Value not found for type \(type):", context.debugDescription)
            } catch DecodingError.dataCorrupted(let context) {
                print("Data corrupted:", context.debugDescription)
            } catch {
                print("General decoding error:", error.localizedDescription)
            }
        }

        task.resume()
        return task
    }


    // MARK: - XML Request
    @discardableResult
    public static func requestXML(
        endpoint: String,
        method: String = "GET",
        parameters: [String: Any]? = nil,
        headers: [String: String]? = nil,
        completion: @escaping (Result<Data, RESTError>) -> Void
    ) -> URLSessionDataTask {
        guard let url = URL(string: endpoint) else {
            completion(.failure(.badRequest))
            return URLSessionDataTask()
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        if let headers = headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }

        if let parameters = parameters {
            let parameterString = parameters.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
            request.httpBody = parameterString.data(using: .utf8)
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.custom(error.localizedDescription)))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.somethingWentWrong))
                return
            }

            if !(200...299).contains(httpResponse.statusCode) {
                completion(.failure(.custom("HTTP \(httpResponse.statusCode)")))
                return
            }

            guard let data = data else {
                completion(.failure(.somethingWentWrong))
                return
            }

            completion(.success(data))
        }

        task.resume()
        return task
    }
}
public enum RESTError: Error {
    case badRequest
    case unauthorized
    case somethingWentWrong
    case parsingFailed
    case custom(String)

    var localizedDescription: String {
        switch self {
        case .badRequest:
            return "Bad Request"
        case .unauthorized:
            return "Unauthorized Access"
        case .somethingWentWrong:
            return "Something went wrong"
        case .parsingFailed:
            return "Parsing failed"
        case .custom(let message):
            return message
        }
    }
}
protocol XMLDecodable {
    static func decode(from data: Data) throws -> Self
}

