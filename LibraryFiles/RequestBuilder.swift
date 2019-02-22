//
//  RequestBuilder.swift
//  Uplift
//
//  Created by Aditya Aggarwal on 10/12/16.
//  Copyright © 2016 Net Solutions. All rights reserved.
//

import Foundation
import Alamofire

struct RequestBuilder {

    var URLString: URLConvertible
    var method: Alamofire.HTTPMethod
    var parameters: [String: Any]?
    var encoding: ParameterEncoding
    var headers: [String: String]?
    var cache: CachePolicy
    var shouldShowLoader: Bool
    var shouldDisableInteraction: Bool

    init(urlString: URLConvertible, requestMethod: Alamofire.HTTPMethod = .get, requestParameters: [String: Any]? = nil, requestEncoding: ParameterEncoding = URLEncoding.default, requestHeaders: [String: String]? = nil, requestCache: CachePolicy = .RequestFromURLNoCache, requestShowLoader: Bool = false, requestShouldDisableInteraction: Bool = false) {
        
        URLString = urlString
        method = requestMethod
        parameters = requestParameters
        encoding = requestEncoding
        headers = requestHeaders
        cache = requestCache
        shouldShowLoader = requestShowLoader
        shouldDisableInteraction = requestShouldDisableInteraction
    }
    
    init(url: URLConvertible, method: Alamofire.HTTPMethod = .get, params: [String: Any]? = nil, headers: [String: String]? = nil) {
        
        URLString = url
        self.method = method
        parameters = params
        self.encoding = (method == .get) ? URLEncoding.default: Alamofire.JSONEncoding.default
        self.headers = headers
        self.cache = .RequestFromURLNoCache
        shouldShowLoader = true
        shouldDisableInteraction = true
    }
}
