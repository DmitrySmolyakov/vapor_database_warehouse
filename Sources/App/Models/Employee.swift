import Vapor
import FluentMySQL

final class Employee: Content {
    static let entity = "employees"
    
    var id: UUID?
    var fullName: String
    var age: Int
    var gender: Int
    var address: String
    var phoneNumber: String
    var passportData: String
    var positionID: Position.ID?
    
    init(fullName: String, age: Int, gender: Int, address: String, phoneNumber: String, passportData: String, positionID: Position.ID) {
        self.fullName = fullName
        self.age = age
        self.gender = gender
        self.address = address
        self.phoneNumber = phoneNumber
        self.passportData = passportData
        self.positionID = positionID
    }
}

extension Employee: MySQLUUIDModel {}
extension Employee: Migration {}
extension Employee: Parameter {}
extension Employee {
    var position: Parent<Employee, Position>? {
        return parent(\.positionID)
    }
    
    var orders: Children<Employee, Order> {
        return children(\.employeeID)
    }
}
