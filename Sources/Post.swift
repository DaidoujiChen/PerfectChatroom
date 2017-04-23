//
//  Post.swift
//  PerfectChatroom
//
//  Created by DaidoujiChen on 2017/4/23.
//
//

import PerfectHTTP
import Foundation

class Post {
    
    static func o3o() -> RequestHandler {
        return { req, res in
            guard let postBodyBytes = req.postBodyBytes else {
                let _ = try? res.setBody(json: [ "Error": "postBodyBytes Fail" ])
                res.completed()
                return
            }
            
            let data = Data(bytes: postBodyBytes)
            if var json = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: Any] {
                json["daidouji"] = "chen"
                let _ = try? res.setBody(json: json)
            }
            res.completed()
        }
    }
    
}
