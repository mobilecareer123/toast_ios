//
//  WebService.swift
//  Demo_SignUp
//
//  Created by Arkenea on 28/09/16.
//  Copyright © 2016 Ashwini@Arkenea. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage


let HOST_URL = kHOST_URL

let SelfSignCert = kSelfSignCert

let boundrary = "ARCFormBoundary8tnwwe6d17l23xr"

class WebService: NSObject {
    
    
    static var isFinish:Bool = true
    
    static func sendPostRequest(postDict: NSDictionary, serviceCount:NSInteger, withCompletion completion: @escaping ((_ response:AnyObject, _ error: AnyObject
        ) -> Void)) {
        
        isFinish = false
        
        NSLog("request = %@", postDict)
        let urlStr = HOST_URL.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        
        Manager.request(urlStr, method: .post, parameters: postDict as? Parameters, encoding: JSONEncoding.default).responseJSON { response in
            
            switch response.result {
            case .success:
                
                isFinish = true
                //  print("\(response.result.value!)")
                if((response.result.value) != nil) { //Check for response
                   // print(response.result.value!)
                    //to logout on device if logged on to other device
                    if ((response.result.value! as! NSDictionary)["status"]! as! String == "Error")
                    {
                        if ((response.result.value!
                            as! NSDictionary)["ErrorCode"]! as! NSNumber == 401) // user not available (in case of double login)
                        {
                            SVProgressHUD.dismiss()
                            let error_message:NSString =  NSString(format: "%@",(response.result.value as! NSDictionary)["Error"]! as! NSString)
                            SVProgressHUD.showInfo(withStatus: error_message as String!, maskType: .gradient)
                            
                            _ = Timer.scheduledTimer(timeInterval: 0.0, target: self, selector: #selector(WebService.callSeg), userInfo: nil, repeats: false)
                        }
                        else
                        {
                            NSLog(".success: >>>> status == Error")
                            completion(response.result.value! as AnyObject, "" as AnyObject)
                        }
                    }
                    else
                    {
                        //  print(response.result.value!)
                        
                        
                         NSLog(".success: >>>> status == response check")
                        print(response )

                        if case (response.result.value! as! NSDictionary) = (response.result.value! as! NSDictionary) {
                            
                            NSLog(".success: >>>> status == Result")
                            completion(response.result.value as AnyObject, "" as AnyObject)
                        }
                        else
                        {
                            NSLog(".success: >>>> status == Resulted in optional unwrapping error")
                        }
                        
                       
                    }
                    
                    SVProgressHUD.dismiss()
                }
            case .failure(let encodingError):
                isFinish = true
                //print encodingError.description
                if let error = encodingError as? AFError {
                    switch error {
                    case .invalidURL(let url):
                        print("Invalid URL: \(url) - \(error.localizedDescription)")
                    case .parameterEncodingFailed(let reason):
                        print("Parameter encoding failed: \(error.localizedDescription)")
                        print("Failure Reason: \(reason)")
                    case .multipartEncodingFailed(let reason):
                        print("Multipart encoding failed: \(error.localizedDescription)")
                        print("Failure Reason: \(reason)")
                    case .responseValidationFailed(let reason):
                        print("Response validation failed: \(error.localizedDescription)")
                        print("Failure Reason: \(reason)")
                        
                        switch reason {
                        case .dataFileNil, .dataFileReadFailed:
                            print("Downloaded file could not be read")
                        case .missingContentType(let acceptableContentTypes):
                            print("Content Type Missing: \(acceptableContentTypes)")
                        case .unacceptableContentType(let acceptableContentTypes, let responseContentType):
                            print("Response content type: \(responseContentType) was unacceptable: \(acceptableContentTypes)")
                        case .unacceptableStatusCode(let code):
                            print("Response status code was unacceptable: \(code)")
                        }
                    case .responseSerializationFailed(let reason):
                        print("Response serialization failed: \(error.localizedDescription)")
                        print("Failure Reason: \(reason)")
                    }
                    
                    print("Underlying error: \(String(describing: error.underlyingError))")
                    //completion(response.result as AnyObject, error as AnyObject)
                    SVProgressHUD.showInfo(withStatus: response.result.error?.localizedDescription)
                    
                } else if let error = encodingError as? URLError {
                    //handling of network connection lost error
                        print("Error message: \(String(describing: error.localizedDescription))")
                        if(error.localizedDescription == "The network connection was lost."){
                            if(3 > serviceCount){
                                var reqCount:NSInteger = 2
                                if(serviceCount == 0){
                                    reqCount = 1
                                }else if(serviceCount == 1){
                                    reqCount = 2
                                }
                                sendPostRequest(postDict: postDict, serviceCount: reqCount, withCompletion: completion)
                            }else{
                                SVProgressHUD.dismiss()
                                SVProgressHUD.showInfo(withStatus: response.result.error?.localizedDescription)

                               // completion(nil, error, nil)
                            }
                        }else{
                            SVProgressHUD.dismiss()
                            SVProgressHUD.showInfo(withStatus: response.result.error?.localizedDescription)
                            //completion(nil, error, nil)
                        }
                    print("URLError occurred 22: \(error)")
                    
                    print("URLError occurred error.failingURL 1: \(String(describing: error.failingURL))")
                    print("URLError occurred error.failureURLPeerTrust 2: \(String(describing: error.failureURLPeerTrust))")
                    print("URLError occurred error.failureURLString 3: \(String(describing: error.failureURLString))")
                    print("URLError occurred error.code 4: \(error.code)")
                    print("URLError occurred error.errorCode 5: \(error.errorCode)")
                    print("URLError occurred error.errorUserInfo 6: \(error.errorUserInfo)")
                    print("URLError occurred error.hashValue 7: \(error.hashValue)")
                    print("URLError occurred error.localizedDescription 8: \(error.localizedDescription)")
                    print("URLError occurred error.userInfo 9: \(error.userInfo)")

                    // completion(result as AnyObject, error as AnyObject)
                    
                } else {
                    print("Unknown error: \(encodingError)")
                    // completion(result as AnyObject, encodingError as AnyObject)
                    
                }
                
                break
            }
            
            
            
        }
        
    }
    
    static func callSeg() {
        let defaults = UserDefaults.standard
        
        let device_Token = UserDefaults.standard.value(forKey: KEY_DEVICE_TOKEN)
        
        
        let appDomain:NSString = Bundle.main.bundleIdentifier! as NSString
        defaults.removePersistentDomain(forName: appDomain as String)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        UserDefaults.standard.setValue(device_Token, forKey: KEY_DEVICE_TOKEN)
        
        appDelegate.startApp()
        
        
    }
    
    static func getpart(filenameKey:String, value:NSData) -> NSData?{
        let string = String(format: "--%@\r\nContent-Disposition: form-data; name=\"%@\"\r\n\r\n%@\r\n", arguments: [boundrary,filenameKey,value])
        return (string.data(using: String.Encoding.utf8, allowLossyConversion: false) as NSData??)!
    }
    static func getPart(fieldName:String, value:String)->NSData?{
        let string = String(format: "--%@\r\nContent-Disposition: form-data; name=\"%@\"\r\n\r\n%@\r\n", arguments: [boundrary,fieldName,value])
        return (string.data(using: String.Encoding.utf8, allowLossyConversion: false) as NSData??)! 
    }
    
    
    static func multipartRequest(postDict: NSDictionary, ProfileImage: String ,withCompletion completion: @escaping ((_ response:AnyObject, _ error: AnyObject
        ) -> Void)) {
        
//        NSLog("request = %@", postDict)
        do
        {
        let data1 = try JSONSerialization.data(withJSONObject: postDict, options: [])
            let datastring1 : NSString? = NSString(data: data1, encoding: String.Encoding.utf8.rawValue)
            let str11 : String = datastring1! as String
            NSLog("json request = %@", str11)
        }
        catch{}

        
        let urlStr = HOST_URL.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        
        isFinish = false
        
        Manager.upload(multipartFormData: { (multipartFormData) in
           
            for optKey in postDict.allKeys {
                let key: String = optKey as! String
                let value: AnyObject = postDict.object(forKey: key)! as AnyObject
                if value is String {
                    multipartFormData.append((postDict.value(forKey: key)! as! String).data(using: String.Encoding.utf8)!, withName: key)
                } else {
                    do
                    {
//                    let data = try JSONSerialization.data(withJSONObject: value, options: .prettyPrinted)
//                        multipartFormData.append(data, withName: key)
//                        let dataString = String(data: data, encoding: .utf8)! as String
//                    multipartFormData.append(dataString.data(using: String.Encoding.utf8)!, withName: key)
                        
                        
                        let str = getDataUsinfEncoding(dict: postDict, key: key )
                        guard let _:NSData = getPart(fieldName: key , value: str) else{
                            return
                        }
                        
                        multipartFormData.append(str.data(using: String.Encoding.utf8)!, withName: key )
                        
                    }
                    catch{
                    }
                    
                }
                
            }
            
            if postDict.allKeys.count > 0 {
                
                if ProfileImage.characters.count > 0 // to ommit call when no image
                {
                multipartFormData.append(URL(fileURLWithPath: ProfileImage) , withName: "image", fileName: "userimage.png", mimeType: "image/png")
                }
            }
            
            }, to: urlStr)
        { (result) in
            
            switch result {
            case .success(let upload, _, _):
                isFinish = true
                upload.uploadProgress(closure: { (progress) in
                    print(progress)
                })
                
                upload.responseJSON { response in
                    if((response.result.value) != nil) { //Check for response
                       // print(response.result.value!)
                        completion(response.result.value! as AnyObject, "" as AnyObject)
                    }

                }
            case .failure(let encodingError):
                isFinish = true
                //print encodingError.description
                if let error = encodingError as? AFError {
                    switch error {
                    case .invalidURL(let url):
                        print("Invalid URL: \(url) - \(error.localizedDescription)")
                    case .parameterEncodingFailed(let reason):
                        print("Parameter encoding failed: \(error.localizedDescription)")
                        print("Failure Reason: \(reason)")
                    case .multipartEncodingFailed(let reason):
                        print("Multipart encoding failed: \(error.localizedDescription)")
                        print("Failure Reason: \(reason)")
                    case .responseValidationFailed(let reason):
                        print("Response validation failed: \(error.localizedDescription)")
                        print("Failure Reason: \(reason)")
                        
                        switch reason {
                        case .dataFileNil, .dataFileReadFailed:
                            print("Downloaded file could not be read")
                        case .missingContentType(let acceptableContentTypes):
                            print("Content Type Missing: \(acceptableContentTypes)")
                        case .unacceptableContentType(let acceptableContentTypes, let responseContentType):
                            print("Response content type: \(responseContentType) was unacceptable: \(acceptableContentTypes)")
                        case .unacceptableStatusCode(let code):
                            print("Response status code was unacceptable: \(code)")
                        }
                    case .responseSerializationFailed(let reason):
                        print("Response serialization failed: \(error.localizedDescription)")
                        print("Failure Reason: \(reason)")
                    }
                    
                    print("Underlying error: \(String(describing: error.underlyingError))")
                    completion(result as AnyObject, error as AnyObject)
                   // SVProgressHUD.showInfo(withStatus: error.localizedDescription)
                    
                } else if let error = encodingError as? URLError {
                    print("URLError occurred 11 : \(error)")
                    
                    print("URLError occurred error.failingURL 1: \(String(describing: error.failingURL))")
                    print("URLError occurred error.failureURLPeerTrust 2: \(String(describing: error.failureURLPeerTrust))")
                    print("URLError occurred error.failureURLString 3: \(String(describing: error.failureURLString))")
                    print("URLError occurred error.code 4: \(error.code)")
                    print("URLError occurred error.errorCode 5: \(error.errorCode)")
                    print("URLError occurred error.errorUserInfo 6: \(error.errorUserInfo)")
                    print("URLError occurred error.hashValue 7: \(error.hashValue)")
                    print("URLError occurred error.localizedDescription 8: \(error.localizedDescription)")
                    print("URLError occurred error.userInfo 9: \(error.userInfo)")


                    
                    completion(result as AnyObject, error as AnyObject)
                    
                } else {
                    print("Unknown error: \(encodingError)")
                    completion(result as AnyObject, encodingError as AnyObject)
                    
                }
                SVProgressHUD.dismiss()
                //SVProgressHUD.showInfo(withStatus: result.)
                break
            }
        }
        
    }
    
    static func downloadImage(urlStr: String, size: CGSize, withCompletion completion: @escaping ((_ response:AnyObject, _ error: AnyObject
        ) -> Void)) {
        
        Manager.request(urlStr).responseImage { response in
            debugPrint(response)
            
            switch response.result {
            case .success:
                
                print(response.request as Any)
                print(response.response as Any)
                debugPrint(response.result)
                
                if let image = response.result.value {
                    
                    //                    // Scale image to size disregarding aspect ratio
                    //                    let scaledImage = image.af_imageScaled(to: size)
                    //
                    //                    // Scale image to fit within specified size while maintaining aspect ratio
                    //                    let aspectScaledToFitImage = image.af_imageAspectScaled(toFit: size)
                    
                    // Scale image to fill specified size while maintaining aspect ratio
                    let aspectScaledToFillImage = image.af_imageAspectScaled(toFill: size)
                    
                    completion(aspectScaledToFillImage as UIImage, "" as AnyObject)
                }
                
                
            case .failure(let encodingError):
                //print encodingError.description
                if let error = encodingError as? AFError {
                    switch error {
                    case .invalidURL(let url):
                        print("Invalid URL: \(url) - \(error.localizedDescription)")
                    case .parameterEncodingFailed(let reason):
                        print("Parameter encoding failed: \(error.localizedDescription)")
                        print("Failure Reason: \(reason)")
                    case .multipartEncodingFailed(let reason):
                        print("Multipart encoding failed: \(error.localizedDescription)")
                        print("Failure Reason: \(reason)")
                    case .responseValidationFailed(let reason):
                        print("Response validation failed: \(error.localizedDescription)")
                        print("Failure Reason: \(reason)")
                        
                        switch reason {
                        case .dataFileNil, .dataFileReadFailed:
                            print("Downloaded file could not be read")
                        case .missingContentType(let acceptableContentTypes):
                            print("Content Type Missing: \(acceptableContentTypes)")
                        case .unacceptableContentType(let acceptableContentTypes, let responseContentType):
                            print("Response content type: \(responseContentType) was unacceptable: \(acceptableContentTypes)")
                        case .unacceptableStatusCode(let code):
                            print("Response status code was unacceptable: \(code)")
                        }
                    case .responseSerializationFailed(let reason):
                        print("Response serialization failed: \(error.localizedDescription)")
                        print("Failure Reason: \(reason)")
                    }
                    
                    print("Underlying error: \(String(describing: error.underlyingError))")
                    //completion(response.result as AnyObject, error as AnyObject)
                    
                } else if let error = encodingError as? URLError {
                    print("URLError occurred 33: \(error)")
                    
                    print("URLError occurred error.failingURL 1: \(String(describing: error.failingURL))")
                    print("URLError occurred error.failureURLPeerTrust 2: \(String(describing: error.failureURLPeerTrust))")
                    print("URLError occurred error.failureURLString 3: \(String(describing: error.failureURLString))")
                    print("URLError occurred error.code 4: \(error.code)")
                    print("URLError occurred error.errorCode 5: \(error.errorCode)")
                    print("URLError occurred error.errorUserInfo 6: \(error.errorUserInfo)")
                    print("URLError occurred error.hashValue 7: \(error.hashValue)")
                    print("URLError occurred error.localizedDescription 8: \(error.localizedDescription)")
                    print("URLError occurred error.userInfo 9: \(error.userInfo)")
                    
                    // completion(result as AnyObject, error as AnyObject)
                    
                } else {
                    print("Unknown error: \(encodingError)")
                    // completion(result as AnyObject, encodingError as AnyObject)
                    
                }
                SVProgressHUD.dismiss()
                break
            }
            
        }
    }
    
    private static var Manager: Alamofire.SessionManager = {
        
        // Create the server trust policies
        let serverTrustPolicies: [String: ServerTrustPolicy] = [
            SelfSignCert: .disableEvaluation
        ]
        // Create custom manager
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = Alamofire.SessionManager.defaultHTTPHeaders
        let manager = Alamofire.SessionManager(
            configuration: URLSessionConfiguration.default,
            serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)
        )
        
        return manager
    }()
}
