import Vapor

/// An authenticator that picks the Basic Auth token from the query parameters.
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

			let auth = UserBasicAuthenticator()
			try await auth.authenticate(basic: .init(username: username, password: password), for: request)
		}
	}
}
