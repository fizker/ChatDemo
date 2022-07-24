const root = document.querySelector(".chat-root")

export function setChatDisplay(value) {
	root.classList[value ? "remove" : "add"]("hidden")
}
