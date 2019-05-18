import D2Utils

fileprivate let operators: [String] = ["=", "+", "-", "*", "/", "^"]
fileprivate let keywords: [String] = ["command", "if", "else", "for", "while"]

fileprivate let rawKeywordPattern = keywords
	.map { "(?:\(Regex.escape($0)))" }
	.joined(separator: "|")
fileprivate let rawOperatorPattern = operators
	.map { "(?:\(Regex.escape($0)))" }
	.joined(separator: "|")

/**
 * Matches a single token.
 * 1.  capture group: a number literal
 * 2.  capture group: an opening parenthesis
 * 3.  capture group: a closing parenthesis
 * 4.  capture group: an opening curly bracket
 * 5.  capture group: a closing curly bracket
 * 6.  capture group: a comma
 * 7.  capture group: a line break
 * 8.  capture group: an operator
 * 9.  capture group: a keyword
 * 10. & 11.   group: a string literal (first part matches the string in quotes, second part matches the content)
 * 12. capture group: an identifier
 */
fileprivate let tokenPattern = try! Regex(from: "(\\d+(?:\\.\\d+)?)|(\\()|(\\))|(\\{)|(\\})|(,)|([\\r\\n]+)|(\(rawOperatorPattern))|(\(rawKeywordPattern))|(\"([^\"]*)\")|([a-zA-Z]+)")

public struct D2ScriptParser {
	public func parse(_ input: String) throws -> D2Script {
		return try parse(tokens: try tokenize(input))
	}
	
	func tokenize(_ input: String) throws -> [D2ScriptToken] {
		return try tokenPattern.allGroups(in: input)
			.map {
				if let numberLiteral = $0[1].nilIfEmpty {
					guard let value = Double(numberLiteral) else { throw D2ScriptError.numberFormatError(numberLiteral) }
					return .numberLiteral(value)
				} else if !$0[2].isEmpty {
					return .leftParenthesis
				} else if !$0[3].isEmpty {
					return .rightParenthesis
				} else if !$0[4].isEmpty {
					return .leftCurlyBracket
				} else if !$0[5].isEmpty {
					return .rightCurlyBracket
				} else if !$0[6].isEmpty {
					return .comma
				} else if !$0[7].isEmpty {
					return .linebreak
				} else if let rawOperator = $0[8].nilIfEmpty {
					return .anyOperator(rawOperator)
				} else if let keyword = $0[9].nilIfEmpty {
					return .keyword(keyword)
				} else if !$0[10].isEmpty {
					return .stringLiteral($0[11])
				} else if let identifier = $0[12].nilIfEmpty {
					return .identifier(identifier)
				} else {
					throw D2ScriptError.unrecognizedToken($0[0])
				}
			}
	}
	
	private func parse(tokens: [D2ScriptToken]) throws -> D2Script {
		return try parseScript(from: TokenIterator(tokens))
	}
	
	// Recursive descent parsing methods for the production rules of D2Script
	
	private func parseScript(from tokens: TokenIterator<D2ScriptToken>) throws -> D2Script {
		guard let commandDeclaration = try parseCommandDeclaration(from: tokens) else {
			throw D2ScriptError.syntaxError("No top-level command declaration")
		}
		return D2Script(topLevelNodes: [commandDeclaration])
	}
	
	private func parseCommandDeclaration(from tokens: TokenIterator<D2ScriptToken>) throws -> D2ScriptCommandDeclaration? {
		guard case let .keyword(commandKeyword)? = tokens.peek() else { return nil }
		guard commandKeyword == "command" else { return nil }
		tokens.next()
		guard case let .identifier(commandName)? = tokens.next() else { throw D2ScriptError.syntaxError("Command declaration requires identifier after the keyword") }
		guard tokens.next() == .leftCurlyBracket else { throw D2ScriptError.syntaxError("Command declaration needs opening bracket: {") }
		if tokens.peek() == .linebreak {
			tokens.next()
		}
		guard let statementList = try parseStatementList(from: tokens) else { throw D2ScriptError.syntaxError("Command declaration should contain statement list") }
		guard tokens.next() == .rightCurlyBracket else { throw D2ScriptError.syntaxError("Command declaration needs closing bracket: {") }
		return D2ScriptCommandDeclaration()
	}
	
	private func parseStatementList(from tokens: TokenIterator<D2ScriptToken>) throws -> D2ScriptStatementList? {
		var statements = [D2ScriptStatement]()
		while let statement = try parseStatement(from: tokens) {
			statements.append(statement)
			if tokens.peek() == .linebreak {
				tokens.next()
			}
		}
		return D2ScriptStatementList(statements: statements)
	}
	
	private func parseStatement(from tokens: TokenIterator<D2ScriptToken>) throws -> D2ScriptStatement? {
		return try parseExpressionStatement(from: tokens) ?? parseAssignment(from: tokens)
	}
	
	private func parseExpressionStatement(from tokens: TokenIterator<D2ScriptToken>) throws -> D2ScriptExpressionStatement? {
		guard let expression = try parseExpression(from: tokens) else { return nil }
		return D2ScriptExpressionStatement(expression: expression)
	}
	
	private func parseAssignment(from tokens: TokenIterator<D2ScriptToken>) throws -> D2ScriptAssignment? {
		guard case let .identifier(identifier)? = tokens.peek(1) else { return nil }
		guard case let .anyOperator(assignmentOperator)? = tokens.peek(2) else { return nil }
		guard assignmentOperator == "=" else { return nil }
		tokens.next()
		tokens.next()
		guard let expression = try parseExpression(from: tokens) else { return nil }
		return D2ScriptAssignment(identifier: identifier, expression: expression)
	}
	
	private func parseExpression(from tokens: TokenIterator<D2ScriptToken>) throws -> D2ScriptExpression? {
		if case let .stringLiteral(literal)? = tokens.peek() {
			tokens.next()
			return D2ScriptValue.string(literal)
		} else if case let .numberLiteral(literal)? = tokens.peek() {
			tokens.next()
			return D2ScriptValue.number(literal)
		} else {
			return try parseFunctionCall(from: tokens)
		}
	}
	
	private func parseFunctionCall(from tokens: TokenIterator<D2ScriptToken>) throws -> D2ScriptFunctionCall? {
		guard case let .identifier(functionName)? = tokens.peek(1) else { return nil }
		guard tokens.peek(2) == .leftParenthesis else { return nil }
		tokens.next()
		tokens.next()
		let args = try parseFunctionArgs(from: tokens)
		guard tokens.next() == .rightParenthesis else { throw D2ScriptError.syntaxError("Function call needs to end with a closing parenthesis") }
		return D2ScriptFunctionCall(functionName: functionName, arguments: args)
	}
	
	private func parseFunctionArgs(from tokens: TokenIterator<D2ScriptToken>) throws -> [D2ScriptExpression] {
		var expressions = [D2ScriptExpression]()
		while let expression = try parseExpressionWithComma(from: tokens) {
			expressions.append(expression)
		}
		if let expression = try parseExpression(from: tokens) {
			expressions.append(expression)
		}
		return expressions
	}
	
	private func parseExpressionWithComma(from tokens: TokenIterator<D2ScriptToken>) throws -> D2ScriptExpression? {
		guard let expression = try parseExpression(from: tokens) else { return nil }
		guard tokens.peek() == .comma else { return nil }
		return expression
	}
}