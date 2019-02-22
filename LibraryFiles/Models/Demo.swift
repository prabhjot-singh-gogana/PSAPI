//
//  OrgBreakDown.swift
//  MetricsApp
//
//  Created by Prabhjot on 24/01/19.
//  Copyright © 2019 Net Solutions. All rights reserved.
//

import Foundation
import ObjectMapper
import RxSwift

struct OrgTeamBreakDown : Mappable, ResponseProtocol {
    var name : String?
    var logged_hours : Double?
    var actual_values = [Utilize]()
    
    init?(map: Map) {
    }
    init() {
    }
    
    mutating func mapping(map: Map) {
        name <- map["name"]
        logged_hours <- map["logged_hours"]
        actual_values <- map["actual_values"]
    }
    
    static func getData(dateModel: DateModel) -> Observable<[OrgTeamBreakDown]> {
        return API<OrgTeamBreakDown>.request(.demo(baseURL: ##AnyURL##))
            .add(header: Configuration.customHeaders)
            .add(param: dateModel)
            .responseArray
    }
    
}
