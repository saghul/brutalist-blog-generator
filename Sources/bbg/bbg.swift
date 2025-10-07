import ArgumentParser

@main
struct BBG: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "bbg",
        abstract: "Brutalist Blog Generator",
        subcommands: [
            InitCommand.self,
            BuildCommand.self,
            ServeCommand.self,
            NewCommand.self,
        ]
    )
}
