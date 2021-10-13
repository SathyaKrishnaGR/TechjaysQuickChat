//
//  APIClient.swift
//  Fayvit
//
//  Created by Sharran on 8/17/20.
//  Copyright © 2020 Iderize. All rights reserved.
//

import Foundation
import Alamofire
import UIKit

typealias APICompletion<T: Codable> =  (_ status: APIClient.Status, _ response: APIResponse<T>) -> Void

class APIClient {
    struct MultipartFile {
        let fileName: String
        let fileExtension: String
        let data: Data
    }

    static let shared = APIClient()
    let urlFactory = URLFactory()

    init() {}

    /// Sends a GET request to the server
    /// - Parameters:
    ///   - url: Request URL
    ///   - completion: Completion callback which will be called asyncronously when response is received
    func GET<T: Codable>(url: String,
                         headers: [String: String]? = nil,
                         completion:@escaping APICompletion<T>) {
        executeRequest(to: url, headers: headers, requestType: .get, completion: completion)
    }

    /// Sends a POST request to the server
    /// - Parameters:
    ///   - url: Request URL
    ///   - payload: Request Payload
    ///   - completion: Completion callback which will be called asyncronously when response is received
    func POST<P, T: Codable> (url: String,
                              headers: [String: String]? = nil,
                              payload: P,
                              completion:@escaping APICompletion<T>) {
        executeRequest(to: url, headers: headers, requestType: .post, payload: parsePayload(payload), completion: completion)
    }

    /// Sends a PUT request to the server
    /// - Parameters:
    ///   - url: Request URL
    ///   - payload: Request Payload
    ///   - completion: Completion callback which will be called asyncronously when response is received
    func PUT<P, T: Codable> (url: String,
                             headers: [String: String]? = nil,
                             payload: P,
                             completion: @escaping APICompletion<T>) {
        executeRequest(to: url, headers: headers, requestType: .put, payload: parsePayload(payload), completion: completion)
    }

    /// Sends a DELETE request to the server
    /// - Parameters:
    ///   - url: Request URL
    ///   - completion: Completion callback which will be called asyncronously when response is received
    func DELETE<P, T: Codable>(url: String,
                               headers: [String: String]? = nil,
                               payload: P,
                               completion: @escaping APICompletion<T>) {
        executeRequest(to: url, headers: headers, requestType: .delete, payload: parsePayload(payload), completion: completion)
    }

    /// Sends a MultipartFormData request as POST or PUT with one Image to the server
    /// - Parameters:
    ///   - url: Request URL
    ///   - method: Request type - POST, PUT, DELETE, etc./
    ///   - payload: Request payload. Note: The values should always be string for MultipartFormData request
    ///   - image: Key - Image field name, Value - Image to be sent
    ///   - completion: Completion callback which will be called asyncronously when response is received
    func MULTIPART<T: Codable> (url: String,
                                headers: [String: String]? = nil,
                                uploadType method: HTTPMethod,
                                images: [(key: String, value: UIImage)]? = nil,
                                files: [MultipartFile]? = nil,
                                completion: @escaping APICompletion<T>) {
        executeRequest(to: url,
                       headers: headers,
                       requestType: method,
                       payload: [String: Any](),
                       images: images,
                       files: files,
                       completion: completion)
    }

    /// Sends a MultipartFormData request as POST or PUT with one Image to the server
    /// - Parameters:
    ///   - url: Request URL
    ///   - method: Request type - POST, PUT, DELETE, etc./
    ///   - payload: Request payload. Note: The values should always be string for MultipartFormData request
    ///   - image: Key - Image field name, Value - Image to be sent
    ///   - completion: Completion callback which will be called asyncronously when response is received
    func MULTIPART<P, T: Codable> (url: String,
                                   headers: [String: String]? = nil,
                                   uploadType method: HTTPMethod,
                                   payload: P,
                                   images: [(key: String, value: UIImage)]? = nil,
                                   files: [MultipartFile]? = nil,
                                   completion: @escaping APICompletion<T>) {
        executeRequest(to: url,
                       headers: headers,
                       requestType: method,
                       payload: parsePayload(payload) ?? [String: Any](),
                       images: images,
                       files: files,
                       completion: completion)
    }
}


