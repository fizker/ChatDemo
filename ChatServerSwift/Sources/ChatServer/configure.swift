import Fluent
import FluentSQLiteDriver
import Vapor

func configure(_ app: Application) throws {
	app.databases.use(.sqlite(.memory), as: .sqlite)
	app.passwords.use(.bcrypt)

	for migration in migrations {
		app.migrations.add(migration())
	}

	try app.autoMigrate().wait()

	try routes(app)
}
