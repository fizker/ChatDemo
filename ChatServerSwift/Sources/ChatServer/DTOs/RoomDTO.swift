import Foundation

struct RoomDTO: Codable {
	var id: UUID
	var name: String
	var participants: [UserDTO]
	var latestMessage: MessageDTO?
}
