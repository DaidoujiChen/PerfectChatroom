//
//  Get.swift
//  PerfectChatroom
//
//  Created by DaidoujiChen on 2017/4/23.
//
//

import PerfectHTTP
import PerfectWebSockets

class Get {
    
    static func version() -> RequestHandler {
        return { req, res in
            res.appendBody(string: "Version 1.0.1")
            res.completed()
        }
    }
    
    static func webSocker() -> RequestHandler {
        return { req, res in
            
            // 如果 protocol 有符合的話, 就會用 WebSocketSessionHandler 來接他
            WebSocketHandler(handlerProducer: { (_, protocols) -> WebSocketSessionHandler? in
                guard protocols.contains("o3o") else {
                    return nil
                }
                return O3OHandler()
            }).handleRequest(request: req, response: res)
        }
    }
    
}
