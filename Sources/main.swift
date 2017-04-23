//
//  main.swift
//  PerfectChatroom
//
//  Created by DaidoujiChen on 2017/4/23.
//
//

import PerfectHTTP
import PerfectHTTPServer

// 開一台 server
let server = HTTPServer()
server.serverPort = 8080;
server.documentRoot = "./webroot"

// 加上 routes
var routes = Routes()

// Get routes
routes.add(method: .get, uri: "/version", handler: Get.version())
routes.add(method: .get, uri: "/**", handler: { req, res in
    StaticFileHandler(documentRoot: req.documentRoot).handleRequest(request: req, response: res)
})
routes.add(method: .get, uri: "/websocket", handler: Get.webSocker())

// Post routes
routes.add(method: .post, uri: "/o3o", handler: Post.o3o())
server.addRoutes(routes)

do {
    try server.start()
}
catch {
    print("Start Server Error : \(error)")
}

