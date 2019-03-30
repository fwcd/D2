import SwiftDiscord

public class PipeOutput: CommandOutput {
	private let sink: Command
	private let context: CommandContext
	private let args: String
	private let next: CommandOutput?
	
	public init(withSink sink: Command, context: CommandContext, args: String, next: CommandOutput? = nil) {
		self.sink = sink
		self.args = args
		self.context = context
		self.next = next
	}
	
	public func append(_ message: DiscordMessage) {
		print("Piping to \(sink)")
		sink.invoke(withArgs: args, input: message, output: next ?? DiscordChannelOutput(channel: message.channel), context: context)
	}
}