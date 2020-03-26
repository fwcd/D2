import D2MessageIO
import Foundation
import Logging
import D2Utils
import D2Commands
import D2Permissions

fileprivate let log = Logger(label: "D2Handlers.D2Delegate")

/** A client delegate that dispatches commands. */
public class D2Delegate: MessageDelegate {
	private let commandPrefix: String
	private let initialPresence: String?
	private var registry: CommandRegistry
	private var messageHandlers: [MessageHandler]
	
	public init(withPrefix commandPrefix: String, initialPresence: String? = nil) throws {
		self.commandPrefix = commandPrefix
		self.initialPresence = initialPresence
		
		registry = CommandRegistry()
		let spamConfiguration = AutoSerializing<SpamConfiguration>(wrappedValue: .init(), filePath: "local/spamConfig.json")
		let permissionManager = PermissionManager()
		let subscriptionManager = SubscriptionManager()

		messageHandlers = [
			SpamHandler(config: spamConfiguration),
			CommandHandler(commandPrefix: commandPrefix, registry: registry, permissionManager: permissionManager, subscriptionManager: subscriptionManager),
			SubscriptionHandler(commandPrefix: commandPrefix, registry: registry, manager: subscriptionManager)
		]

		registry["ping"] = PingCommand()
		registry["vertical"] = VerticalCommand()
		registry["bf"] = BFCommand()
		registry["bfencode"] = BFEncodeCommand()
		registry["bftoc"] = BFToCCommand()
		registry["echo"] = EchoCommand()
		registry["say"] = SayCommand()
		registry["campus"] = CampusCommand()
		registry["type"] = TriggerTypingCommand()
		registry["mdb"] = MDBCommand()
		registry["timetable"] = TimeTableCommand()
		registry["univis"] = UnivISCommand()
		registry["mensa"] = MensaCommand()
		registry["spieleabend"] = InfoMessageCommand(text: "This command has been migrated to `\(commandPrefix)countdown`")
		registry["countdown"] = CountdownCommand(goals: ["Spieleabend": SpieleabendGoal()])
		registry["reddit"] = RedditCommand()
		registry["grant"] = GrantPermissionCommand(permissionManager: permissionManager)
		registry["revoke"] = RevokePermissionCommand(permissionManager: permissionManager)
		registry["spammerrole"] = SpammerRoleCommand(spamConfiguration: spamConfiguration)
		registry["permissions"] = ShowPermissionsCommand(permissionManager: permissionManager)
		registry["user"] = UserCommand()
		registry["clear"] = ClearCommand()
		registry["logs"] = LogsCommand()
		registry["for"] = ForCommand()
		registry["void"] = VoidCommand()
		registry["quit"] = QuitCommand()
		registry["grep"] = GrepCommand()
		registry["last"] = LastMessageCommand()
		registry["+"] = BinaryOperationCommand<Double>(name: "addition", operation: +)
		registry["-"] = BinaryOperationCommand<Double>(name: "subtraction", operation: -)
		registry["*"] = BinaryOperationCommand<Double>(name: "multiplication", operation: *)
		registry["/"] = BinaryOperationCommand<Double>(name: "division", operation: /)
		registry["%"] = BinaryOperationCommand<Int>(name: "remainder", operation: %)
		registry["rpn"] = EvaluateExpressionCommand(parser: RPNExpressionParser(), name: "Reverse Polish Notation")
		registry["math"] = EvaluateExpressionCommand(parser: InfixExpressionParser(), name: "Infix Notation")
		registry["matmul"] = MatrixMultiplicationCommand()
		registry["maxima"] = MaximaCommand()
		registry["integral"] = IntegralCalculatorCommand()
		registry["portal"] = PortalCommand()
		registry["mcping"] = MinecraftServerPingCommand()
		registry["mcmods"] = MinecraftServerModsCommand()
		registry["mcmod"] = MinecraftModSearchCommand()
        registry["mcdynchat"] = MinecraftDynmapChatCommand()
		registry["mcdynmap"] = MinecraftDynmapCommand()
		registry["mcwiki"] = MinecraftWikiCommand()
		registry["mcstronghold"] = MinecraftStrongholdFinderCommand()
		registry["ftbpacks"] = FTBModpacksCommand()
		registry["wolframalpha"] = WolframAlphaCommand()
		registry["stackoverflow"] = StackOverflowCommand()
		registry["wikipedia"] = WikipediaCommand()
		registry["gitlab"] = GitLabCommand()
		registry["perceptron"] = PerceptronCommand()
		registry["tictactoe"] = GameCommand<TicTacToeGame>()
		registry["uno"] = GameCommand<UnoGame>()
		registry["sourcefile"] = SourceFileCommand()
		registry["urbandict"] = UrbanDictionaryCommand()
		registry["chess"] = GameCommand<ChessGame>()
		registry["cyclethrough"] = CycleThroughCommand()
		registry["demoimage"] = DemoImageCommand()
		registry["demogif"] = DemoGifCommand()
		registry["color"] = ColorCommand()
		registry["mandelbrot"] = MandelbrotCommand()
		registry["invert"] = InvertCommand()
		registry["spin"] = AnimateCommand<SpinAnimation>(description: "Rotates an image")
		registry["twirl"] = AnimateCommand<TransformAnimation<TwirlTransform>>(description: "Applies a twirl distortion effect")
		registry["bump"] = AnimateCommand<TransformAnimation<RadialTransform<BumpDistortion>>>(description: "Applies a bump distortion effect")
		registry["pinch"] = AnimateCommand<TransformAnimation<RadialTransform<PinchDistortion>>>(description: "Applies an inverse bump distortion effect")
		registry["warp"] = AnimateCommand<TransformAnimation<RadialTransform<WarpDistortion>>>(description: "Applies a warp distortion effect")
		registry["squiggle"] = AnimateCommand<TransformAnimation<SquiggleTransform>>(description: "Applies a 'squiggling' distortion effect")
		registry["pingpong"] = PingPongCommand()
		registry["reverse"] = ReverseCommand()
		registry["togif"] = ToGifCommand()
		registry["avatar"] = AvatarCommand()
		registry["qr"] = QRCommand()
		registry["latex"] = LatexCommand()
		registry["autolatex"] = AutoLatexCommand()
		registry["hoogle"] = HoogleCommand()
		registry["haskell"] = HaskellCommand()
		registry["pointfree"] = PointfreeCommand()
		registry["pointful"] = PointfulCommand()
		registry["prolog"] = PrologCommand()
		registry["piglatin"] = PigLatinCommand()
		registry["markov"] = MarkovCommand()
		registry["watch"] = WatchCommand()
		registry["poll"] = PollCommand()
		registry["concat"] = ConcatCommand()
		registry["presence"] = PresenceCommand()
		registry["xkcd"] = XkcdCommand()
		registry["dm"] = DirectMessageCommand()
		registry["tofile"] = ToFileCommand()
		registry["chord"] = FretboardChordCommand()
		registry["web"] = WebCommand()
		registry["stats"] = StatsCommand()
		registry["songcharts"] = SongChartsCommand()
		registry["sortby"] = SortByCommand()
		registry["addscript"] = AddD2ScriptCommand()
		registry["iobackend"] = IOBackendCommand()
		registry["help"] = HelpCommand(commandPrefix: commandPrefix, permissionManager: permissionManager)
	}

	public func on(connect connected: Bool, client: MessageClient) {
		client.setPresence(PresenceUpdate(game: Presence.Activity(name: initialPresence ?? "\(commandPrefix)help", type: .listening)))
	}
	
	public func on(receivePresenceUpdate presence: Presence, client: MessageClient) {
		for (_, command) in registry {
			command.onReceivedUpdated(presence: presence)
		}
	}
	
	public func on(createMessage message: Message, client: MessageClient) {
		for (i, _) in messageHandlers.enumerated() {
			if messageHandlers[i].handle(message: message, from: client) {
				break
			}
		}
	}
}