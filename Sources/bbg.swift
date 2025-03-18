import ArgumentParser

@main
struct BBG: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "bbg",
        abstract: "Brutalist Blog Generator",
        subcommands: [
            InitCommand.self,
            BuildCommand.self
        ]
    )
}
