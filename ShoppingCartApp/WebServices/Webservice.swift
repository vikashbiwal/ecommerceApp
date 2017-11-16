//  Webservice.swift

import Foundation
import Alamofire

let kInternetDown       = "Your internet connection seems to be down"
let kHostDown           = "Your host seems to be down"
let kTimeOut            = "The request timed out"
let kTokenExpire        = "Session expired - please login again."

typealias ResponseBlock = (_ response: Response) -> ()

class WebService {

    let manager: SessionManager
    var networkManager: NetworkReachabilityManager
    var headers: HTTPHeaders = [
        "Accept": "application/json",
        "Content-Type": "application/json"
    ]

   
    typealias WSProgress = (Progress) -> ()?
    typealias WSFileBlock = (_ path: String?, _ success: Bool) -> ()
    
    var successBlock: (String, HTTPURLResponse?, Any?, ResponseBlock) -> Void
    var errorBlock: (String, HTTPURLResponse?, NSError, ResponseBlock) -> Void
    
    
    //MARK : Initializer
    
    init() {
            manager = Alamofire.SessionManager.default
            networkManager = NetworkReachabilityManager()!
			manager.session.configuration.timeoutIntervalForRequest = 30

        
            // Will be called on success of web service calls.
            successBlock = { (relativePath, res, respObj, block) -> Void in
                // Check for response it should be there as it had come in success block
                if let response = res{
                    println("Response Code: \(response.statusCode)")
                    println("Response(\(relativePath)): \(String(describing: respObj))")
                    if response.statusCode == 200 {
                        block(Response(respObj, response.statusCode))
                    } else {
                        block(Response(respObj, response.statusCode))
                    }
                } else {
                    // There might me no case this can get execute
                    block(Response(nil, 404))
                }
            }
            
            // Will be called on Error during web service call
            errorBlock = { (relativePath, res, error, block) -> Void in
                // First check for the response if found check code and make decision
                if let response = res {
                    println("Response Code: \(response.statusCode)")
                    println("Error Code: \(error.code)")
                    if let data = error.userInfo["com.alamofire.serialization.response.error.data"] as? NSData {
                        let errorDict = (try? JSONSerialization.jsonObject(with: data as Data, options: JSONSerialization.ReadingOptions.mutableContainers)) as? NSDictionary
                        if errorDict != nil {
                            println("Error(\(relativePath)): \(errorDict!)")
                            block(Response(errorDict, response.statusCode))
                            if response.statusCode == 423 {
                                //TODO
                            }
                        } else {
                            block(Response(nil, response.statusCode))
                        }
                    } else {
                        block(Response(nil, response.statusCode))
                    }
                    // If response not found rely on error code to find the issue
                } else {
                    println("Error(\(relativePath)): \(error)")
                    block(Response(nil, error.code))
                }
                
            }
            addInterNetListner()
        }
    
    deinit {
            networkManager.stopListening()
        }

}


// MARK: - Request, ImageUpload and Dowanload methods
extension WebService {
    
    //MARK: GET REQUEST
     func GET_REQUEST(relPath: String, param: [String: Any]?, block: @escaping ResponseBlock)-> DataRequest?{
        println("----------------------Request API : \(relPath)---------------------")
        println("----------------------Request Parameters : \(param ?? [:])")
        println("-------------------------------------------------------------------")

        do{
            return manager.request(try apiUrl(relPath: relPath), method: HTTPMethod.get, parameters: param, encoding: URLEncoding.queryString, headers: headers).responseJSON { (resObj) in
                switch resObj.result {
                case .success:
                    let dictionary = resObj.response?.allHeaderFields as! [String:Any]          //Get Headers to check token
                    self.checkClientTokenFromHeader(dict: dictionary)
                    if let resData = resObj.data {
                        do {
                            let res = try JSONSerialization.jsonObject(with: resData, options: [])
                            self.successBlock(relPath, resObj.response, res, block)
                        } catch let errParse {
                            println(errParse)
                            self.errorBlock(relPath, resObj.response, errParse as NSError, block)
                        }
                    }
                case .failure(let err):
                    println(err)
                    self.errorBlock(relPath, resObj.response, err as NSError, block)
                }
            }
        } catch let error {
            println(error)
            errorBlock(relPath, nil, error as NSError, block)
            return nil
        }
    }
    
