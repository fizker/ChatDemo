import Fluent
import Vapor

extension UserModel: Authenticatable {
}

struct UserAuthenticator: AsyncBasicAuthenticator {
	func authenticate(basic: BasicAuthorization, for request: Request) async throws {
		guard
			let user = try await UserModel.query(on: request.db)
			.filter(\.$username == basic.username)
			.first(),
			try await request.password.async.verify(basic.password, created: user.passwordHash)
		else { return }

		request.auth.login(user)
	}
}

func routes(_ app: Application) throws {
	let userController = UserController()

	let app = app.grouped(UserAuthenticator())

	app.get { req -> String in
		"Hello World"
	}

	app.group("users") { app in
		app.grouped(UserModel.guardMiddleware()).get("self") { req in
			try Content(req.auth.require(UserModel.self).asDTO)
		}

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
