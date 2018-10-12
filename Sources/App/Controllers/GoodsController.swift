import Vapor
import FluentMySQL
import FluentSQL

struct GoodsContent: Content {
    var name: String?
    var manufacturer: String?
    var storageConditions: String?
    var package: String?
    var expirationDate: Double?
    var goodsTypeID: GoodsType.ID?
}

struct GoodsWithTypes: Content {
    var goods: [Goods]?
    var goodsTypes: [GoodsType]?
}

final class GoodsController: RouteCollection {
    func boot(router: Router) throws {
        let goods = router.grouped("goods")
        
        goods.get(use: index)
        goods.get(Goods.parameter, use: show)
        goods.get(Goods.parameter, "suppliers", use: suppliers)
        goods.get(Goods.parameter, "customers", use: customers)
        
        goods.post(Goods.self, use: create)
        goods.post(Goods.parameter, "supplier", use: addSupplier)
        goods.post(Goods.parameter, "customer", use: addCustomer)
        
        goods.get("ascending", use: indexSortedAscending)
        goods.get("descending", use: indexSortedDescending)
        
        goods.patch(GoodsContent.self, at: Goods.parameter, use: update)
        
        goods.delete(Goods.parameter, use: delete)
        goods.delete(Goods.parameter, "supplier", use: removeSupplier)
        goods.delete(Goods.parameter, "customer", use: removeCustomer)
    }
    
    func indexSortedAscending(_ request: Request) throws -> Future<GoodsWithTypes> {
        let goods = Goods.query(on: request).sort(\.name, .ascending).all()
        let goodsTypes = GoodsType.query(on: request).all()
        
        return map(to: GoodsWithTypes.self, goods, goodsTypes) { goods, goodsTypes in
            GoodsWithTypes(goods: goods, goodsTypes: goodsTypes)
        }
    }
    
    func indexSortedDescending(_ request: Request) throws -> Future<GoodsWithTypes> {
        let goods = Goods.query(on: request).sort(\.name, .descending).all()
        let goodsTypes = GoodsType.query(on: request).all()
        
        return map(to: GoodsWithTypes.self, goods, goodsTypes) { goods, goodsTypes in
            GoodsWithTypes(goods: goods, goodsTypes: goodsTypes)
        }
    }
    
    func index(_ request: Request) throws -> Future<GoodsWithTypes> {
        let goods = Goods.query(on: request).all()
        let goodsTypes = GoodsType.query(on: request).all()

        return map(to: GoodsWithTypes.self, goods, goodsTypes) { goods, goodsTypes in
            GoodsWithTypes(goods: goods, goodsTypes: goodsTypes)
        }
    }
    
    func show(_ request: Request)throws -> Future<Goods> {
        return try request.parameters.next(Goods.self)
    }
    
    func create(_ request: Request, _ goods: Goods)throws -> Future<Goods> {
        return goods.create(on: request)
    }
    
    func addSupplier(_ request: Request)throws -> Future<[Supplier]> {
        let goods = try request.parameters.next(Goods.self)
        let supplierID = request.content.get(Supplier.ID.self, at: "supplier")
        let supplier = supplierID.and(result: request).flatMap(Supplier.find).unwrap(or: Abort(.badRequest, reason: "Unable to find supplier with ID"))
        
        return flatMap(to: (goods: Goods, supplier: Supplier).self, goods, supplier) { goods, supplier in
            return goods.addSupplier(supplier: supplier, on: request)
            }.map { goods in
                return [goods.supplier]
        }
    }
    
    func addCustomer(_ request: Request)throws -> Future<[Customer]> {
        let goods = try request.parameters.next(Goods.self)
        let customerID = request.content.get(Customer.ID.self, at: "customer")
        let customer = customerID.and(result: request).flatMap(Customer.find).unwrap(or: Abort(.badRequest, reason: "Unable to find supplier with ID"))
        
        return flatMap(to: (goods: Goods, customer: Customer).self, goods, customer) { goods, customer in
            return goods.addCustomer(customer: customer, on: request)
            }.map { goods in
                return [goods.customer]
        }
    }
    
    func removeSupplier(_ request: Request)throws -> Future<HTTPStatus> {
        let goods = try request.parameters.next(Goods.self)
        let supplierID = request.content.get(Supplier.ID.self, at: "supplier")
        let supplier = supplierID.and(result: request).flatMap(Supplier.find).unwrap(or: Abort(.badRequest, reason: "Unable to find supplier with ID"))
        
        return flatMap(to: HTTPStatus.self, goods, supplier) { goods, supplier in
            return goods.removeSupplier(supplier: supplier, on: request).transform(to: .noContent)
        }
    }
    
    func removeCustomer(_ request: Request)throws -> Future<HTTPStatus> {
        let goods = try request.parameters.next(Goods.self)
        let customerID = request.content.get(Customer.ID.self, at: "customer")
        let customer = customerID.and(result: request).flatMap(Customer.find).unwrap(or: Abort(.badRequest, reason: "Unable to find supplier with ID"))
        
        return flatMap(to: HTTPStatus.self, goods, customer) { goods, customer in
            return goods.removeCustomer(customer: customer, on: request).transform(to: .noContent)
        }
    }
    
    func update(_ request: Request, _ body: GoodsContent)throws -> Future<Goods> {
        let goods = try request.parameters.next(Goods.self)
        return goods.map(to: Goods.self, { goods in
            goods.name = body.name ?? goods.name
            goods.manufacturer = body.manufacturer ?? goods.manufacturer
            goods.storageConditions = body.storageConditions ?? goods.storageConditions
            goods.package = body.package ?? goods.package
            goods.expirationDate = body.expirationDate ?? goods.expirationDate
            goods.goodsTypeID = body.goodsTypeID ?? goods.goodsTypeID
            return goods
        }).update(on: request)
    }
    
    func delete(_ request: Request)throws -> Future<HTTPStatus> {
        return try request.parameters.next(Goods.self).delete(on: request).transform(to: .noContent)
    }
    
    func suppliers(_ request: Request)throws -> Future<[Supplier]> {
        return try request.parameters.next(Goods.self).flatMap { goods in
            return try goods.suppliers.query(on: request).all()
        }
    }
    
    func customers(_ request: Request)throws -> Future<[Customer]> {
        return try request.parameters.next(Goods.self).flatMap { goods in
            return try goods.customers.query(on: request).all()
        }
    }
}
