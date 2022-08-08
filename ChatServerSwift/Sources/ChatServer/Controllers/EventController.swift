import Foundation
import ServerSentEventModels
import ServerSentEventVapor
import Vapor

typealias EventController = ServerSentEventController

enum EventType: String {
	case messageSent
	case roomCreated
}

extension ServerSentEventController {
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
		try emit(.init(eventType: type, data: data))
	}
}

extension MessageEvent {
	init(
		eventType: EventType,
		data: Data
	) throws {
		self.init(eventType: eventType.rawValue)
		try encodeData(data, encoding: .utf8)
	}
}

extension MessageEvent {
	enum DataEncodingStrategy {
		case base64
		case utf8
	}

	enum DecodingError: Error {
		case invalidEncoding
	}

	enum EncodingError: Error {
		case invalidEncoding
	}

	init(
		id: String? = nil,
		lastEventID: String? = nil,
		eventType: String? = nil,
		retry: Int? = nil,
		comments: [String] = [],
		data: Data,
		dataEncoding: DataEncodingStrategy
	) throws {
		self.init(id: id, lastEventID: lastEventID, eventType: eventType, retry: retry, comments: comments)
		try encodeData(data, encoding: dataEncoding)
	}

	func decodeData(encoding: DataEncodingStrategy) throws -> Data {
		let data: Data?
		switch encoding {
		case .base64:
			data = Data(base32Encoded: self.data)
		case .utf8:
			data = self.data.data(using: .utf8)
		}

		guard let data
		else { throw DecodingError.invalidEncoding }

		return data
	}

	mutating func encodeData(_ data: Data, encoding: DataEncodingStrategy) throws {
		switch encoding {
		case .base64:
			self.data = data.base32EncodedString()
		case .utf8:
			guard let s = String(data: data, encoding: .utf8)
			else { throw EncodingError.invalidEncoding }
			self.data = s
		}
	}
}
