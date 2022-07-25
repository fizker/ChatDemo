import { isLoggedIn, addAuthHeader } from "./auth.mjs"

const root = document.querySelector(".chat-root")
const roomList = document.querySelector(".rooms__list")
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

		const selectedRoom = sessionStorage.getItem("room")
		if(selectedRoom) {
			const room = JSON.parse(selectedRoom)
			selectRoom(room)
		}
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
	roomList.innerHTML = ""
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
	sessionStorage.setItem("room", JSON.stringify(room))

	const res = await fetch(`/rooms/${room.id}/messages`, {
		headers: addAuthHeader(),
	})

	data.messages = await res.json()
	data.currentRoom = room

	updateMessageList()
}

function updateMessageList() {
	messageList.innerHTML = ""
	for(const message of data.messages.items) {
		const item = document.createElement("div")
		item.className = "message"
		item.innerHTML = `
			<div class="message__sender">${message.sender.name}</div>
			<div class="message__timestamp">${formatDate(message.createdAt)}</div>
			<div class="message__content">${message.content}</div>
		`
		messageList.appendChild(item)
	}
}

function setup() {
	messageForm.onsubmit = (event) => {
		event.preventDefault()
	}
}

function formatDate(date) {
	return date.toString()
}

setup()
