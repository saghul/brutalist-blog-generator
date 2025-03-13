import ArgumentParser

@main
struct MWC: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "mwc",
        abstract: "A static website generator",
        subcommands: [
            InitCommand.self,
            BuildCommand.self
        ]
    )
}
