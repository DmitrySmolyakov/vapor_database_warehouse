import Vapor
import FluentMySQL

final class Supplier: Content {
    static let entity = "suppliers"
    
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

extension Supplier: MySQLUUIDModel {}
extension Supplier: Migration {}
extension Supplier: Parameter {}
extension Supplier {
    var orders: Children<Supplier, Order> {
        return children(\.supplierID)
    }
}
