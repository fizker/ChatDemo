import Foundation
import ServerSentEventModels
import ServerSentEventVapor
import Vapor

enum EventType: String {
	case messageSent
	case roomCreated
}

class EventController: ServerSentEventController {
	func emit(_ dto: MessageDTO) throws {
		try emit(dto, type: .messageSent)
	}

	func emit(_ dto: RoomDTO) throws {
		try emit(dto, type: .roomCreated)
	}

	private func emit<T: Encodable>(_ dto: T, type: EventType) throws {
		let encoder = JSONEncoder()
		encoder.dateEncodingStrategy = .iso8601

		let data = try encoder.encode(dto)
		let str = String(data: data, encoding: .utf8)!
		emit(.init(eventType: type.rawValue, data: str))
	}
}
