import Foundation

struct SiteBuilder: Decodable {
    private static let templates = [
        "base.html": String(decoding: Data(PackageResources.base_html), as: UTF8.self),
        "index.html": String(decoding: Data(PackageResources.index_html), as: UTF8.self),
        "post.html": String(decoding: Data(PackageResources.post_html), as: UTF8.self),
        "main.css": String(decoding: Data(PackageResources.main_css), as: UTF8.self),
        "rss.xml": String(decoding: Data(PackageResources.rss_xml), as: UTF8.self),
    ]
    private let templateEngine: TemplateEngine
    private let srcDir: URL
    private let postsDir: URL
    private let staticDir: URL
    private let outputDir: URL
    private let outputPostsDir: URL

    let config: Config

    init() {
        config = Config.load(from: "config.yml")
        templateEngine = TemplateEngine(templates: SiteBuilder.templates)
        srcDir = URL(fileURLWithPath: config.srcDir)
        postsDir = srcDir.appendingPathComponent("posts")
        staticDir = srcDir.appendingPathComponent("static")
        outputDir = URL(fileURLWithPath: config.outputDir)
        outputPostsDir = outputDir.appendingPathComponent("posts")
    }

    init(from decoder: Decoder) throws {
        self.init()
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
        do {
            try fileManager.removeItem(at: outputDir)
        } catch {
            // Ignore error, directory might not exist.
        }

        try fileManager.createDirectory(at: outputPostsDir, withIntermediateDirectories: true, attributes: nil)

        // Process each document
        for document in documents {
            try processPost(document: document)
        }

        // Generate RSS
        try processRss(documents: documents)

        // Generate index
        try processIndex(documents: documents)

        // Generate CSS
        try processCss()

        // Copy static directory
        if fileManager.fileExists(atPath: staticDir.path) {
            try fileManager.copyItem(at: staticDir, to: outputDir.appendingPathComponent("static"))
        }
    }

    private func processCss() throws {
        let outputUrl = outputDir
            .appendingPathComponent("main.css")

        let finalCss = try templateEngine.renderTemplate(name: "main.css", context: [:])
        try finalCss.write(toFile: outputUrl.path, atomically: true, encoding: .utf8)

        print("Successfully generated CSS at: \(outputUrl.path)")
    }

    private func processIndex(documents: [Document]) throws {
        let outputUrl = outputDir
            .appendingPathComponent("index.html")

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let context: [String : Any] = [
            "title": config.title,
            "tagLine": config.tagLine,
            "siteUrl": config.siteUrl,
            "links": config.links,
            "posts": documents.map { document in
                return [
                    "title": document.title,
                    "date": dateFormatter.string(from: document.date),
                    "url": "posts/" + document.fileName,
                ]
            }
        ]
        let finalHtml = try templateEngine.renderTemplate(name: "index.html", context: context)
        try finalHtml.write(toFile: outputUrl.path, atomically: true, encoding: .utf8)

        print("Successfully generated HTML at: \(outputUrl.path)")
    }

    private func processPost(document: Document) throws {
        let outputUrl = outputPostsDir
            .appendingPathComponent(document.fileName)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let context: [String : Any] = [
            "title": config.title,
            "tagLine": config.tagLine,
            "siteUrl": config.siteUrl,
            "post": [
                "title": document.title,
                "date": dateFormatter.string(from: document.date),
                "content": document.toHtml()
            ]
        ]
        let finalHtml = try templateEngine.renderTemplate(name: "post.html", context: context)
        try finalHtml.write(toFile: outputUrl.path, atomically: true, encoding: .utf8)

        print("Successfully generated HTML at: \(outputUrl.path)")
    }

    private func processRss(documents: [Document]) throws {
        let outputUrl = outputDir
            .appendingPathComponent("rss.xml")

        // Take only the 10 most recent posts
        let recentPosts = Array(documents.prefix(10))

        let context: [String : Any] = [
            "title": config.title,
            "tagLine": config.tagLine,
            "date": Date().rfc822String(),
            "siteUrl": config.siteUrl,
            "posts": recentPosts.map { document in
                return [
                    "title": document.title,
                    "date": document.date.rfc822String(),
                    "url": "posts/" + document.fileName,
                    "content": document.toHtml()
                ]
            }
        ]
        let finalXml = try templateEngine.renderTemplate(name: "rss.xml", context: context)
        try finalXml.write(toFile: outputUrl.path, atomically: true, encoding: .utf8)

        print("Successfully generated RSS at: \(outputUrl.path)")
    }
}
