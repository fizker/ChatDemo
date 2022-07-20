import Fluent
import Foundation

final class RoomModel: Model {
	static let schema = "rooms"

	@ID(key: .id)
	var id: UUID?

	@Field(key: "name")
	var name: String

	@Siblings(through: RoomParticipantModel.self, from: \.$room, to: \.$participant)
	var participants: [UserModel]

	@Children(for: \.$room)
	var messages: [MessageModel]

	init() {}

	init(id: UUID? = nil, name: String) {
		self.id = id
		self.name = name
	}
}
