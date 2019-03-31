import Cairo
import D2Utils

public struct CairoGraphics: Graphics {
	private let context: Cairo.Context
	
	init(surface: Surface) {
		context = Cairo.Context(surface: surface)
	}
	
	public init(fromImage image: Image) {
		self.init(surface: image.surface)
	}
	
	public func save() {
		context.save()
	}
	
	public func restore() {
		context.restore()
	}
	
	public func translate(by offset: Vec2<Double>) {
		context.translate(x: offset.x, y: offset.y)
	}
	
	public func rotate(by angle: Double) {
		context.rotate(angle)
	}
	
	public func draw(line: LineSegment<Double>) {
		context.setSource(color: line.color.asDoubleTuple)
		context.move(to: line.start.asTuple)
		context.line(to: line.end.asTuple)
		context.stroke()
	}
	
	public func draw(rect: Rectangle<Double>) {
		context.setSource(color: rect.color.asDoubleTuple)
		context.addRectangle(x: rect.topLeft.x, y: rect.topLeft.y, width: rect.width, height: rect.height)
		
		if rect.isFilled {
			context.fill()
		} else {
			context.stroke()
		}
	}
	
	public func draw(image: Image, at position: Vec2<Double>, withSize size: Vec2<Int>) {
		let originalWidth = image.width
		let originalHeight = image.height
		
		context.save()
		
		let scaleFactor = Vec2(x: Double(size.x) / Double(originalWidth), y: Double(size.y) / Double(originalHeight))
		context.translate(x: position.x, y: position.y)
		
		if originalWidth != size.x || originalHeight != size.y {
			context.scale(x: scaleFactor.x, y: scaleFactor.y)
		}
		
		context.source = Pattern(surface: image.surface)
		context.paint()
		context.restore()
	}
	
	public func draw(text: Text) {
		context.setSource(color: text.color.asDoubleTuple)
		context.setFont(size: text.fontSize)
		context.move(to: text.position.asTuple)
		context.show(text: text.value)
	}
	
	public func draw(ellipse: Ellipse<Double>) {
		context.save()
		context.setSource(color: ellipse.color.asDoubleTuple)
		context.translate(x: ellipse.center.x, y: ellipse.center.y)
		context.rotate(ellipse.rotation)
		context.scale(x: ellipse.radius.x, y: ellipse.radius.y)
		context.addArc(center: (x: 0.0, y: 0.0), radius: 1.0, angle: (0, 2.0 * Double.pi))
		context.fill()
		context.restore()
	}
}
