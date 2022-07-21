import Fluent
import Foundation
import Vapor

extension UserModel {
	var asDTO: UserDTO {
		get throws { UserDTO(id: try requireID(), name: name, username: username) }
	}
}

class UserController {
	enum ValidationError: Error {
		case usernameRequired, usernameInUse
		case passwordRequired, nameRequired
	}

	func registerUser(req: Request) async throws -> UserDTO {
		let dto = try req.content.decode(UserUpdateDTO.self)

		guard let name = dto.name
		else { throw ValidationError.nameRequired }

		guard let username = dto.username
		else { throw ValidationError.usernameRequired }

		guard let password = dto.password
		else { throw ValidationError.passwordRequired }

		let existingUser = try await UserModel.query(on: req.db)
			.filter(\UserModel.$username == username)
			.first()
		guard existingUser == nil
		else { throw ValidationError.usernameInUse }

		let user = UserModel(
			username: username,
			passwordHash: try await req.password.async.hash(password),
			name: name
		)

		try await user.save(on: req.db)

		return try user.asDTO
	}
}
