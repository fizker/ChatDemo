import { isLoggedIn } from "./auth.mjs"
import { setLoginDisplay } from "./login.mjs"
import { setSignupDisplay } from "./signup.mjs"
import { setChatDisplay } from "./chat.mjs"

const unauthNav = document.querySelector(".unauth-nav")

function showPage(page) {
	unauthNav.classList.toggle("hidden", true)
	setLoginDisplay(false)
	setSignupDisplay(false)
	setChatDisplay(false)

	switch(page) {
	case "login":
		setLoginDisplay(true)
		unauthNav.classList.toggle("hidden", false)
		break
	case "signup":
		setSignupDisplay(true)
		unauthNav.classList.toggle("hidden", false)
		break
	case "chat":
		setChatDisplay(true)
		break
	}
}

function setup() {
	unauthNav.addEventListener("click", (event) => {
		event.preventDefault()
		showPage(event.target.dataset.target)
	})
}

setup()

if(isLoggedIn()) {
	showPage("chat")
} else {
	showPage("login")
}
