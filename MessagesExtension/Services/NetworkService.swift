import UIKit

let baseUrl = "https://api.sticker.place"

enum APIEndpoint {
    
    case custom(path: String)
    case packInfo
    case analititycEvent
    case stickersPath
    
    var path: String {
        var endpoint = String()
        switch self {
        case .custom(let custom_path): return "\(custom_path)"
        case .packInfo:  endpoint = "/v2/packs"
        case .stickersPath: endpoint = "/v2/packs/\(SPSettingsManager.sharedInstance.kPackId)/images"
        case .analititycEvent: endpoint = "/v2/event"
        }
        
        return baseUrl + endpoint
    }
}

class NetworkService {
    
    enum NetworkError: Error {
        case unauthorized, forbidden, dataNil, unknown(Error?)
    }
    
    enum Result {
        case success(data: Data)
        case failure(error: Error?)
    }
    
    
    func getRequest(urlStr: String, headers: [String: String]? = nil, parameters: [String: Any]? = nil ,completion: @escaping (_ result: Result) -> () ) {
        var url: URL
        if let _headerString = headers?.stringFromHttpParameters() {
            url = URL(string: urlStr + "?\(_headerString)")!
        } else {
            url = URL(string: urlStr)!
        }
        
        var request = URLRequest(url: url)
        request.setValue(SPSettingsManager.sharedInstance.kApiKey, forHTTPHeaderField: "x-api-key")
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let httpResponse = response as? HTTPURLResponse {
                switch httpResponse.statusCode {
                case 200:
                    if let _data = data {
                        completion(.success(data: _data))
                    } else {
                        completion(.failure(error: NetworkError.dataNil))
                    }
                case 401:
                    completion(.failure(error: NetworkError.unauthorized))
                case 403:
                    completion(.failure(error: NetworkError.forbidden))
                default:
                    completion(.failure(error: NetworkError.unknown(error)))
                }
            } else {
                completion(.failure(error: NetworkError.unknown(error)))
            }
            
        }
        
        task.resume()
    }
    
    func postRequest(urlStr: String, headers: [String : String]? = nil, parameters: [String : Any]? = nil, body: Any? = nil, completion: @escaping (_ result: Result) -> () ) {
        var url: URL
        if let _headerString = headers?.stringFromHttpParameters() {
            url = URL(string: urlStr + "?\(_headerString)")!
        } else {
            url = URL(string: urlStr)!
        }
        
        var request = URLRequest(url: url)
        request.setValue(SPSettingsManager.sharedInstance.kApiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        if let _string = body as? String {
            request.httpBody = "'\(_string)'".data(using: .utf8)
        } else if let _parameters = body {
            request.httpBody = try? JSONSerialization.data(withJSONObject: _parameters, options: [])
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let httpResponse = response as? HTTPURLResponse {
                switch httpResponse.statusCode {
                case 200:
                    if let _data = data {
                        completion(.success(data: _data))
                    } else {
                        completion(.failure(error: NetworkError.dataNil))
                    }
                case 401:
                    completion(.failure(error: NetworkError.unauthorized))
                case 403:
                    completion(.failure(error: NetworkError.forbidden))
                default:
                    completion(.failure(error: NetworkError.unknown(error)))
                }
            } else {
                completion(.failure(error: NetworkError.unknown(error)))
            }
            
        }
        
        task.resume()
    }
    
    func getDataFromServerURL(urlString: String, completion: @escaping (Data?)->()) {
        guard let url = NSURL(string: urlString) as? URL else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) -> Void in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            
            completion(data)
        }).resume()
    }
}
