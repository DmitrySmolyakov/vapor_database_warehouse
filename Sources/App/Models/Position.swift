import Vapor
import FluentMySQL

final class Position: Content {
    static let entity = "positions"

    var id: UUID?
    var name: String
    var salary: Double
    var responsibility: String
    var requirements: String
    
    init(name: String, salary: Double, responsibility: String, requirements: String) {
        self.name = name
        self.salary = salary
        self.responsibility = responsibility
        self.requirements = requirements
    }
}

extension Position: MySQLUUIDModel {}
extension Position: Migration {}
extension Position: Parameter {}

extension Position {
    var employees: Children<Position, Employee> {
        return children(\.positionID)
    }
}
