import Hummingbird

struct SimpleWebServer {
    let hostname: String
    let port: Int
    let path: String

    init(hostname: String, port: Int, path: String) {
        self.hostname = hostname
        self.port = port
        self.path = path
    }

    func run() async throws {
        let router = Router()
        router.add(middleware: FileMiddleware(path, searchForIndexHtml: true))

        let app = Application(
            router: router,
            configuration: .init(address: .hostname(hostname, port: port))
        )

        print("Server started at http://\(hostname):\(port)")
        try await app.runService()
    }
}
