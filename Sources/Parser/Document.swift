import Foundation
import Markdown

public class Document {
    private let content: Markdown.Document

    private init(content: Markdown.Document) {
        self.content = content
    }

    public static func parse(path: String) throws -> Document {
        let markdown = try String(contentsOfFile: path, encoding: .utf8)
        let document = Markdown.Document(parsing: markdown)
        return Document(content: document)
    }

    public func toHtml() -> String {
        return HTMLFormatter.format(content)
    }
}
