import Foundation

struct MessageDTO: Codable {
	var id: UUID
	var content: String
	var sender: UserDTO
	var createdAt: Date
}
