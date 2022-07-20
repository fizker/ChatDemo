import Foundation
import Fluent

final class RoomParticipantModel: Model {
	static var schema = "room_participants"

	@ID(key: .id)
	var id: UUID?

	@Parent(key: "room")
	var room: RoomModel

	@Parent(key: "participant")
	var participant: UserModel

	init() {}

	init(id: UUID? = nil, roomID: UUID, participantID: UUID) {
		self.id = id
		self.$room.id = roomID
		self.$participant.id = participantID
	}

	init(id: UUID? = nil, room: RoomModel, participant: UserModel) throws {
		self.id = id
		self.$room.id = try room.requireID()
		self.$participant.id = try participant.requireID()
	}
}