extension APIClient {
    /// Handles GET, POST, PUT, DELETE requests
    /// - Parameters:
    ///   - url: Request URL
    ///   - method: HTTP Request type - GET, POST, PUT, DELETE
    ///   - payload: Request payload. Note: The values should always be string for MultipartFormData request
    ///   - completion: Completion callback which will be called asyncronously when response is received
    private func executeRequest<T: Codable>(to url: String,
                                            headers: [String: String]? = nil,
                                            requestType method: HTTPMethod,
                                            payload: [String: Any]? = nil,
                                            completion: @escaping APICompletion<T>) {
        guard isNetworkReachable(completion) else {
            return
        }
        let headers: HTTPHeaders = buildHeaders(contentType: FayvStrings.APIClient.applicationJson, overrideHeaders: headers)
        guard let encodedUrl = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            completion(.FAILURE, APIResponse<T>(result: false, msg: "Url can't be encoded"))
            return
        }
        AF.sessionConfiguration.urlCache = nil
        AF.request(URL.init(string: encodedUrl)!,
                   method: method,
                   parameters: payload,
                   encoding: JSONEncoding.default,
                   headers: headers)
            .responseJSON { (response) in
                self.parseResponse(response: response, completion: completion)
        }
    }

    /// Handles MultipartFormData Request for PUT and POST with one Image
    /// - Parameters:
    ///   - url: Request URL
    ///   - method: HTTP Request type - PUT, POST
    ///   - image: Key - Image field name, Value - Image to be sent
    ///   - param: Request payload. Note: The values should always be string for MultipartFormData request
    ///   - completion: Completion callback which will be called asyncronously when response is received
    private func executeRequest<T: Codable>(to url: String,
                                            headers: [String: String]? = nil,
                                            requestType method: HTTPMethod,
                                            payload param: [String: Any],
                                            images: [(key: String, value: UIImage)]?,
                                            files: [MultipartFile]?,
                                            completion: @escaping APICompletion<T>) {
        guard isNetworkReachable(completion) else {
            return
        }
        let headers: HTTPHeaders = buildHeaders(contentType: "multipart/form-data", overrideHeaders: headers)
        
        let multipartFormData = { (data: MultipartFormData) in
            images?.forEach({ img in
                if let jpegImage = img.value.jpegData(compressionQuality: 1) {
                    data.append(jpegImage,
                                withName: img.key,
                                fileName: "\(img.key).jpg",
                                mimeType: "image/jpg")
                }
            })
            files?.forEach({ file in
                data.append(file.data,
                            withName: file.fileName,
                            fileName: "\(file.fileName).\(file.fileExtension)",
                            mimeType: "application/octet-stream")
            })
            for (key, value) in param {
                if let value = value as? String, let utf8Value = value.data(using: String.Encoding.utf8) {
                    data.append(utf8Value, withName: key)
                } else {
                    debugPrint(String(format: "MultiPartPayloadMustBeString", key))
                }
            }
        }
        
        debugPrint(param)
        guard let encodedUrl = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            completion(.FAILURE, APIResponse<T>(result: false, msg: "Url can't be encoded"))
            return
        }
        AF.sessionConfiguration.urlCache = nil
        AF.upload(multipartFormData: multipartFormData,
                  to: URL.init(string: encodedUrl)!,
                  method: method,
                  headers: headers)
            .responseJSON { (response) in
                self.parseResponse(response: response, completion: completion)
        }
    }
}

extension APIClient {
    /// Parses the API Response
    /// - Parameters:
    ///   - response: Alamofire response which was received from the server
    ///   - completion: Completion callback through which the Success or Failure response will be sent
    private func parseResponse<T: Codable>(
        response: AFDataResponse<Any>,
        completion :@escaping APICompletion<T>) {
        do {
            debugPrint(response)
            var apiResponse: APIResponse<T>

            if let data = response.data, let statusCode = response.response?.statusCode {
                switch statusCode {
                case 200, 201:
                    apiResponse = try JSONDecoder().decode(APIResponse<T>.self, from: data)
                    if apiResponse.result {
                        completion(.SUCCESS, apiResponse)
                    } else {
                        completion(.FAILURE, apiResponse)
                    }
                case 500, 504:
                    apiResponse = APIResponse<T>(result: false, msg: FayvStrings.APIClient.cantConnectToServer)
                    completion(.FAILURE, apiResponse)
                case 401:
                    apiResponse = APIResponse<T>(result: false, msg: FayvStrings.APIClient.unAuthorized)
                    completion(.FAILURE, apiResponse)
                default:
                    apiResponse = try JSONDecoder().decode(APIResponse<T>.self, from: response.data!)
                    completion(.FAILURE, apiResponse)
                }
            } else {
                apiResponse = APIResponse<T>(result: false, msg: FayvStrings.APIClient.noResponseFromServer)
                completion(.FAILURE, apiResponse)
            }
        } catch {
            print(error)
            completion(.FAILURE, APIResponse<T>(result: false, msg: FayvStrings.APIClient.cantConnectToServer))
        }
    }
}

extension Encodable {
  func asDictionary() -> [String: Any] {
   return (try? JSONSerialization.jsonObject(with: JSONEncoder().encode(self))) as? [String: Any] ?? [:]
  }
}

extension APIClient {
    private func parsePayload<P>(_ payload: P) -> [String: Any]? {
        if let codable = payload as? Codable {
            return codable.asDictionary()
        }
        if let dictionary = payload as? [String: Any] {
            return dictionary
        }
        return nil
    }

    private func buildHeaders(contentType: String, overrideHeaders: [String: String]? = nil) -> HTTPHeaders {
        var headers: HTTPHeaders = [
            FayvStrings.APIClient.contentType: contentType,
            FayvStrings.APIClient.device: FayvKeys.DeviceUUID,
            FayvStrings.APIClient.platform: FayvStrings.APIClient.iOS.lowercased()
        ]
        addAuthToken(&headers)
        if let additionalHeaders = overrideHeaders {
            additionalHeaders.forEach { (key, value) in
                headers[key] = value
            }
        }
        return headers
    }

    private func addAuthToken(_ headers: inout HTTPHeaders) {
//        if let token = FayvStorage.standard.user?.token {
            headers[FayvStrings.APIClient.authorization] = String(format: FayvStrings.APIClient.token, "token")
//        }
    }

    private func isNetworkReachable<T>(_ completion: @escaping APICompletion<T>)
        -> Bool {
        if NetworkReachabilityManager()?.isReachable ?? false {
            return true
        }
        let status: Status = .FAILURE
        let response = APIResponse<T>(result: false,
                                      msg: FayvStrings.APIClient.pleaseCheckYourInternetConnection)
        completion(status, response)
        return false
    }

    enum Status {
        case SUCCESS, FAILURE
    }

    enum UploadType {
        case POST, PUT
    }
}