    //MARK: POST REQUEST
     func POST_REQUEST(relPath: String, param: [String: Any]?, block: @escaping ResponseBlock)-> DataRequest?{
        println("----------------------Request API : \(relPath)---------------------")
        println("----------------------Request Parameters : \(param ?? [:])")
        println("-------------------------------------------------------------------")
        do{
			let encoding:ParameterEncoding = relPath == APIName.GetAuthToken ? URLEncoding.default : JSONEncoding.default
            return manager.request(try apiUrl(relPath: relPath), method: HTTPMethod.post, parameters: param, encoding: encoding, headers: headers).responseJSON { (resObj) in
                print( resObj.request as Any)
                
                switch resObj.result{
                case .success:
                    let dictionary = resObj.response?.allHeaderFields as! [String:Any]          //Get Headers to check token
                    self.checkClientTokenFromHeader(dict: dictionary)
                    if let resData = resObj.data{
                        do {
                            let res = try JSONSerialization.jsonObject(with: resData, options: [.allowFragments, .mutableLeaves, .mutableContainers]) as AnyObject
                            self.successBlock(relPath, resObj.response, res, block)
                        } catch let errParse{
                            println(errParse)
                            self.errorBlock(relPath, resObj.response, errParse as NSError, block)
                        }
                    }
                    break
                case .failure(let err):
                    println(err)
                    if let dictionary = resObj.response?.allHeaderFields as? [String:Any]{
                        self.checkClientTokenFromHeader(dict: dictionary)
                    }//Get Headers to check token
                    self.errorBlock(relPath, resObj.response, err as NSError, block)

                    break
                }
            }
        } catch let error {
            println(error)
            errorBlock(relPath, nil, error as NSError, block)
            return nil
        }
    }
    
    //MARK: UPLOAD IMAGE
    func UPLOAD_IMAGE(relPath: String,imgData: Data, param: [String: String]?, block: @escaping ResponseBlock, progress: WSProgress?){
        do{
            manager.upload(multipartFormData: { (formData) in
                formData.append(imgData, withName: "keyName", fileName: "image.jpeg", mimeType: "image/jpeg")
                
                if let param = param{
                    for (key, value) in param {
                        formData.append(value.data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: key)
                    }
                }
            },
                           to: try apiUrl(relPath: relPath), method: HTTPMethod.post, headers: headers,
                           encodingCompletion: { encoding in
                switch encoding{
                case .success(let req, _, _):
                    req.uploadProgress(closure: { (prog) in
                        progress?(prog)
                        
                    }).responseJSON { (resObj) in
                        let dictionary = resObj.response?.allHeaderFields as! [String:Any]          //Get Headers to check token
                        self.checkClientTokenFromHeader(dict: dictionary)
                        
                        switch resObj.result{
                        case .success:
                            if let resData = resObj.data{
                                do {
                                    let res = try JSONSerialization.jsonObject(with: resData, options: [])
                                    self.successBlock(relPath, resObj.response, res, block)
                                } catch let errParse{
                                    println(errParse)
                                    self.errorBlock(relPath, resObj.response, errParse as NSError, block)
                                }
                            }
                            break
                        case .failure(let err):
                            println(err)
                            self.errorBlock(relPath, resObj.response, err as NSError, block)
                            break
                        }
                    }
                    break
                case .failure(let err):
                    println(err)
                    self.errorBlock(relPath, nil, err as NSError, block)
                    break
                }
            })
        } catch let err{
            self.errorBlock(relPath, nil, err as NSError, block)
        }
    }
    
    //MARK: DOWNLOAD FILE
    func DOWNLOAD_FILE(relPath : String, progress: WSProgress?, block: @escaping WSFileBlock){
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            
            if let imageName = URL(string: relPath)?.lastPathComponent {
                let fileURL = documentsURL.appendingPathComponent("panorama/\(imageName)")
                return (fileURL, [.removePreviousFile, .createIntermediateDirectories])

            } else {
                return (documentsURL, [.removePreviousFile, .createIntermediateDirectories])
            }
        }
        
