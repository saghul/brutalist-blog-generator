import Foundation
import Yams

public struct DocumentMetadata {
    let title: String?
    let date: Date
    let slug: String?

    private init(title: String?, date: Date, slug: String?) {
        self.title = title
        self.date = date
        self.slug = slug
    }

    public static func parse(data: String?) throws -> DocumentMetadata {
        let yaml = try Yams.load(yaml: data ?? "") as? [String: String]

        let title = yaml?["title"]
        let slug = yaml?["slug"]
        let dateStr = yaml?["date"] ?? ""
        let formatter = ISO8601DateFormatter()
        let date = formatter.date(from: dateStr) ?? Date()

        return DocumentMetadata(title: title, date: date, slug: slug)
     }
}
