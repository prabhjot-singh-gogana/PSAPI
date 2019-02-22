//
//  NSIResponse.swift
//  Uplift
//
//  Created by Aditya Aggarwal on 10/7/16.
//  Copyright © 2016 Net Solutions. All rights reserved.
//


// swiftlint:disable file_length
// swiftlint:disable line_length
// swiftlint:disable cyclomatic_complexity

import Foundation
import ObjectMapper


public protocol ResponseProtocol {
    static func response(json: Dictionary<String, Any>) -> Self?
    static func arrayResponse(json: Dictionary<String, Any>) -> [Self]?
}

public extension ResponseProtocol where Self: Mappable {
    static func arrayResponse(json: Dictionary<String, Any>) -> [Self]? {
        guard let response = json["response"] as? Dictionary<String, Any>  else {
            guard let reponseArray = json["response"] as? [[String: Any]] else {
                return Mapper<Self>().mapArray(JSONObject: json)
            }
            return Mapper<Self>().mapArray(JSONArray: reponseArray)
        }
        return Mapper<Self>().mapArray(JSONObject: response)
    }
    static func response(json: Dictionary<String, Any>) -> Self? {
        guard let response = json["response"] as? Dictionary<String, Any>  else {
            return Mapper<Self>().map(JSON: json)
        }
        return Mapper<Self>().map(JSON: response)
    }
}

struct NSIResponse<T>: Mappable {

	var status: Int
	var message: String
	var response: Any?
    var responseGen: T?

    init?(map: Map) {
		status = -1
		message = "default message"
	}


	mutating func mapping(map: Map) {

		status <- map["status"]
		message <- map["message"]

		switch T.self {
    // Fro Swift users
        case is [Project].Type: response = Mapper<Project>().mapArray(JSONObject: map["response"].currentValue)

        case is TeamProductivity.Type: response = Mapper<TeamProductivity>().map(JSONObject: map["response"].currentValue)
            
        default: response <- map["response"]
		}
	}
}
