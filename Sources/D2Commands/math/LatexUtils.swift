func handleLatex(error: Error, output: CommandOutput) {
	if case let LatexError.pdfError(log) = error {
		output.append("A LaTeX PDF error occurred:\n```\n\(extractLatexError(from: log))\n```")
		print("LaTeX PDF error:")
		print(log)
	} else {
		output.append("An asynchronous LaTeX error occurred")
		print("Asynchronous LaTeX error: \(error)")
	}
}

func renderLatexPNG(with renderer: LatexRenderer, from input: String, to output: CommandOutput, then: @escaping () -> Void) {
	do {
		try renderer.renderPNG(from: input, onError: {
			// Catch asynchronous errors
			handleLatex(error: $0, output: output)
			then()
		}) {
			// Render output
			do {
				try output.append($0)
				then()
			} catch {
				output.append("Error while appending image to output")
				print("Error while appending image to output: \(error)")
			}
		}
	} catch {
		handleLatex(error: error, output: output)
	}
}

private func extractLatexError(from log: String) -> String {
	return log.components(separatedBy: "\n")
		.filter { $0.starts(with: "!") }
		.joined(separator: "\n")
		.nilIfEmpty
		?? "Unknown error"
}
