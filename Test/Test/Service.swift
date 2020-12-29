//
//  Service.swift
//  Test
//
//  Created by 张欣 on 2020/12/28.
//

import Foundation

typealias ServicesSuccess = (Any) -> Void
typealias ServicesFaile = (String?) -> Void
class Service {
    
    public static func requestApi(success:@escaping ServicesSuccess,faile:@escaping ServicesFaile){
            let url = URL(string: "https://api.github.com")
            var request = URLRequest(url: url!)
            request.httpMethod = "GET"
            let configuration:URLSessionConfiguration = URLSessionConfiguration.default
            let session:URLSession = URLSession(configuration: configuration)
        
            DispatchQueue.global(qos: .userInitiated).async {
                let task:URLSessionDataTask = session.dataTask(with: request) { (data, response, error)->Void in
                    DispatchQueue.main.async {
                        if error == nil{
                            do{
                                let responseData:NSDictionary = try JSONSerialization.jsonObject(with: data!, options:   JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
                                    success(responseData)
                            }catch{
                                faile(nil)
                            }
                        }else{
                            success(error.debugDescription)
                        }
                    }
                }
                task.resume()
        }
    }
}

class LocalData {
    public static func setData(data:Any)  {
        let currentTime = Date().timeIntervalSince1970
        UserDefaults.standard.setValue(data, forKey: String(currentTime))
        UserDefaults.standard.synchronize()
    }
    
    public static func getData(key:String) -> NSDictionary {
        return UserDefaults.standard.value(forKey: key) as! NSDictionary
    }
    
    public static func getAllKeys(data:[String:Any]) ->[String]   {
        var list:[String]  = []
        for key in data.keys {
            list.append(String(key))
        }
    
        list.sort { (s1, s2) -> Bool in
            return s1 > s2
        }
        return list
    }
    
    public static func getAllKeys() ->[String]   {
        var list:[String]  = []
        for key in UserDefaults.standard.dictionaryRepresentation().keys {
            
            let number = String(key)
            if isNotfindChar(string: number) {
                list.append(number)
            }
        }
        list.sort { (s1, s2) -> Bool in
            return s1 > s2
        }
        return list
    }
    
    public static func getDataString(string:String) -> String
    {

        let time = TimeInterval(string)
        let date = NSDate(timeIntervalSince1970: time ?? 0)
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let timeString = dateformatter.string(from: date as Date)
        return timeString
    }
    
    private static func  isNotfindChar(string: String) -> Bool {
        for char in string.utf8 {
            if (char > 64 && char < 91) || (char > 96 && char < 123) {
                return false
            }
        }
        return true
    }
    
    
    
    
    
}
