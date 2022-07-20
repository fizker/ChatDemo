import Fluent

struct CreateRoom: AsyncMigration {
	func prepare(on database: Database) async throws {
		try await database.schema("rooms")
			.id()
			.field("name", .string, .required)
			.create()
	}

	func revert(on database: Database) async throws {
		try await database.schema("rooms")
			.delete()
	}
}