        do{
            manager.download(try apiUrl(relPath: relPath), to: destination).downloadProgress { (prog) in
                progress?(prog)
                }.response { (responce) in
                    if responce.error == nil, let path = responce.destinationURL?.path{
                        block(path, true)
                    }else{
                        block(nil, false)
                    }
                }.resume()
            
        } catch {
            block(nil, false)
        }
    }
}


//MARK: ACCESS TOKEN ADD AND REMOVE
extension WebService {
    
    func setAccesTokenToHeader(token:String){
        manager.adapter = TokenAdapter(token)
       
    }
    
    func removeAccessTokenFromHeader(){
        manager.adapter = nil
    }
    
    func checkClientTokenFromHeader(dict : [String:Any]){
        
        if dict != nil{
            
            if dict["Authorization"] as? String != nil{
                let newToken = dict["Authorization"] as! String
                removeClientToken()
                _userDefault.set(newToken, forKey: AppPreference.authToken)
                setClientToken(token:newToken)
            }
        }
    }
    
    func setClientToken(token: String){
        headers["Authorization"] =  token
    }
    
    func removeClientToken(){
        headers.removeValue(forKey: "Authorization")
    }
    
    func setHeaderCustomerId(custId : String){
        headers["customerId"] = custId
    }
    
    func removeHeaderCustomerId(){
        headers.removeValue(forKey: "customerId")
    }
    
    func apiUrl(relPath : String) throws -> URL{
        do{
            if relPath.lowercased().contains("http") || relPath.lowercased().contains("www"){
                return try relPath.asURL()
            }else{
                return try (_baseUrl+relPath).asURL()
            }
        }catch let err{
            throw err
        }
    }

}

//MARK: TOKEN ADAPTER
fileprivate class TokenAdapter: RequestAdapter {
    private let token: String
    
    init(_ token: String) {
        self.token = token
    }
    
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        var urlRequest = urlRequest
        urlRequest.setValue(token, forHTTPHeaderField: "Authorization")
		//urlRequest.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")

        print("Token added : \(token)")
        return urlRequest
    }
}

// MARK: - INTERNET AVAILABILITY
fileprivate extension WebService {
    
    func addInterNetListner(){
        networkManager.listener = { (status) in
            if status == NetworkReachabilityManager.NetworkReachabilityStatus.notReachable{
                print("No InterNet")
            }else{
                print("Internet Avail")
            }
        }
        networkManager.startListening()
    }
    
    func isInternetAvailable() -> Bool {
        if networkManager.isReachable{
            return true
        }else{
            return false
        }
    }
}



//Structure will be used for manage the ws response.
struct Response {
    var isSuccess  = false
    let json: Any?
    var message: String
    var code = 0
    
    init(_ rJson : Any?, _ code : Int) {
        self.isSuccess = false
        self.json = rJson
        self.message = ""
        self.code = code
        
        if code == 200 {
            isSuccess = true
			if let message = rJson as? String {
				self.message = message
			} else if let json = rJson as? [String: Any] {
                if let msg = json["message"] as? String {
                    message = msg
                }
            }
        } else if code == 400 { //
            if let json = rJson as? [String: Any] {
                if let msgInfo = json["message"] as? String {
                    message = msgInfo
                }
            }
            
        } else if  code == 404  {//used for no data available
            if let json = rJson as? [String: Any] {
                if let msgInfo = json["message"] as? String {
                    message = msgInfo
                }
            }
        } else if  code == -1009  {
            message = kInternetDown
            //CustomAlertView.show(alertMsg: kInternetDown)
        } else if code == -1003  {
            message = kHostDown
            //CustomAlertView.show(alertMsg: kHostDown)
        } else if code == -1001  {
            message = kTimeOut
            //CustomAlertView.show(alertMsg: kTimeOut)
        } else {
            message = "Something went wrong!"
            //CustomAlertView.show(alertMsg: "Something happen wrong.")

        }

    }
    
}

