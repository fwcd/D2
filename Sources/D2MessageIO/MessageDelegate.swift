public protocol MessageDelegate {
	func on(connect connected: Bool, client: MessageClient)
	
	func on(createMessage message: Message, client: MessageClient)
}