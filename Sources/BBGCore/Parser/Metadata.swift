import Foundation
import Yams

enum MetadataError: Error {
    case invalidDate
    case missingDate
}

struct DocumentMetadata {
    let date: Date
    let title: String?
    let slug: String?

    private init(date: Date, title: String?, slug: String?) {
        self.date = date
        self.title = title
        self.slug = slug
    }

    static func parse(data: String?) throws -> DocumentMetadata {
        let yaml = try Yams.load(yaml: data ?? "") as? [String: String]

        // Extract date and make sure it's correctly formatted'
        let dateStr = yaml?["date"]
        guard let validDateStr = dateStr else {
            throw MetadataError.missingDate
        }
        let formatter = ISO8601DateFormatter()
        let date = formatter.date(from: validDateStr)
        guard let validDate = date else {
            throw MetadataError.invalidDate
        }

        let title = yaml?["title"]
        let slug = yaml?["slug"]

        return DocumentMetadata(date: validDate, title: title, slug: slug)
     }
}
