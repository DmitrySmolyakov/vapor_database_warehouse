import Vapor
import FluentMySQL

final class Order: Content {
    static let entity = "orders"
    
    var id: UUID?
    var orderDate: Double
    var arrivalDate: Double
    var deliveryDate: Double
    var deliveryMode: String
    var amount: Int
    var price: Double
    var goodsID: Goods.ID
    var supplierID: Supplier.ID
    var customerID: Customer.ID
    var employeeID: Employee.ID
    
    init(orderDate: Double, arrivalDate: Double,
         deliveryDate: Double, deliveryMode: String,
         amount: Int, price: Double,
         goodsID: Goods.ID, supplierID: Supplier.ID,
         customerID: Customer.ID, employeeID: Employee.ID) {
        self.orderDate = orderDate
        self.arrivalDate = arrivalDate
        self.deliveryDate = deliveryDate
        self.deliveryMode = deliveryMode
        self.amount = amount
        self.price = price
        self.goodsID = goodsID
        self.supplierID = supplierID
        self.customerID = customerID
        self.employeeID = employeeID
    }
}

extension Order: MySQLUUIDModel {}
extension Order: Migration {}
extension Order: Parameter {}
extension Order {
    var goods: Parent<Order, Goods> {
        return parent(\.goodsID)
    }
    
    var supplier: Parent<Order, Supplier> {
        return parent(\.supplierID)
    }
    
    var customer: Parent<Order, Customer> {
        return parent(\.customerID)
    }
    
    var employee: Parent<Order, Employee> {
        return parent(\.employeeID)
    }
}
