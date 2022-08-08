import Foundation

struct MessageDTO: Codable {
	var id: UUID
	var content: String
	var roomID: UUID
	var sender: UserDTO
	var createdAt: Date
}
