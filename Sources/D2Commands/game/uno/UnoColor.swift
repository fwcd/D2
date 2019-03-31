import D2Utils

enum UnoColor: String {
	case yellow = "yellow"
	case red = "red"
	case green = "green"
	case blue = "blue"
	
	var color: Color {
		switch self {
			case .yellow: return Colors.yellow
			case .red: return Colors.red
			case .green: return Colors.green
			case .blue: return Colors.blue
		}
	}
}