import Fluent
import ServerSentEventModels
import ServerSentEventVapor
import Vapor

extension UserModel: Authenticatable {
}

struct AuthTokenInQueryAuthenticator: AsyncRequestAuthenticator {
	func authenticate(request: Request) async throws {
		if
			let token = try? request.query.get(String.self, at: "token"),
			let data = Data(base64Encoded: token),
			let values = String(data: data, encoding: .utf8)
		{
			let a = values.components(separatedBy: ":")
			let username = a[0]
			let password = a[1...].joined(separator: ":")

			let auth = UserAuthenticator()
			try await auth.authenticate(basic: .init(username: username, password: password), for: request)
		}
	}
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
	let eventController = ServerSentEventController()
	let roomController = RoomController(eventController: eventController)
	let userController = UserController()

	let app = app.grouped(UserAuthenticator())

	app.get { req -> Response in
		return req.fileio.streamFile(at: "../ChatClientWeb/index.html")
	}
	app.group("js") { app in
		app.get(":file") { req -> Response in
			let file = try req.parameters.require("file")
			if !file.hasSuffix(".mjs") || file.hasPrefix(".") {
				throw Abort(.notFound)
			}

			return req.fileio.streamFile(at: "../ChatClientWeb/js/\(file)")
		}
	}
	app.get("styles.css") { req in
		req.fileio.streamFile(at: "../ChatClientWeb/styles.css")
	}

	app.grouped(AuthTokenInQueryAuthenticator()).grouped(UserModel.guardMiddleware()).get("events") { req -> ServerSentEventResponse in
		let user = try req.auth.require(UserModel.self)
		let id = try user.requireID()
		return eventController.createResponse(id: id)
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
