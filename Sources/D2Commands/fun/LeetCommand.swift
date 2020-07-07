fileprivate let substitutions: [Character: Character] = [
    "A": "4",
    "E": "3",
    "O": "0",
    "L": "1",
    "T": "7",
    "S": "$",
    "B": "6",
    "I": "!"
]

public class LeetCommand: StringCommand {
    public let info = CommandInfo(
        category: .fun,
        shortDescription: "Converts text into leetspeak",
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        output.append(String(input.map { substitutions[Character($0.uppercased())] ?? $0 }))
    }
}
