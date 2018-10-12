import Vapor
import FluentMySQL

final class GoodsCustomers: MySQLPivot {
    typealias Left = Goods
    typealias Right = Customer
    
    static var leftIDKey: LeftIDKey = \.goodsID
    static var rightIDKey: RightIDKey = \.customerID
    
    var id: Int?
    var goodsID: UUID
    var customerID: UUID
    
    init(left: Goods, right: Customer)throws {
        self.goodsID = try left.requireID()
        self.customerID = try right.requireID()
    }
}

extension GoodsCustomers: Migration {}

extension Goods {
    var customers: Siblings<Goods, Customer, GoodsCustomers> {
        return siblings()
    }
    
    func addCustomer(customer: Customer, on connection: DatabaseConnectable) -> Future<(goods: Goods, customer: Customer)> {
        return Future.flatMap(on: connection) {
            let pivot = try GoodsCustomers(left: self, right: customer)
            return pivot.save(on: connection).transform(to: (self, customer))
        }
    }
    
    func removeCustomer(customer: Customer, on connection: DatabaseConnectable) -> Future<(goods: Goods, customer: Customer)> {
        return self.customers.detach(customer, on: connection).transform(to: (self, customer))
    }
}

extension Customer {
    var goods: Siblings<Customer, Goods, GoodsCustomers> {
        return siblings()
    }
    
    func addGoods(goods: Goods, on connection: DatabaseConnectable) -> Future<(customer: Customer, goods: Goods)> {
        return Future.flatMap(on: connection) {
            let pivot = try GoodsCustomers(left: goods, right: self)
            return pivot.save(on: connection).transform(to: (self, goods))
        }
    }
    
    func removeGoods(goods: Goods, on connection: DatabaseConnectable) -> Future<(customer: Customer, goods: Goods)> {
        return self.goods.detach(goods, on: connection).transform(to: (self, goods))
    }
}
