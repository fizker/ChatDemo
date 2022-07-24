import { login } from "./auth.mjs"

const title = document.querySelector(".login-title")
const root = document.querySelector(".login-root")
const form = document.querySelector(".login-form")
const error = document.querySelector(".login-form .error")

export function setLoginDisplay(value) {
	title.classList.toggle("hidden", !value)
	root.classList.toggle("hidden", !value)
}

function setup() {
	form.onsubmit = async (event) => {
		event.preventDefault()
		const creds = { username: form.username.value, password: form.password.value }
		if(await login(creds)) {
			location.reload()
		} else {
			error.innerText = "Invalid username or password"
		}
	}
}

setup()
