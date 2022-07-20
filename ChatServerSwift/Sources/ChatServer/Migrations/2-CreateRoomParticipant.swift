import Fluent

struct CreateRoomParticipant: AsyncMigration {
	func prepare(on database: Database) async throws {
		try await database.schema("room_participants")
			.id()
			.field("participant", .uuid, .references("users", "id"))
			.field("room", .uuid, .references("rooms", "id"))
			.create()
	}

	func revert(on database: Database) async throws {
		try await database.schema("room_participants")
			.delete()
	}
}
