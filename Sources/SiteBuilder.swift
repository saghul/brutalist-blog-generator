import Foundation

struct SiteBuilder {
    private static let templates = [
        "index": String(decoding: Data(PackageResources.index_html), as: UTF8.self),
        "post": String(decoding: Data(PackageResources.post_html), as: UTF8.self),
    ]
    private let templateEngine: TemplateEngine
    private let config: Config
    private let srcDir: URL
    private let postsDir: URL
    private let outputDir: URL
    private let outputPostsDir: URL

    init() {
        config = Config.load(from: "config.yml")
        templateEngine = TemplateEngine(templates: SiteBuilder.templates)
        srcDir = URL(fileURLWithPath: config.srcDir)
        postsDir = srcDir.appendingPathComponent("posts")
        outputDir = URL(fileURLWithPath: config.outputDir)
        outputPostsDir = outputDir.appendingPathComponent("posts")
    }

    func build() throws {
        let fileManager = FileManager.default
        var documents: [Document] = []

        if let enumerator = fileManager.enumerator(atPath: postsDir.path) {
            while let filePath = enumerator.nextObject() as? String {
                if filePath.hasSuffix(".md") {
                    let fullPathUrl = postsDir.appendingPathComponent(filePath)
                    print("Found file: \(fullPathUrl.path)")
                    do {
                        let document = try Document.parse(path: fullPathUrl.path)
                        documents.append(document)
                    } catch {
                        print("Failed to process file: \(fullPathUrl.path)")
                        throw error
                    }
                }
            }
        }

        // Sort documents by date
        documents.sort { $0.date > $1.date }

        // Prepare output directory
        try fileManager.createDirectory(at: outputPostsDir, withIntermediateDirectories: true, attributes: nil)

        // Process each document
        for document in documents {
            try processPost(document: document)
        }

        // Generate index
        try processIndex(documents: documents)
    }

    private func processIndex(documents: [Document]) throws {
        let outputUrl = outputDir
            .appendingPathComponent("index.html")

        let context: [String : Any] = [
            "title": config.title,
            "tagLine": config.tagLine,
            "posts": documents.map { document in
                return [
                    "title": document.title,
                    "date": document.date,
                    "url": "posts/" + document.fileName,
                ]
            }
        ]
        let finalHtml = try templateEngine.renderTemplate(name: "index", context: context)
        try finalHtml.write(toFile: outputUrl.path, atomically: true, encoding: .utf8)

        print("Successfully generated HTML at: \(outputUrl.path)")
    }

    private func processPost(document: Document) throws {
        let outputUrl = outputPostsDir
            .appendingPathComponent(document.fileName)

        let html = document.toHtml()
        let context = [
            "post": [
                "title": document.title,
                "date": document.date,
                "content": html
            ]
        ]
        let finalHtml = try templateEngine.renderTemplate(name: "post", context: context)
        try finalHtml.write(toFile: outputUrl.path, atomically: true, encoding: .utf8)

        print("Successfully generated HTML at: \(outputUrl.path)")
    }
}
