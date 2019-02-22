//
//  Alamofire.swift

import Foundation
import Alamofire
import SVProgressHUD
import RxSwift

// swiftlint:disable type_name

/// Cache expiry in seconds, default to 1 day
let cacheExpiry = 86400.0

/**
 Enum for cache policy

 - RequestFromURLNoCache:                                       Fetch from URL only not from cache
 - RequestFromCacheFirstThenFromURLAndUpdateInCache:            Fetch from cache first then from url and update in cache
 - RequestFromCacheFirstThenFromURLIfDifferentAndUpdateInCache: Fetch from cache first then from url if data different in cache and update in cache
 - RequestFromCacheIfAvailableOtherwiseFromUrlAndUpdateInCache: Fetch from cache if available other from url and update in cache
 - RequestFromUrlAndUpdateInCache:                              Fetch from url only and update in cache
 - RequestFromCacheOnlyThenCallUrlInBackgroundAndUpdateInCache: Fetch from cache only and then call url in background and update in cache
 */
enum CachePolicy {
    case RequestFromURLNoCache
    case RequestFromCacheFirstThenFromURLAndUpdateInCache
    case RequestFromCacheFirstThenFromURLIfDifferentAndUpdateInCache
    case RequestFromCacheIfAvailableOtherwiseFromUrlAndUpdateInCache
    case RequestFromUrlAndUpdateInCache
    case RequestFromCacheOnlyThenCallUrlInBackgroundAndUpdateInCache
}

// MARK: Requests

/**
 JSON request

 - parameter requestBuilder:            contains url, method and various parameters required for the service call
 - parameter completionHandler:         closure called when request completed
 */
func JSONRequest(requestBuilder: RequestBuilder,
                 completionHandler: @escaping (DataResponse<Any>, Bool) -> Void) {

    request(responseSerializer: Alamofire.DataRequest.jsonResponseSerializer(), requestBuilder: requestBuilder, completionHandler: completionHandler)
}

/**
 JSON request
 
 - parameter requestBuilder:            contains url, method and various parameters required for the service call
 - parameter Observable:         closure called when request completed
 */
func JSONRequest$(requestBuilder: RequestBuilder) -> Observable<DataResponse<Any>> {
    
    return request(responseSerializer: Alamofire.DataRequest.jsonResponseSerializer(), requestBuilder: requestBuilder)
}
 

/**
 Data request

 - parameter requestBuilder:            contains url, method and various parameters required for the service call
 - parameter completionHandler:         closure called when request completed
 */
func DataRequest(requestBuilder: RequestBuilder,
                 completionHandler: @escaping (DataResponse<Data>, Bool) -> Void) {

    request(responseSerializer: Alamofire.DataRequest.dataResponseSerializer(), requestBuilder: requestBuilder, completionHandler: completionHandler)
}

/**
 String request

 - parameter requestBuilder:            contains url, method and various parameters required for the service call
 - parameter completionHandler:         closure called when request completed
 */
func StringRequest(requestBuilder: RequestBuilder,
                   completionHandler: @escaping (DataResponse<String>, Bool) -> Void) {

    request(responseSerializer: Alamofire.DataRequest.stringResponseSerializer(), requestBuilder: requestBuilder, completionHandler: completionHandler)
}

/**
 Property list request

 - parameter requestBuilder:            contains url, method and various parameters required for the service call
 - parameter completionHandler:         closure called when request completed
 */
func PropertyListRequest(requestBuilder: RequestBuilder,
                         completionHandler: @escaping (DataResponse<Any>, Bool) -> Void) {

    request(responseSerializer: Alamofire.DataRequest.propertyListResponseSerializer(), requestBuilder: requestBuilder, completionHandler: completionHandler)
}

// MARK: Generic request

/**
 Generic request called by other request methods
 
 - parameter responseSerializer:        type of serializer: json, data etc
 - parameter requestBuilder:            contains url, method and various parameters required for the service call
 - parameter completionHandler:         closure called when request completed
 */
