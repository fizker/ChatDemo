import Vapor

func routes(_ app: Application) throws {
	app.get { req -> String in
		"Hello World"
	}
}
