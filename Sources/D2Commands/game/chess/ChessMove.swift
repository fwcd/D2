import Utils

public struct ChessMove: Hashable, CustomStringConvertible {
    public var pieceType: ChessPieceType?
    public var color: ChessRole?
    public var originX: Int?
    public var originY: Int?
    public var isCapture: Bool?
    public var destinationX: Int?
    public var destinationY: Int?
    public var promotionPieceType: ChessPieceType?
    public var checkType: CheckType?
    public var isEnPassant: Bool
    public var castlingType: CastlingType?

    // Contains additional moves such as the rook move after castling
    // that should be performed immediately after this move.
    public var associatedMoves: [ChessMove]
    // Other captures, currently only used for en passant
    public var associatedCaptures: [Vec2<Int>]

    public var origin: Vec2<Int>? { return originX.flatMap { x in originY.map { y in Vec2(x: x, y: y) } } }
    public var destination: Vec2<Int>? { return destinationX.flatMap { x in destinationY.map { y in Vec2(x: x, y: y) } } }

    public var isFullyDefined: Bool {
        return pieceType != nil
            && color != nil
            && originX != nil
            && originY != nil
            && isCapture != nil
            && destinationX != nil
            && destinationY != nil
            && promotionPieceType != nil
    }

    public var description: String {
        return StringBuilder()
            .append(color?.rawValue, withSeparator: " ")
            .append(pieceType?.rawValue, withSeparator: " ")
            .append(describePosition(x: originX, y: originY), withSeparator: " ")
            .append(isCapture.map { $0 ? "x" : "-" }, or: " ", withSeparator: " ")
            .append(describePosition(x: destinationX, y: destinationY), withSeparator: " ")
            .append(promotionPieceType.map { "promotion to \($0.rawValue) " }, withSeparator: " ")
            .append(checkType?.rawValue, withSeparator: " ")
            .append(isEnPassant ? "e.p." : "", withSeparator: " ")
            .append(castlingType.map { "castling \($0.rawValue) " }, withSeparator: " ")
            .trimmedValue
    }

    public init(
        pieceType: ChessPieceType? = nil,
        color: ChessRole? = nil,
        originX: Int? = nil,
        originY: Int? = nil,
        isCapture: Bool? = nil,
        destinationX: Int? = nil,
        destinationY: Int? = nil,
        promotionPieceType: ChessPieceType? = nil,
        checkType: CheckType? = nil,
        isEnPassant: Bool = false,
        castlingType: CastlingType? = nil,
        associatedMoves: [ChessMove] = [],
        associatedCaptures: [Vec2<Int>] = []
    ) {
        self.pieceType = pieceType
        self.color = color
        self.originX = originX
        self.originY = originY
        self.isCapture = isCapture
        self.destinationX = destinationX
        self.destinationY = destinationY
        self.promotionPieceType = promotionPieceType
        self.checkType = checkType
        self.isEnPassant = isEnPassant
        self.castlingType = castlingType
        self.associatedMoves = associatedMoves
        self.associatedCaptures = associatedCaptures
    }

    private func describePosition(x optionalX: Int?, y optionalY: Int?) -> String {
        return (optionalX.flatMap { fileOf(x: $0).map { String($0) } } ?? "")
            + (optionalY.map { String(rankOf(y: $0)) } ?? "")
    }

    func matches(_ move: ChessMove) -> Bool {
        return (pieceType == nil || move.pieceType == nil || pieceType == move.pieceType)
            && (color == nil || move.color == nil || color == move.color)
            && (originX == nil || move.originX == nil || originX == move.originX)
            && (originY == nil || move.originY == nil || originY == move.originY)
            && (isCapture == nil || move.isCapture == nil || isCapture == move.isCapture)
            && (destinationX == nil || move.destinationX == nil || destinationX == move.destinationX)
            && (destinationY == nil || move.destinationY == nil || destinationY == move.destinationY)
            && (promotionPieceType == nil || move.promotionPieceType == nil || promotionPieceType == move.promotionPieceType)
            && (checkType == nil || move.checkType == nil || checkType == move.checkType)
            && (castlingType == move.castlingType)
    }
}
