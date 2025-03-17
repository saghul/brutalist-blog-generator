import Markdown

extension Markdown.Document {
    func getTitle() -> String? {
        guard let heading = children.first(where: { $0 is Heading }) as? Heading else {
            return nil
        }

        return heading.plainText
    }
}
