import Kitura
import HeliumLogger
import SwiftProtobuf

HeliumLogger.use()

let router = Router()

func getLibrary() -> MyLibrary {
    let map = ["route": "66"]
    
    var bookInfo = BookInfo()
    bookInfo.id = 10
    bookInfo.title = "Welcome to Swift"
    bookInfo.author = "Apple Inc."
    
    var library = MyLibrary()
    library.id = 20
    library.name = "Swift"
    library.books = [bookInfo]
    library.keys = map
    
    return library
}

router.get("/") { request, response, next in
    let library = getLibrary()
    
    let accept = request.headers["Accept"]
    if accept == "application/protobuf" {
        response.headers["Content-Type"] = "application/protobuf"
        response.send(data: try library.serializeProtobuf())
    } else {
        response.headers["Content-Type"] = "application/json; charset=UTF-8"
        response.send(try library.serializeJSON())
    }
    
    next()
}

Kitura.addHTTPServer(onPort: 8090, with: router)

Kitura.run()
