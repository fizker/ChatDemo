import Fluent

struct CreateMessage: AsyncMigration {
	func prepare(on database: Database) async throws {
		try await database.schema("messages")
			.id()
			.field("content", .string, .required)
			.field("created_at", .datetime)
			.field("sender", .uuid, .references("users", "id"))
			.field("room", .uuid, .references("rooms", "id"))
			.create()
	}

	func revert(on database: Database) async throws {
		try await database.schema("messages")
			.delete()
	}
}
