import Foundation
import D2Utils

public struct UnivISQuery {
	private let url: URL
	
	public init(
		search: UnivISSearchKey,
		params: [UnivISSearchParameter: String],
		scheme: String = "http",
		host: String = "univis.uni-kiel.de",
		path: String = "/prg"
	) throws {
		var components = URLComponents()
		components.scheme = scheme
		components.host = host
		components.path = path
		components.queryItems = [
			URLQueryItem(name: "search", value: search.rawValue),
			URLQueryItem(name: "show", value: "xml")
		] + params.map { URLQueryItem(name: $0.key.rawValue, value: $0.value) }
		
		guard let url = components.url else { throw UnivISError.urlError(components) }
		self.url = url
	}
	
	public func start(then: @escaping (Result<UnivISOutputNode, Error>) -> Void) {
		print("Querying \(url)")
		
		var request = URLRequest(url: url)
		request.httpMethod = "GET"
		URLSession.shared.dataTask(with: request) { data, response, error in
			guard error == nil else {
				then(.failure(UnivISError.httpError(error!)))
				return
			}
			guard let data = data else {
				then(.failure(UnivISError.missingData))
				return
			}
			
			// print("Got \(String(data: data!, encoding: .utf8))")
			
			let delegate = UnivISXMLParserDelegate(then: then)
			let parser = XMLParser(data: data)
			
			parser.delegate = delegate
			_ = parser.parse()
		}.resume()
	}
}