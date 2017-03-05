//
//  Service.swift
//  dbnetworktest
//
//  Created by Patryk Mikolajczyk on 05/03/2017.
//  Copyright © 2017 Patryk Mikolajczyk. All rights reserved.
//

import Foundation
import Alamofire
import JASON
import PromiseKit

enum Result<T> {
    case success(T)
    case failure(error: String)
}


protocol ServiceType: class {
    func call(completion: @escaping (Result<String>)->())
    func call2(completion: @escaping (Result<String>)->())
}
/* for simplification i will skip passing links and almost everything. its just only proof of conept*/

// METHOD1 : Current solution



extension DataRequest {
    enum LiveplayError: Error {
        case networkError(error: Error?)
        case failure(error: Error?)
    }
    
    static func jsonResponseSerializer() -> DataResponseSerializer<JSON> {
        return DataResponseSerializer { request, response, data, error in
            guard error == nil else {
                return .failure(LiveplayError.networkError(error: error))
            }
            
            guard let statusCode = response?.statusCode, (200..<300).contains(statusCode) else {
                return .failure(LiveplayError.failure(error: error))
            }
            
            let result = Request.serializeResponseData(response: response,
                                                       data: data, error: nil)
            
            guard case .success = result else {
                return .failure(LiveplayError.failure(error: result.error))
            }
            
            return .success(JSON(result.value))
        }
    }
    
    @discardableResult
    func liveplayResponseJSON(queue: DispatchQueue? = nil, completionHandler: @escaping (DataResponse<JSON>) -> Void) -> Self {
        return validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .response(queue: queue, responseSerializer: DataRequest.jsonResponseSerializer(),
                      completionHandler: completionHandler)
    }
}


class Service1: ServiceType {
    func call(completion: @escaping (Result<String>)->()) {
        let params = ["userId": "ble a nie id"]
        let url = "https://google.pl" + "/videos"
        
        Alamofire.request(url, method: .get, parameters: params)
            .liveplayResponseJSON { (response) in
                switch response.result {
                case .success(_):
                    // PARSING DATA here
                    /*
                     guard let array = json.jsonArray else { return }
                     let videos = array.flatMap { Video(json: $0, currentUserId: userId) }.sorted { $0.0.postDate > $0.1.postDate }
                     */
                    completion(.success("edward"))
                case .failure(let error):
                    completion(.failure(error: "some error code or whatsoever \(error)"))
                }
        }
    }
    
    func call2(completion: @escaping (Result<String>)->()) {
        let params = ["userId": "ble a nie id"]
        let url = "https://google.pl" + "/photos"
        
        Alamofire.request(url, method: .get, parameters: params)
            .liveplayResponseJSON { (response) in
                switch response.result {
                case .success(_):
                    // PARSING DATA here
                    /*
                     guard let array = json.jsonArray else { return }
                     let videos = array.flatMap { Video(json: $0, currentUserId: userId) }.sorted { $0.0.postDate > $0.1.postDate }
                     */
                    completion(.success("edward"))
                case .failure(let error):
                    completion(.failure(error: "some error code or whatsoever \(error)"))
                }
        }
    }
}


// METHOD 2: Alamofire router


// sample from alamofire github page
enum Router: URLRequestConvertible {
    case createUser(parameters: Parameters)
    case readUser(username: String)
    case updateUser(username: String, parameters: Parameters)
    case destroyUser(username: String)
    
    static let baseURLString = "https://example.com"
    
    var method: HTTPMethod {
        switch self {
        case .createUser:
            return .post
        case .readUser:
            return .get
        case .updateUser:
            return .put
        case .destroyUser:
            return .delete
        }
    }
    
    var path: String {
        switch self {
        case .createUser:
            return "/users"
        case .readUser(let username):
            return "/users/\(username)"
        case .updateUser(let username, _):
            return "/users/\(username)"
        case .destroyUser(let username):
            return "/users/\(username)"
        }
    }
    
    // MARK: URLRequestConvertible
    
    func asURLRequest() throws -> URLRequest {
        let url = try Router.baseURLString.asURL()
        
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue
        
        switch self {
        case .createUser(let parameters):
            urlRequest = try URLEncoding.default.encode(urlRequest, with: parameters)
        case .updateUser(_, let parameters):
            urlRequest = try URLEncoding.default.encode(urlRequest, with: parameters)
        default:
            break
        }
        
        return urlRequest
    }
}


