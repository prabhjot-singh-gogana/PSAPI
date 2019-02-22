//
//  AlamofireResponseWrapper.swift
//  Uplift
//
//  Created by Aditya Aggarwal on 10/3/16.
//  Copyright © 2016 Net Solutions. All rights reserved.
//

import Foundation

class AlamofireResponseWrapper: NSObject, NSCoding {

    var request: NSURLRequest?

    /// The server's response to the URL request.
    var response: HTTPURLResponse?

    /// The data returned by the server.
    var data: NSData?

    init(request: NSURLRequest?, response: HTTPURLResponse?, data: NSData?) {
        self.request = request
        self.response = response
        self.data = data
    }

    required public init?(coder aDecoder: NSCoder) {
        request = aDecoder.decodeObject(forKey: "request") as? NSURLRequest
        response = aDecoder.decodeObject(forKey: "response") as? HTTPURLResponse
        data = aDecoder.decodeObject(forKey: "data") as? NSData
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(request, forKey: "request")
        aCoder.encode(response, forKey: "response")
        aCoder.encode(data, forKey: "data")
    }
}
