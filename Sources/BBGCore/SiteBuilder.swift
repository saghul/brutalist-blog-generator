import Foundation

public struct SiteBuilder: Decodable {
    private static let templates = [
        "base": String(decoding: Data(PackageResources.base_mustache), as: UTF8.self),
        "index": String(decoding: Data(PackageResources.index_mustache), as: UTF8.self),
        "post": String(decoding: Data(PackageResources.post_mustache), as: UTF8.self),
        "page": String(decoding: Data(PackageResources.page_mustache), as: UTF8.self),
        "main": String(decoding: Data(PackageResources.main_mustache), as: UTF8.self),
        "rss": String(decoding: Data(PackageResources.rss_mustache), as: UTF8.self),
    ]
    private let templateEngine: TemplateEngine
    private let srcDir: URL
    private let postsDir: URL
    private let pagesDir: URL
    private let staticDir: URL
    private let outputDir: URL
    private let outputPostsDir: URL
    private let outputPagesDir: URL

    public let config: Config

    public init() {
        config = Config.load(from: "config.yml")
        templateEngine = TemplateEngine(templates: SiteBuilder.templates)
        srcDir = URL(fileURLWithPath: config.srcDir)
        postsDir = srcDir.appendingPathComponent("posts")
        pagesDir = srcDir.appendingPathComponent("pages")
        staticDir = srcDir.appendingPathComponent("static")
        outputDir = URL(fileURLWithPath: config.outputDir)
        outputPostsDir = outputDir.appendingPathComponent("posts")
        outputPagesDir = outputDir.appendingPathComponent("pages")
    }

    public init(from decoder: Decoder) throws {
        self.init()
    }

    public func build() throws {
        let fileManager = FileManager.default

        // Prepare output directory
        do {
            try fileManager.removeItem(at: outputDir)
        } catch {
            // Ignore error, directory might not exist.
        }

        // Process posts
        let posts = try processPosts()

        // Generate RSS
        try processRss(posts: posts)

        // Generate pages
        try processPages()

        // Generate index
        try processIndex(posts: posts)

        // Generate CSS
        try processCss()

        // Copy static directory
        if fileManager.fileExists(atPath: staticDir.path) {
            try fileManager.copyItem(at: staticDir, to: outputDir.appendingPathComponent("static"))
        }
    }

    private func loadDocuments(at: URL) throws -> [Document] {
        let fileManager = FileManager.default
        var docs: [Document] = []

        if let enumerator = fileManager.enumerator(atPath: at.path) {
            while let filePath = enumerator.nextObject() as? String {
                if filePath.hasSuffix(".md") {
                    let fullPathUrl = at.appendingPathComponent(filePath)
                    //print("Found file: \(fullPathUrl.path)")
                    do {
                        let doc = try Document.parse(path: fullPathUrl.path)
                        docs.append(doc)
                    } catch {
                        print("Failed to process file: \(fullPathUrl.path)")
                        throw error
                    }
                }
            }
        }

        return docs
    }

    private func processCss() throws {
        let outputUrl = outputDir
            .appendingPathComponent("main.css")

        let finalCss = try templateEngine.renderTemplate(name: "main", context: [:])
        try finalCss.write(toFile: outputUrl.path, atomically: true, encoding: .utf8)

        print("Successfully generated CSS at: \(outputUrl.path)")
    }

    private func processIndex(posts: [Document]) throws {
        let outputUrl = outputDir
            .appendingPathComponent("index.html")

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let context: [String : Any] = [
            "title": config.title,
            "tagLine": config.tagLine,
            "siteRoot": "",
            "siteUrl": config.siteUrl,
            "links": config.links,
            "footer": config.footer,
            "posts": posts.map { post in
                return [
                    "title": post.title,
                    "date": post.date,
                    "formattedDate": dateFormatter.string(from: post.date),
                    "url": "posts/" + post.fileName,
                ]
            }
        ]
        let finalHtml = try templateEngine.renderTemplate(name: "index", context: context)
        try finalHtml.write(toFile: outputUrl.path, atomically: true, encoding: .utf8)

        print("Successfully generated HTML at: \(outputUrl.path)")
    }

    private func processPosts() throws -> [Document] {
        let fileManager = FileManager.default
        var posts = try loadDocuments(at: postsDir)

        // Sort posts by date
        posts.sort { $0.date > $1.date }

        try fileManager.createDirectory(at: outputPostsDir, withIntermediateDirectories: true, attributes: nil)

        // Process each document
        for post in posts {
            try processPost(post)
        }

        return posts
    }

    private func processPost(_ post: Document) throws {
        let outputUrl = outputPostsDir
            .appendingPathComponent(post.fileName)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let context: [String : Any] = [
            "title": config.title,
            "tagLine": config.tagLine,
            "siteRoot": "../",
            "siteUrl": config.siteUrl,
            "footer": config.footer,
            "links": config.links,
            "post": [
                "title": post.title,
                "date": post.date,
                "formattedDate": dateFormatter.string(from: post.date),
                "content": post.toHtml()
            ]
        ]
        let finalHtml = try templateEngine.renderTemplate(name: "post", context: context)
        try finalHtml.write(toFile: outputUrl.path, atomically: true, encoding: .utf8)

        print("Successfully generated HTML at: \(outputUrl.path)")
    }

    private func processPages() throws {
        let fileManager = FileManager.default
        let pages = try loadDocuments(at: pagesDir)

        try fileManager.createDirectory(at: outputPagesDir, withIntermediateDirectories: true, attributes: nil)

        // Process each page
        for page in pages {
            try processPage(page)
        }
    }

    private func processPage(_ page: Document) throws {
        let outputUrl = outputPagesDir
            .appendingPathComponent(String(format: "%@.html", page.slug))

        let context: [String : Any] = [
            "title": config.title,
            "tagLine": config.tagLine,
            "siteRoot": "../",
            "siteUrl": config.siteUrl,
            "footer": config.footer,
            "links": config.links,
            "page": [
                "title": page.title,
                "content": page.toHtml()
            ]
        ]
        let finalHtml = try templateEngine.renderTemplate(name: "page", context: context)
        try finalHtml.write(toFile: outputUrl.path, atomically: true, encoding: .utf8)

        print("Successfully generated HTML at: \(outputUrl.path)")
    }

    private func processRss(posts: [Document]) throws {
        let outputUrl = outputDir
            .appendingPathComponent("rss.xml")

        // Take only the 10 most recent posts
        let recentPosts = Array(posts.prefix(10))

        let context: [String : Any] = [
            "title": config.title,
            "tagLine": config.tagLine,
            "date": Date().rfc822String(),
            "siteUrl": config.siteUrl,
            "posts": recentPosts.map { post in
                return [
                    "title": post.title,
                    "date": post.date.rfc822String(),
                    "url": "posts/" + post.fileName,
                    "content": post.toHtml()
                ]
            }
        ]
        let finalXml = try templateEngine.renderTemplate(name: "rss", context: context)
        try finalXml.write(toFile: outputUrl.path, atomically: true, encoding: .utf8)

        print("Successfully generated RSS at: \(outputUrl.path)")
    }
}
