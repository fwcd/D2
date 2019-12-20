import D2MessageIO
import SwiftDiscord
import Foundation

// TO Discord conversions

extension Embed: DiscordAPIConvertible {
	public var usingDiscordAPI: Embed {
		return Embed(
			title: title,
			description: description,
			author: author?.usingDiscordAPI,
			url: url,
			image: image?.usingDiscordAPI,
			timestamp: timestamp,
			thumbnail: thumbnail?.usingDiscordAPI,
			color: color,
			footer: footer?.usingDiscordAPI,
			fields: fields.usingDiscordAPI
		)
	}
}

extension Embed.Author: DiscordAPIConvertible {
	public var usingDiscordAPI: Embed.Author {
		return Embed.Author(
			name: name,
			iconUrl: iconUrl,
			url: url
		)
	}
}

extension Embed.Thumbnail: DiscordAPIConvertible {
	public var usingDiscordAPI: Embed.Thumbnail {
		return Embed.Thumbnail(url: url)
	}
}

extension Embed.Image: DiscordAPIConvertible {
	public var usingDiscordAPI: Embed.Image {
		return Embed.Image(url: url)
	}
}

extension Embed.Footer: DiscordAPIConvertible {
	public var usingDiscordAPI: Embed.Footer {
		return Embed.Footer(text: text)
	}
}

extension Embed.Field: DiscordAPIConvertible {
	public var usingDiscordAPI: Embed.Field {
		return Embed.Field(name: name, value: value, inline: inline)
	}
}

// FROM Discord conversions

extension Embed: MessageIOConvertible {
	public var usingMessageIO: Embed {
		return Embed(
			title: title,
			description: description,
			author: author?.usingMessageIO,
			url: url,
			image: image?.usingMessageIO,
			timestamp: timestamp,
			thumbnail: thumbnail?.usingMessageIO,
			color: color,
			footer: footer?.usingMessageIO,
			fields: fields.usingMessageIO
		)
	}
}

extension Embed.Author: MessageIOConvertible {
	public var usingMessageIO: Embed.Author {
		return Embed.Author(
			name: name,
			iconUrl: iconUrl,
			url: url
		)
	}
}

extension Embed.Thumbnail: MessageIOConvertible {
	public var usingMessageIO: Embed.Thumbnail {
		return Embed.Thumbnail(url: url)
	}
}

extension Embed.Image: MessageIOConvertible {
	public var usingMessageIO: Embed.Image {
		return Embed.Image(url: url)
	}
}

extension Embed.Footer: MessageIOConvertible {
	public var usingMessageIO: Embed.Footer {
		return Embed.Footer(text: text)
	}
}

extension Embed.Field: MessageIOConvertible {
	public var usingMessageIO: Embed.Field {
		return Embed.Field(name: name, value: value, inline: inline)
	}
}
