import Fluent
import Foundation

final class UserModel: Model {
	static var schema = "users"

	@ID(key: .id)
	var id: UUID?

	@Field(key: "username")
	var username: String

	@Field(key: "password_hash")
	var passwordHash: String

	@Field(key: "name")
	var name: String

	@Children(for: \.$sender)
	var sentMessages: [MessageModel]

	@Siblings(through: RoomParticipantModel.self, from: \.$participant, to: \.$room)
	var rooms: [RoomModel]

	init() {}

	init(id: UUID? = nil, username: String, passwordHash: String, name: String) {
		self.id = id
		self.username = username
		self.passwordHash = passwordHash
		self.name = name
	}
}
