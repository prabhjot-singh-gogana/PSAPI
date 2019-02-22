//
//  OperationAPI.swift
//  MetricsApp
//
//  Created by Prabhjot on 06/09/18.
//  Copyright © 2018 Net Solutions. All rights reserved.
//

import UIKit
import RxSwift
import ObjectMapper

enum URLEnum {
    case filter
    case demo(baseURL: String)
    
    var value: String {
        switch self {
        case .filter:
            return ""
        case .demo(let baseURL):
            return "\(baseURL)api/operations/demo"
        }
    }
}

struct GenericResponseObject: ResponseProtocol, Mappable {
    var object: Any?
    init?(map: Map) {
        
    }
    init() {
        
    }
    static func response(json: Dictionary<String, Any>) -> GenericResponseObject? {
        var generic = GenericResponseObject()
        guard let response = json["response"] as? Dictionary<String, Any>  else {
             generic.object = json
            return generic
        }
        generic.object = response
        return generic
    }
    
    mutating func mapping(map: Map) {
        
    }
}

enum Method: Int {
    case POST = 0
    case GET = 1
}

class API<T: ResponseProtocol> {
    var request: RequestBuilder?
    var timer: Timer?
    
    func responseWithTimer(in minute: Int,  handler: @escaping ((Observable<T>) -> Void)) {
        if #available(iOS 10.0, *) {
            handler(self.response)
            if timer == nil {
                self.timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(60 * minute), repeats: true, block: { (timer) in
                    handler(self.response)
                })
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    private init(builder: RequestBuilder) {
        self.request = builder
    }
    static func request(_ urlEnum: URLEnum, param: [String: Any]? = nil, method: Method = .GET) -> API<T> {
        let url = urlEnum.value
        var builder = RequestBuilder(url: url,
                       method: ((method == Method.GET) ? .get: .post),
                       params: param); builder.shouldDisableInteraction = false
        return API<T>.init(builder: builder)
    }
    func add<M: Mappable>(param params: M) -> API<T> {
        self.request?.parameters = (self.request?.parameters == nil) ? params.toJSON() : self.request?.parameters?.merging(params.toJSON()) {$1}
        return self
    }
    func add(param params: [String: Any]) -> API<T> {
        let nonNillable = params.filter { !($0.1 is NSNull) }
        self.request?.parameters = (self.request?.parameters == nil) ? nonNillable : self.request?.parameters?.merging(nonNillable) {$1}
        return self
    }
    func add(_ params: [String: Any]) {
        let nonNillable = params.filter { !($0.1 is NSNull) }
        self.request?.parameters = (self.request?.parameters == nil) ? nonNillable : self.request?.parameters?.merging(nonNillable) {$1}
    }
    func add(header headers: [String: String]) -> API<T> {
        self.request?.headers = headers
        return self
    }
    func add(method methods: Method) -> API<T> {
        self.request?.method = (methods == Method.GET) ? .get: .post
        return self
    }

    var response: Observable<T> {
        return JSONRequest$(requestBuilder: self.request!)
            .filter{$0.result.isSuccess}
            .map({ (response) -> T in
                guard let jsonResponse = response.result.value  as? [String: AnyObject] else { throw RxError.noElements }
                guard let nsiResponse = T.response(json: jsonResponse) else { throw RxError.noElements }
                return nsiResponse
            })
    }
    var responseArray: Observable<[T]> {
        return JSONRequest$(requestBuilder: request!)
            .filter{$0.result.isSuccess}
            .map({ (response) -> [T] in
                guard let jsonResponse = response.result.value  as? [String: AnyObject] else { throw RxError.noElements }
                guard let nsiResponse = T.arrayResponse(json: jsonResponse) else { throw RxError.noElements }
                return nsiResponse
            })
    }
}
