import Fluent
import Vapor

extension MessageModel {
	func asDTO(on db: Database) async throws -> MessageDTO {
		MessageDTO(
			id: try requireID(),
			content: content,
			sender: try await $sender.get(on: db).asDTO,
			createdAt: createdAt!
		)
	}
}

extension RoomModel {
	func asDTO(on db: Database) async throws -> RoomDTO {
		RoomDTO(
			id: try requireID(),
			name: name,
			participants: try await $participants.get(on: db).map { try $0.asDTO },
			latestMessage: try await $messages.query(on: db).sort(\.$createdAt).first()?.asDTO(on: db)
		)
	}
}

class RoomController {
	func room(req: Request, roomID: UUID) async throws -> RoomDTO {
		guard let room = try await RoomModel.query(on: req.db)
			.with(\.$participants)
			.filter(\.$id == roomID)
			.first()
		else { throw Abort(.notFound) }

		return try await room.asDTO(on: req.db)
	}

	func rooms(req: Request) async throws -> [RoomDTO] {
		let rooms = try await RoomModel.query(on: req.db)
			.with(\.$participants)
			.all()

		return try await withThrowingTaskGroup(of: RoomDTO.self) {
			for room in rooms {
				$0.addTask {
					try await room.asDTO(on: req.db)
				}
			}

			var results: [RoomDTO] = []
			for try await dto in $0 {
				results.append(dto)
			}
			return results
		}
	}

	func createRoom(req: Request) async throws -> RoomDTO {
		let dto = try req.content.decode(RoomUpdateDTO.self)

		let room = RoomModel(name: dto.name)
		try await room.save(on: req.db)

		let participant = try RoomParticipantModel(room: room, participant: try req.auth.require(UserModel.self))
		try await participant.save(on: req.db)

		return try await room.asDTO(on: req.db)
	}

	func joinRoom(req: Request, roomID: UUID) async throws -> RoomDTO {
		let participant = RoomParticipantModel(
			roomID: roomID,
			participantID: try req.auth.require(UserModel.self).requireID()
		)
		try await participant.save(on: req.db)

		return try await room(req: req, roomID: roomID)
	}
}
