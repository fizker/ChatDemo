import Vapor

func routes(_ app: Application) throws {
	let userController = UserController()

	app.get { req -> String in
		"Hello World"
	}

	app.group("users") { app in
		app.post("register") { try await Content(userController.registerUser(req: $0)) }
	}
}

struct Content<T: Codable>: Codable, Vapor.Content {
	var item: T

	init(_ item: T) {
		self.item = item
	}

	init(from decoder: Decoder) throws {
		item = try T(from: decoder)
	}

	func encode(to encoder: Encoder) throws {
		try item.encode(to: encoder)
	}
}
