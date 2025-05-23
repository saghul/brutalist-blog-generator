import Hummingbird

public struct SimpleWebServer {
    let hostname: String
    let port: Int
    let path: String

    public init(hostname: String, port: Int, path: String) {
        self.hostname = hostname
        self.port = port
        self.path = path
    }

    public func run() async throws {
        print("Starting server at http://\(hostname):\(port)")

        let router = Router()
        router.add(middleware: FileMiddleware(path, searchForIndexHtml: true))

        let app = Application(
            router: router,
            configuration: .init(address: .hostname(hostname, port: port))
        )

        try await app.runService()
    }
}
