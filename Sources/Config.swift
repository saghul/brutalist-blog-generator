import Yams

struct Config {
    let title: String
    let tagLine: String
    let srcDir: String
    let outputDir: String
    let siteUrl: String

    private init(title: String? = nil,
                 tagLine: String? = nil,
                 srcDir: String? = nil,
                 outputDir: String? = nil,
                 siteUrl: String? = nil) {
        self.title = title ?? ""
        self.tagLine = tagLine ?? ""
        self.srcDir = srcDir ?? "www"
        self.outputDir = outputDir ?? "build"
        self.siteUrl = siteUrl ?? ""
    }

    static func load(from path: String) -> Config {
        guard let data = try? String(contentsOfFile: path) else {
            print("Failed to load config file")
            return Config()
        }

        guard let yaml = try? Yams.load(yaml: data) as? [String: String] else {
            print("Failed to parse config file")
            return Config()
        }

        return Config(title: yaml["title"],
                      tagLine: yaml["tagLine"],
                      srcDir: yaml["srcDir"],
                      outputDir: yaml["outputDir"],
                      siteUrl: yaml["siteUrl"])
    }
}
