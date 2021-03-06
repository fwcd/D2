import Utils
import Graphics

public protocol Animation: KeyParameterizable {
    init(pos: Vec2<Int>?, kvArgs: [Key: String]) throws

    func renderFrame(from image: Image, to frame: Image, percent: Double) throws
}
