import D2MessageIO
import SwiftDiscord

// FROM Discord conversions

extension DiscordPresence {
	var usingMessageIO: Presence {
		return Presence(
			guildId: guildId.usingMessageIO,
			user: user.usingMessageIO,
			game: game?.usingMessageIO,
			nick: nick,
			roles: roles,
			status: status?.usingMessageIO
		)
	}
}

// TO Discord conversions

extension PresenceUpdate {
	var usingDiscordAPI: DiscordPresenceUpdate {
		return DiscordPresenceUpdate(
			game: game?.usingDiscordAPI,
			status: status.usingDiscordAPI,
			afkSince: afkSince
		)
	}
}

extension Presence.Status {
	var usingDiscordAPI: DiscordPresenceStatus {
		switch self {
			case .idle: return .idle
			case .offline: return .offline
			case .online: return .online
			case .doNotDisturb: return .doNotDisturb
		}
	}
}

extension Presence.Activity {
	var usingDiscordAPI: DiscordActivity {
		return DiscordActivity(name: name, type: type.usingDiscordAPI)
	}
}

extension Presence.Activity.ActivityType {
	var usingDiscordAPI: DiscordActivityType {
		switch self {
			case .game: return .game
			case .stream: return .stream
			case .listening: return .listening
		}
	}
}