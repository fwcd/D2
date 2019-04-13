enum ExpressionError: Error {
	case invalidOperator(String)
	case tooFewOperands(String)
	case noValueForPlaceholder(String)
	case emptyResult
}