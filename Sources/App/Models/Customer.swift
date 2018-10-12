import Vapor
import FluentMySQL

final class Customer: Content {
    static let entity = "customers"
    
    var id: UUID?
    var name: String
    var address: String
    var phone: String
    
    init(name: String, address: String, phone: String) {
        self.name = name
        self.address = address
        self.phone = phone
    }
}

extension Customer: MySQLUUIDModel {}
extension Customer: Migration {}
extension Customer: Parameter {}
extension Customer {
    var orders: Children<Customer, Order> {
        return children(\.customerID)
    }
}
