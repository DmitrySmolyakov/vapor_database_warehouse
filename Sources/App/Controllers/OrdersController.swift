import Vapor
import FluentMySQL
import FluentSQL

struct OrderContent: Content {
    var orderDate: Double?
    var arrivalDate: Double?
    var deliveryDate: Double?
    var deliveryMode: String?
    var amount: Int?
    var price: Double?
    var goodsID: Goods.ID?
    var supplierID: Supplier.ID?
    var customerID: Customer.ID?
    var employeeID: Employee.ID?
}

struct OredersWithGoods: Content {
    var orders: [Order]
    var goods: [Goods]
}

final class OrderController: RouteCollection {
    func boot(router: Router) throws {
        let orders = router.grouped("orders")
        
        orders.get(use: index)
        orders.get(Order.parameter, use: show)
        
        orders.get("filterprice", use: specialIndex)
        orders.get("filteramount", use: specialFilterAmount)
        orders.get("filterdate", use: specialFilterDate)
        
        let special = router.grouped("sortedOrders")
        special.get(use: specialIndex)
        
        orders.post(Order.self, use: create)
        
        orders.patch(OrderContent.self, at: Order.parameter, use: update)
        
        orders.delete(Order.parameter, use: delete)
    }
    
    func specialIndex(_ request: Request) throws -> Future<OredersWithGoods> {
        let goods = Goods.query(on: request).all()
        let orders = Order.query(on: request).filter(\.price > 50).sort(\.price, .ascending).all()
        
        return map(to: OredersWithGoods.self, orders, goods) { orders, goods in
            OredersWithGoods(orders: orders, goods: goods)
        }
    }
    
    func specialFilterAmount(_ request: Request) throws -> Future<OredersWithGoods> {
        let goods = Goods.query(on: request).all()
        let orders = Order.query(on: request).filter(\.amount > 10).filter(\.amount < 50).sort(\.amount, .ascending).all()
        
        return map(to: OredersWithGoods.self, orders, goods) { orders, goods in
            OredersWithGoods(orders: orders, goods: goods)
        }
    }
    
    func specialFilterDate(_ request: Request) throws -> Future<OredersWithGoods> {
        let goods = Goods.query(on: request).all()
        let orders = Order.query(on: request).filter(\.orderDate >= 1514764800).filter(\.orderDate <= 1546300800).sort(\.orderDate, .ascending).all()
        
        return map(to: OredersWithGoods.self, orders, goods) { orders, goods in
            OredersWithGoods(orders: orders, goods: goods)
        }
    }
    
    func index(_ request: Request) throws -> Future<OredersWithGoods> {
        let goods = Goods.query(on: request).all()
        let orders = Order.query(on: request).all()
        
        return map(to: OredersWithGoods.self, orders, goods) { orders, goods in
            OredersWithGoods(orders: orders, goods: goods)
        }
    }
    
    func show(_ request: Request)throws -> Future<Order> {
        return try request.parameters.next(Order.self)
    }
    
    func create(_ request: Request, _ order: Order)throws -> Future<Order> {
        return order.create(on: request)
    }
    
    func update(_ request: Request, _ body: OrderContent)throws -> Future<Order> {
        let order = try request.parameters.next(Order.self)
        return order.map(to: Order.self, { order in
            order.orderDate = body.orderDate ?? order.orderDate
            order.arrivalDate = body.arrivalDate ?? order.arrivalDate
            order.deliveryDate = body.deliveryDate ?? order.deliveryDate
            order.deliveryMode = body.deliveryMode ?? order.deliveryMode
            order.amount = body.amount ?? order.amount
            order.price = body.price ?? order.price
            order.goodsID = body.goodsID ?? order.goodsID
            order.supplierID = body.supplierID ?? order.supplierID
            order.customerID = body.customerID ?? order.customerID
            order.employeeID = body.employeeID ?? order.employeeID
            return order
        }).update(on: request)
    }
    
    func delete(_ request: Request)throws -> Future<HTTPStatus> {
        return try request.parameters.next(Order.self).delete(on: request).transform(to: .noContent)
    }
}
