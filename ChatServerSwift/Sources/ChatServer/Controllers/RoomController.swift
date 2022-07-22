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
	let messagePageSize = 50

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

		return try await rooms.asyncMap { try await $0.asDTO(on: req.db) }
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

	func postMessage(req: Request, roomID: UUID) async throws -> MessageDTO {
		let dto = try req.content.decode(MessageUpdateDTO.self)

		let user = try req.auth.require(UserModel.self)

		let message = MessageModel(senderID: try user.requireID(), roomID: roomID, content: dto.content)
		try await message.save(on: req.db)

		return try await message.asDTO(on: req.db)
	}

	func messages(req: Request, roomID: UUID, page: Int, urlFactory: (Pagination) -> URL) async throws -> Page<MessageDTO> {
		guard let room = try await RoomModel.query(on: req.db)
			.filter(\.$id == roomID)
			.first()
		else { throw Abort(.notFound) }

		let messages = try await room.$messages.query(on: req.db)
			.paginate(PageRequest(page: page, per: messagePageSize))

		let dtos = try await messages.items.asyncMap { try await $0.asDTO(on: req.db) }

		return Page(items: dtos, pagination: .init(messages.metadata, urlFactory: urlFactory))
	}
}
