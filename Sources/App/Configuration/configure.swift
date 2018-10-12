import FluentMySQL
import Vapor

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    /// Register providers first
    try services.register(FluentMySQLProvider())

    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    /// middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)

    var databases = DatabasesConfig()
    let database = Environment.get("DATABASE_DB") ?? "vapor"
    let hostname = Environment.get("DATABASE_HOSTNAME") ?? "localhost"
    let username = Environment.get("DATABASE_USER") ?? "vapor"
    let password = Environment.get("DATABASE_PASSWORD") ?? "password"
    let config = MySQLDatabaseConfig(hostname: hostname, username: username, password: password, database: database)
//    let config = MySQLDatabaseConfig(hostname: "localhost", username: "root", password: "", database: "warehouse", transport: MySQLTransportConfig.unverifiedTLS)
    databases.add(database: MySQLDatabase(config: config), as: .mysql)
    services.register(databases)

    /// Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: Employee.self, database: .mysql)
    migrations.add(model: Position.self, database: .mysql)
    migrations.add(model: Goods.self, database: .mysql)
    migrations.add(model: GoodsType.self, database: .mysql)
    migrations.add(model: Supplier.self, database: .mysql)
    migrations.add(model: GoodsSuppliers.self, database: .mysql)
    migrations.add(model: Customer.self, database: .mysql)
    migrations.add(model: GoodsCustomers.self, database: .mysql)
    migrations.add(model: Order.self, database: .mysql)
    services.register(migrations)

//    var commands = CommandConfig.default()
//    commands.useFluentCommands()
//    services.register(commands)
    
    // Configure the rest of your application here
    var commandConfig = CommandConfig.default()
    commandConfig.useFluentCommands()
    services.register(commandConfig)
}
