import Fluent
import Foundation

final class MessageModel: Model {
	static var schema = "messages"

	@ID(key: .id)
	var id: UUID?

	@Parent(key: "sender")
	var sender: UserModel

	@Parent(key: "room")
	var room: RoomModel

	@Field(key: "content")
	var content: String

	@Timestamp(key: "created_at", on: .create)
	var createdAt: Date?

	init() {}

	init(
		id: UUID? = nil,
		senderID: UUID,
		roomID: UUID,
		content: String,
		createdAt: Date? = nil
	) {
		self.id = id
		self.$sender.id = senderID
		self.$room.id = roomID
		self.content = content
		self.createdAt = createdAt
	}

	init(
		id: UUID? = nil,
		sender: UserModel,
		room: RoomModel,
		content: String,
		createdAt: Date? = nil
	) throws {
		self.id = id
		self.$sender.id = try sender.requireID()
		self.$room.id = try room.requireID()
		self.content = content
		self.createdAt = createdAt
	}
}
