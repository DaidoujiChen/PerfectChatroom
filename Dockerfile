FROM perfectlysoft/perfectassistant
RUN apt-get update -y && apt-get install clang openssl libssl-dev uuid-dev libcurl3 -y
ADD Package.swift /usr/src/SwiftProject/Package.swift
ADD Sources/* /usr/src/SwiftProject/Sources/
ADD Sources/chatroom.html /usr/src/SwiftProject/webroot/chatroom.html
WORKDIR /usr/src/SwiftProject
RUN swift build
CMD .build/debug/PerfectChatroom --port 8080
