//
//  O3OHandler.swift
//  PerfectChatroom
//
//  Created by DaidoujiChen on 2017/4/23.
//
//

import PerfectHTTP
import PerfectWebSockets
import Foundation

class WeakReference: NSObject {
    
    weak var o3o: O3OHandler?
    
    init(weak: O3OHandler) {
        self.o3o = weak
    }
    
}

// MARK: Class Methods / Properties
extension O3OHandler {
    
    fileprivate static var o3os: [WeakReference] = []
    fileprivate static var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter
    }()
    
    // 伺服器當前時間
    fileprivate static func serverTime() -> String {
        return self.dateFormatter.string(from: Date())
    }
    
    // 列舉所有 Client 並且清除掉已離線 Client
    fileprivate static func eachO3O(callback: (_ o3o: O3OHandler) -> () ) {
        for weakReference in self.o3os {
            if let safeO3O = weakReference.o3o {
                callback(safeO3O)
            }
            else {
                if let index = self.o3os.index(of: weakReference) {
                    self.o3os.remove(at: index)
                }
            }
        }
    }
    
    // 傳送訊息給當前聊天室中所有 Client
    fileprivate static func sendMessage(message: String) {
        self.eachO3O { (o3o) in
            o3o.sendMessage(message: "[\(self.serverTime())] \(message)")
        }
    }
    
    // 歡迎訊息 (顯示在線用戶)
    fileprivate static func welcomeMessage(exclude: O3OHandler) -> String? {
        var userIDs: [String] = []
        self.eachO3O { (o3o) in
            userIDs.append(o3o.userID)
        }
        
        if userIDs.count > 0 {
            return userIDs.joined(separator: ", ")
        }
        
        return nil
    }
    
}

// MARK: Instance Methods
extension O3OHandler {
    
    // 傳送訊息到 Client
    fileprivate func sendMessage(message: String) {
        guard
            let safeSocket = self.socket,
            let safeRequest = self.request else {
                return
        }
        
        safeSocket.sendStringMessage(string: message, final: true) {
            self.listenClient(request: safeRequest, socket: safeSocket)
        }
    }
    
    // 等待 Client 傳入訊息
    fileprivate func listenClient(request: HTTPRequest, socket: WebSocket) {
        if !self.isListening {
            self.isListening = true
            socket.readStringMessage { (string, codeType, finish) in
                self.isListening = false
                
                guard let string = string else {
                    socket.close()
                    return
                }
                
                if !string.contains(":") {
                    self.userID = string
                    
                    if let welcomeMessage = O3OHandler.welcomeMessage(exclude: self) {
                        self.sendMessage(message: "Online User : \(welcomeMessage)")
                    }
                }
                else {
                    O3OHandler.sendMessage(message: string);
                }
            }
        }
    }
    
}

// MARK: O3OHandler Instance
class O3OHandler: WebSocketSessionHandler {
    
    // MARK: Init Values
    
    fileprivate var request: HTTPRequest? = nil
    fileprivate var socket: WebSocket? = nil
    fileprivate var userID = ""
    fileprivate var isListening = false
    
    // MARK: WebSocketSessionHandler
    
    let socketProtocol: String? = "o3o"
    
    func handleSession(request: HTTPRequest, socket: WebSocket) {
        guard let _ = self.request, let _ = self.socket else {
            self.request = request
            self.socket = socket
            self.listenClient(request: request, socket: socket)
            O3OHandler.o3os.append(WeakReference(weak: self))
            return
        }
    }
    
    // MARK: Life Cycle
    
    deinit {
        O3OHandler.sendMessage(message: "\(self.userID) Offline")
        print("dealloc \(self)")
    }
    
}