private func request<T: DataResponseSerializerProtocol>(responseSerializer: T, requestBuilder: RequestBuilder) -> Observable<DataResponse<T.SerializedObject>> {
    
    return Observable<DataResponse<T.SerializedObject>>.create { (observer) -> Disposable in
        
        manageUIInteractionAndLoader(isServiceStart: true, requestBuilder: requestBuilder)
        Alamofire.request(requestBuilder.URLString, method: requestBuilder.method, parameters: requestBuilder.parameters, encoding: requestBuilder.encoding, headers: requestBuilder.headers)
            .validate()
            .response(responseSerializer: responseSerializer, completionHandler: { (response) in
                manageUIInteractionAndLoader(isServiceStart: false, requestBuilder: requestBuilder)
                if response.data == nil {
                    observer.onError(RxError.noElements)
                }
                observer.onNext(response)
                observer.onCompleted()
            })
        
        return Disposables.create()
    }
    
}

/**
 Generic request called by other request methods

 - parameter responseSerializer:        type of serializer: json, data etc
 - parameter requestBuilder:            contains url, method and various parameters required for the service call
 - parameter completionHandler:         closure called when request completed
 */
private func request<T: DataResponseSerializerProtocol>(responseSerializer: T, requestBuilder: RequestBuilder, completionHandler: @escaping (DataResponse<T.SerializedObject>, Bool) -> Void) {

    

        manageUIInteractionAndLoader(isServiceStart: true, requestBuilder: requestBuilder)
        
        Alamofire.request(requestBuilder.URLString, method: requestBuilder.method, parameters: requestBuilder.parameters, encoding: requestBuilder.encoding, headers: requestBuilder.headers)
            .validate()
            .response(responseSerializer: responseSerializer, completionHandler: { (response) in
                if response.data != nil {
                    return                                   // Don't call completion closure if cachedData & url responseData is same
                }
                completionHandler(response, false)
            })
    
}

// MARK: Helper methods

/**
 Get timeline object based on start time

 - parameter startTime: start time

 - returns: timeline object
 */
private func getTimeline(startTime: CFAbsoluteTime) -> Timeline {

    let requestCompletedTime = CFAbsoluteTimeGetCurrent()

    return Timeline(requestStartTime: startTime, initialResponseTime: requestCompletedTime, requestCompletedTime: requestCompletedTime, serializationCompletedTime: CFAbsoluteTimeGetCurrent())
}

// MARK: UIInteraction & Loaders

/**
 Manages user interaction and loading indicator based on parameters

 - parameter isServiceStart:          bool to state whether service will start or is ended
 - parameter requestBuilder:          contains url, method and various parameters required for the service call
 - parameter isDataReturnedFromCache: bool to represent whether the data is returned from cache or not
 */
private func manageUIInteractionAndLoader(isServiceStart: Bool, requestBuilder: RequestBuilder) {
    UIApplication.shared.isNetworkActivityIndicatorVisible = isServiceStart
    if isServiceStart {
        showLoader(requestBuilder: requestBuilder)
        userInteractionEnabled(requestBuilder: requestBuilder, interactionEnable: false)
    } else {
        hideLoader(requestBuilder: requestBuilder)
        userInteractionEnabled(requestBuilder: requestBuilder, interactionEnable: true)
    }
}



/**
 Show loading indicator according to requestBuilder variable

 - parameter requestBuilder: contains url, method and various parameters required for the service call
 */
private func showLoader(requestBuilder: RequestBuilder) {
    if requestBuilder.shouldShowLoader {
        // show loader
        SVProgressHUD.setDefaultStyle(.custom)
        SVProgressHUD.setBackgroundColor(UIColor(red: 0, green: 0, blue: 0, alpha: 0.5))
        SVProgressHUD.setForegroundColor(UIColor.white)
        SVProgressHUD.show()
    }
}

/**
 Hide loading indicator

 - parameter requestBuilder: contains url, method and various parameters required for the service call
 */
private func hideLoader(requestBuilder: RequestBuilder) {
    if requestBuilder.shouldShowLoader {
        SVProgressHUD.dismiss()
    }
}

/**
 Enable or disable user interaction

 - parameter requestBuilder:    contains url, method and various parameters required for the service call
 - parameter interactionEnable: bool to represent whether to enable/disable user interaction
 */
private func userInteractionEnabled(requestBuilder: RequestBuilder, interactionEnable: Bool) {
    if requestBuilder.shouldDisableInteraction {
        UIApplication.shared.delegate?.window??.isUserInteractionEnabled = interactionEnable
    }
}
