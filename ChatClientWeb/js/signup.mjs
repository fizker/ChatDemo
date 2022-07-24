import { signup } from "./auth.mjs"

const title = document.querySelector(".signup-title")
const root = document.querySelector(".signup-root")
const form = document.querySelector(".signup-form")
const error = document.querySelector(".signup-form .error")

export function setSignupDisplay(value) {
	title.classList.toggle("hidden", !value)
	root.classList.toggle("hidden", !value)
}

function setup() {
	form.onsubmit = async (event) => {
		event.preventDefault()

		const e = await signup(form.name.value, { username: form.username.value, password: form.password.value })
		if(e) {
			error.innerText = e.reason
		} else {
			location.reload()
		}
	}
}

setup()
