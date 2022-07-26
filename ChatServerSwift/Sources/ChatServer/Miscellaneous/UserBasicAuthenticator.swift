import Fluent
import Vapor

extension UserModel: Authenticatable {
}

/// An authenticator for HTTP Basic Auth.
struct UserBasicAuthenticator: AsyncBasicAuthenticator {
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
