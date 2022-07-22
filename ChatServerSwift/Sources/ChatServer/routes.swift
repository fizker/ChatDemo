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
	let roomController = RoomController()
	let userController = UserController()

	let app = app.grouped(UserAuthenticator())

	app.get { req -> Response in
		req.fileio.streamFile(at: "../ChatClientWeb/index.html")
	}
	app.get("styles.css") { req -> Response in
		req.fileio.streamFile(at: "../ChatClientWeb/styles.css")
	}

	app.grouped(UserModel.guardMiddleware()).group("rooms") { app in
		app.get {
			Page(allItems: try await roomController.rooms(req: $0))
		}

		app.post {
			Content(try await roomController.createRoom(req: $0))
		}

		app.group(":room") { app in
			app.get {
				Content(try await roomController.room(
					req: $0,
					roomID: try $0.parameters.require("room")
				))
			}

			app.post("join") {
				Content(try await roomController.joinRoom(
					req: $0,
					roomID: try $0.parameters.require("room")
				))
			}

			app.group("messages") { app in
				app.get { req in
					let roomID = try req.parameters.require("room", as: UUID.self)
					return Content(try await roomController.messages(
						req: req,
						roomID: roomID,
						page: (try? req.query.get(at: "page")) ?? 1,
						urlFactory: { pagination in
							URL(string: "/rooms/\(roomID)/messages?page=\(pagination.page)")!
						}
					))
				}
				app.post {
					Content(try await roomController.postMessage(
						req: $0,
						roomID: try $0.parameters.require("room")
					))
				}
			}
		}
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
