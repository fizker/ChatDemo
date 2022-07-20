import Fluent

let migrations: [() -> Migration] = [
	CreateRoom.init,
	CreateUser.init,
	CreateMessage.init,
	CreateRoomParticipant.init,
]
