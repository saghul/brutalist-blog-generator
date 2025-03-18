import ArgumentParser

struct BuildCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "build",
        abstract: "Build the blog"
    )

    func run() throws {
        let builder = SiteBuilder()
        try builder.build()
    }
}
