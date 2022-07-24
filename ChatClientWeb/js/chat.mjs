import { isLoggedIn, addAuthHeader } from "./auth.mjs"

const root = document.querySelector(".chat-root")
const roomList = document.querySelector(".rooms__list")
const participantList = document.querySelector(".participants__list")
const messageList = document.querySelector(".messages")
const messageForm = document.querySelector(".message-field")

const data = {
	rooms: null,
	currentRoom: null,
	messages: null,
}

export function setChatDisplay(shouldBeVisible) {
	root.classList.toggle("hidden", !shouldBeVisible)

	if(shouldBeVisible) {
		loadRooms().then(updateRoomList)
	}
}

async function loadRooms() {
	const res = await fetch("/rooms", {
		headers: addAuthHeader(),
	})

	data.rooms = await res.json()
	data.currentRoom = null
	data.messages = null
}

function updateRoomList() {
	roomList.innerHTML = ''
	for(const room of data.rooms.items) {
		const item = document.createElement("li")
		const link = document.createElement("a")
		link.innerHTML = room.name
		link.href = "/rooms/" + room.id
		link.onclick = (event) => {
			event.preventDefault()
			selectRoom(room)
		}
		item.appendChild(link)
		roomList.appendChild(item)
	}
}

async function selectRoom(room) {
	const res = await fetch(`/rooms/${room.id}/messages`, {
		headers: addAuthHeader(),
	})

	data.messages = await res.json()
	data.currentRoom = room
}

function setup() {
	messageForm.onsubmit = (event) => {
		event.preventDefault()
	}
}

setup()
