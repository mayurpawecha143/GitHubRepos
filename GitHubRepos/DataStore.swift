//
//  DataStore.swift
//  GitHubRepos
//
//  Created by Mayur Pawecha on 8/17/18.
//  Copyright © 2018 MayurPawecha. All rights reserved.
//

import Foundation
import UIKit

struct Repos {
    let name: String
    let description: String?
    let created_At: String
    let license: String?
    
    init(dictionary: Dictionary<String, Any>) {
        self.name = dictionary["name"] as! String
        if dictionary["description"] is NSNull
        {
            self.description = nil
        }
        else
        {
            self.description = dictionary["description"] as? String
        }
        self.created_At = dictionary["created_at"] as! String
        
        if dictionary["license"] is NSNull
        {
            self.license = nil
        }
        else
        {
            let dict = dictionary["license"] as! [String: Any]
            self.license = dict["name"] as? String
        }
    }
}

final class DataStore
{
    static let sharedInstance = DataStore()
    fileprivate init() {}
    
    var ReposList: [Repos] = []
    
    func GetRepoList(name : String, value : Int) {
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration)
        //https://api.github.com/users/apple/repos?page=1&per_page=10
        let urlString = NSString(format: "https://api.github.com/users/\(name)/repos?page=\(value/10)&per_page=10" as NSString)
        let request : NSMutableURLRequest = NSMutableURLRequest()
        request.url = NSURL(string: NSString(format: "%@", urlString) as String)! as URL
        
        let dataTask = session.dataTask(with: request as URLRequest) {
            ( data, response, error) -> Void in
            
            guard let httpResponse = response as? HTTPURLResponse, let receivedData = data
                else {
                    print("error: not a valid http response")
                    return
            }
            if httpResponse.statusCode == 200
            {
                let response = NSString (data: receivedData, encoding: String.Encoding.utf8.rawValue)
                print("response is \(String(describing: response))")
                
                do {
                    let getResponse = try JSONSerialization.jsonObject(with: receivedData, options: []) as! [Any]
                    for item in getResponse {
                        if let dict = item as? [String: Any]{
                            let newItem = Repos(dictionary: dict)
                            self.ReposList.append(newItem)
                        }
                    }
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateRepos"), object: nil)
                } catch {
                    print("error serializing JSON: \(error)")
                }
            }
        }
        dataTask.resume()
    }
}
