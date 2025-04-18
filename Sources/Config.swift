import Yams

struct Config {
    let title: String
    let tagLine: String
    let srcDir: String
    let outputDir: String
    let siteUrl: String
    let links: [Link]
    let footer: String

    private init(title: String? = nil,
                 tagLine: String? = nil,
                 srcDir: String? = nil,
                 outputDir: String? = nil,
                 siteUrl: String? = nil,
                 links: [Link]? = nil,
                 footer: String? = nil) {
        self.title = title ?? ""
        self.tagLine = tagLine ?? ""
        self.srcDir = srcDir ?? "www"
        self.outputDir = outputDir ?? "build"
        self.siteUrl = siteUrl ?? ""
        self.links = links ?? []
        self.footer = footer ?? ""
    }

    static func load(from path: String) -> Config {
        guard let data = try? String(contentsOfFile: path) else {
            print("Failed to load config file")
            return Config()
        }

        guard let yaml = try? Yams.load(yaml: data) as? [String: Any] else {
            print("Failed to parse config file")
            return Config()
        }

        let links: [Link] = (yaml["links"] as? [[String: String]])?.compactMap { dict in
            guard let name = dict["name"],
                  let url = dict["url"] else {
                return nil
            }
            return Link(name: name, url: url)
        } ?? []

        return Config(title: yaml["title"] as? String,
                      tagLine: yaml["tagLine"] as? String,
                      srcDir: yaml["srcDir"] as? String,
                      outputDir: yaml["outputDir"] as? String,
                      siteUrl: yaml["siteUrl"] as? String,
                      links: links,
                      footer: yaml["footer"] as? String)
    }
}

struct Link {
    let name: String
    let url: String
}
