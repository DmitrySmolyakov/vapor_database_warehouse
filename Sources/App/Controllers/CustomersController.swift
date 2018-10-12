import Vapor
import FluentMySQL
import FluentSQL

struct CustomerContent: Content {
    var name: String?
    var address: String?
    var phone: String?
}

final class CustomerController: RouteCollection {
    func boot(router: Router) throws {
        let customers = router.grouped("customers")
        
        customers.get(use: index)
        customers.get(Customer.parameter, use: show)
        customers.get(Customer.parameter, "goods", use: goods)
        
        customers.post(Customer.self, use: create)
        customers.post(Customer.parameter, "goods", use: addGoods)
        
        customers.patch(CustomerContent.self, at: Customer.parameter, use: update)
        
        customers.delete(Customer.parameter, use: delete)
        customers.delete(Customer.parameter, "goods", use: removeGoods)
    }
    
    func index(_ request: Request) throws -> Future<[Customer]> {
        return Customer.query(on: request).all()
    }
    
    func show(_ request: Request)throws -> Future<Customer> {
        return try request.parameters.next(Customer.self)
    }
    
    func goods(_ request: Request)throws -> Future<[Goods]> {
        return try request.parameters.next(Customer.self).flatMap { customer in
            return try customer.goods.query(on: request).all()
        }
    }
    
    func create(_ request: Request, _ customer: Customer)throws -> Future<Customer> {
        return customer.create(on: request)
    }
    
    func addGoods(_ request: Request)throws -> Future<[Goods]> {
        let customer = try request.parameters.next(Customer.self)
        let goodsID = request.content.get(Goods.ID.self, at: "goods")
        let goods = goodsID.and(result: request).flatMap(Goods.find).unwrap(or: Abort(.badRequest, reason: "Unable to find supplier with ID"))

        return flatMap(to: (customer: Customer, goods: Goods).self, customer, goods) { customer, goods in
            return customer.addGoods(goods: goods, on: request)
            }.map { customer in
                return [customer.goods]
        }
    }
    
    func removeGoods(_ request: Request)throws -> Future<HTTPStatus> {
        let customer = try request.parameters.next(Customer.self)
        let goodsID = request.content.get(Goods.ID.self, at: "goods")
        let goods = goodsID.and(result: request).flatMap(Goods.find).unwrap(or: Abort(.badRequest, reason: "Unable to find supplier with ID"))

        return flatMap(to: HTTPStatus.self, goods, customer) { goods, customer in
            return customer.removeGoods(goods: goods, on: request).transform(to: .noContent)
        }
    }
    
    func update(_ request: Request, _ body: CustomerContent)throws -> Future<Customer> {
        let customer = try request.parameters.next(Customer.self)
        return customer.map(to: Customer.self, { customer in
            customer.address = body.address ?? customer.address
            customer.name = body.name ?? customer.name
            customer.phone = body.phone ?? customer.phone
            return customer
        }).update(on: request)
    }
    
    func delete(_ request: Request)throws -> Future<HTTPStatus> {
        return try request.parameters.next(Customer.self).delete(on: request).transform(to: .noContent)
    }
}
