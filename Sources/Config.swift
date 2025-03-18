import Yams

struct Config {
    let title: String
    let tagLine: String

    private init(title: String?, tagLine: String?) {
        self.title = title ?? ""
        self.tagLine = tagLine ?? ""
    }

    static func load(from path: String) -> Config {
        guard let data = try? String(contentsOfFile: path) else {
            return Config(title: nil, tagLine: nil)
        }

        guard let yaml = try? Yams.load(yaml: data) as? [String: String] else {
            return Config(title: nil, tagLine: nil)
        }

        return Config(title: yaml["title"], tagLine: yaml["tagLine"])
    }
}
