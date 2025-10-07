import Foundation
import Yams

public struct ThemeColors: Sendable {
    public let background: String
    public let text: String
    public let link: String
    public let codeBg: String
    public let border: String
    public let codeBorderLeft: String
    public let secondaryText: String

    static let defaultLight = ThemeColors(
        background: "#FAFAFA",
        text: "#24292f",
        link: "#0969da",
        codeBg: "#f6f8fa",
        border: "#d0d7de",
        codeBorderLeft: "#2b2b2b",
        secondaryText: "#57606a"
    )

    static let defaultDark = ThemeColors(
        background: "#0d1117",
        text: "#e6edf3",
        link: "#58a6ff",
        codeBg: "#161b22",
        border: "#30363d",
        codeBorderLeft: "#6e7681",
        secondaryText: "#8b949e"
    )
}

public struct ThemeConfig: Sendable {
    public let light: ThemeColors
    public let dark: ThemeColors

    static let `default` = ThemeConfig(
        light: .defaultLight,
        dark: .defaultDark
    )
}

public struct Config {
    public let title: String
    public let tagLine: String
    public let srcDir: String
    public let outputDir: String
    public let siteUrl: String
    public let links: [Link]
    public let footer: String
    public let theme: ThemeConfig
    public let defaultTheme: String

    public var basePath: String {
        guard let url = URL(string: siteUrl) else {
            return "/"
        }
        let path = url.path
        if path.isEmpty || path == "/" {
            return "/"
        }
        return path.hasSuffix("/") ? path : path + "/"
    }

    private init(title: String? = nil,
                 tagLine: String? = nil,
                 srcDir: String? = nil,
                 outputDir: String? = nil,
                 siteUrl: String? = nil,
                 links: [Link]? = nil,
                 footer: String? = nil,
                 theme: ThemeConfig? = nil,
                 defaultTheme: String? = nil) {
        self.title = title ?? ""
        self.tagLine = tagLine ?? ""
        self.srcDir = srcDir ?? "www"
        self.outputDir = outputDir ?? "build"
        self.siteUrl = siteUrl ?? ""
        self.links = links ?? []
        self.footer = footer ?? ""
        self.theme = theme ?? .default
        self.defaultTheme = defaultTheme ?? "auto"
    }

    public func withSiteUrl(_ newSiteUrl: String) -> Config {
        return Config(
            title: self.title,
            tagLine: self.tagLine,
            srcDir: self.srcDir,
            outputDir: self.outputDir,
            siteUrl: newSiteUrl,
            links: self.links,
            footer: self.footer,
            theme: self.theme,
            defaultTheme: self.defaultTheme
        )
    }

    public static func load(from path: String) -> Config {
        guard let data = try? String(contentsOfFile: path, encoding: .utf8) else {
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

        let theme: ThemeConfig? = {
            guard let themeDict = yaml["theme"] as? [String: Any] else { return nil }

            let parseColors = { (dict: [String: String]) -> ThemeColors in
                return ThemeColors(
                    background: dict["background"] ?? "",
                    text: dict["text"] ?? "",
                    link: dict["link"] ?? "",
                    codeBg: dict["codeBg"] ?? "",
                    border: dict["border"] ?? "",
                    codeBorderLeft: dict["codeBorderLeft"] ?? "",
                    secondaryText: dict["secondaryText"] ?? ""
                )
            }

            guard let lightDict = themeDict["light"] as? [String: String],
                  let darkDict = themeDict["dark"] as? [String: String] else {
                return nil
            }

            return ThemeConfig(
                light: parseColors(lightDict),
                dark: parseColors(darkDict)
            )
        }()

        return Config(title: yaml["title"] as? String,
                      tagLine: yaml["tagLine"] as? String,
                      srcDir: yaml["srcDir"] as? String,
                      outputDir: yaml["outputDir"] as? String,
                      siteUrl: yaml["siteUrl"] as? String,
                      links: links,
                      footer: yaml["footer"] as? String,
                      theme: theme,
                      defaultTheme: yaml["defaultTheme"] as? String)
    }
}

public struct Link {
    let name: String
    let url: String
}
