export class AuthError extends Error {
}

export function addAuthHeader(headers = {}) {
	const credentials = sessionStorage.getItem("auth")
	if(credentials == null) {
		throw new AuthError()
	}

	return authHeader(JSON.parse(credentials), headers)
}

export function getAuthToken() {
	const credentials = sessionStorage.getItem("auth")
	if(credentials == null) {
		throw new AuthError()
	}

	return authToken(JSON.parse(credentials))
}

function authToken({ username, password }) {
	return btoa(`${username}:${password}`)
}

function authHeader(credentials, headers = {}) {
	headers["Authorization"] = `Basic ${authToken(credentials)}`
	return headers
}

export function isLoggedIn() {
	const credentials = sessionStorage.getItem("auth")
	return credentials != null
}

export async function signup(name, credentials) {
	const body = {
		...credentials,
		name,
	}

	const res = await fetch("/users/register", {
		body: JSON.stringify(body),
		headers: { "content-type": "application/json" },
		method: "post",
	})

	if(res.status < 400) {
		sessionStorage.setItem("auth", JSON.stringify(credentials))
		return null
	} else {
		return await res.json()
	}
}

export async function login(credentials) {
	const res = await fetch("/users/self", {
		headers: authHeader(credentials),
	})

	if(res.status < 400) {
		sessionStorage.setItem("auth", JSON.stringify(credentials))
		return true
	} else {
		return false
	}
}

export function logout() {
	sessionStorage.removeItem("auth")
}