class Service2: ServiceType {
    internal func call2(completion: @escaping (Result<String>) -> ()) {
        Alamofire.request(Router.readUser(username: "username"))
            .liveplayResponseJSON { (response) in
                switch response.result {
                case .success(_):
                    // PARSING DATA here
                    /*
                     guard let array = json.jsonArray else { return }
                     let videos = array.flatMap { Video(json: $0, currentUserId: userId) }.sorted { $0.0.postDate > $0.1.postDate }
                     */
                    completion(.success("edward"))
                case .failure(let error):
                    completion(.failure(error: "some error code or whatsoever \(error)"))
                }
        }
    }
    
    internal func call(completion: @escaping (Result<String>) -> ()) {
        Alamofire.request(Router.destroyUser(username: "username"))
            .liveplayResponseJSON { (response) in
                switch response.result {
                case .success(_):
                    // PARSING DATA here
                    /*
                     guard let array = json.jsonArray else { return }
                     let videos = array.flatMap { Video(json: $0, currentUserId: userId) }.sorted { $0.0.postDate > $0.1.postDate }
                     */
                    completion(.success("edward"))
                case .failure(let error):
                    completion(.failure(error: "some error code or whatsoever \(error)"))
                }
        }
    }
}



// METHOD 3

//Basically method takes request ( in alamofire it can take urlrequestconvertible or datarequest and <T> -> response model
// reminder its only proof of concept so example will not work so
// Ofc instead of using http method from alamo, parameters, http headers etc we can use our own types ( its safer) but i skipped it for migration. the only change would occour in getdatarequest function inside service request protocol
protocol Service3Type: class {
    
}

protocol ServiceResponse {
    init?(json: JSON)
}

protocol ServiceRequest {
    var url: String { get set }
    var method: HTTPMethod { get set }
    var parameters: Parameters { get set }
    var encoding: ParameterEncoding? { get set }
    var headers: HTTPHeaders? { get set }
}

extension ServiceRequest {
    func getDataRequest() -> DataRequest {
        return Alamofire.request(url, method: method, parameters: parameters, encoding: encoding ?? URLEncoding.default, headers: headers)
    }
}

struct ServiceMethod3 {
    static func get<T: ServiceResponse>(request: ServiceRequest, completion: @escaping (Result<T>)->()) {
        request.getDataRequest().liveplayResponseJSON { (response) in
            switch response.result {
            case .success(let json):
                guard let response = T(json: json) else {
                    completion(.failure(error: "error message"))
                    return
                }
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error: "some error code or whatsoever \(error)"))
            }
            
        }
    }
}

protocol ServiceType3: class {
    func call1(request: Request, completion: @escaping (Result<HueHueHue>)->())
    
    // OR
    
    func call2(param: String, completion: @escaping (Result<HueHueHue>)->())
    // i prefer the second one
}


// you should store it in some meaningful struct like managerfactorystructswifty

struct HueHueHue: ServiceResponse {
    let ble: String
    init?(json: JSON) {
        // parsing response. if not correct response nil -> we can also make it throwing function, but i prefere nil (its cleaner)
        ble = "edward"
    }
}
struct Request2: ServiceRequest {
    var url: String = "blebleble"
    var method: HTTPMethod = .post
    var parameters: Parameters
    var encoding: ParameterEncoding?
    var headers: HTTPHeaders?
    
    init(param1: String) {
        parameters = ["key": param1]
    }
}
class Service3 {
    
    func call1(request: Request, completion: @escaping (Result<HueHueHue>)->()) {
        ServiceMethod3.get(request: request, completion: completion)
    }
    struct Request: ServiceRequest {
        var url: String
        var method: HTTPMethod
        var parameters: Parameters
        var encoding: ParameterEncoding?
        var headers: HTTPHeaders?
    }
    
    
    func call2(param: String, completion: @escaping (Result<HueHueHue>)->()) {
        let req = Request2(param1: "ble")
        ServiceMethod3.get(request: req, completion: completion)
        
        
    }
    
}

// METHOD 4

// we can also wrap previous solution in different way using promise. i know its not implemented yet in swift... idk why
// and ofc you can pass some parameters to service4 if you want ( links or other stuff)
protocol Servicable {
    associatedtype Output: ServiceResponse
    var request: ServiceRequest { get }
    func execute() -> Promise<Output>
}

protocol Operation: Servicable { }

extension Operation {
    func execute() -> Promise<Output> {
        return Promise{ fulfill, reject in
            ServiceMethod3.get(request: request, completion: { (result: Result<Output>) in
                switch result {
                case .success(let obj): fulfill(obj)
                    // i dont want to change stuff everywhere so just forcecasted to error to dodge the error
                case .failure(let error): reject(error as! Error)
                }
            })
        }
    }
}

class Service4: Operation {
    typealias Output = HueHueHue
    var request: ServiceRequest {
        return Request2(param1: "ble")
    }
}

func ble() {
    Service4().execute()
        .then { (obj) in
        print(obj.ble)
    }.catch { error in
        print(error)
    }
}



