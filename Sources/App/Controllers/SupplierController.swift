import Vapor
import FluentMySQL
import FluentSQL

struct SupplierContent: Content {
    var name: String?
    var address: String?
    var phone: String?
}

final class SupplierController: RouteCollection {
    func boot(router: Router) throws {
        let suppliers = router.grouped("supliers")
        
        suppliers.get(use: index)
        suppliers.get(Supplier.parameter, use: show)
        suppliers.get(Supplier.parameter, "goods", use: goods)
        
        suppliers.post(Supplier.self, use: create)
        suppliers.post(Supplier.parameter, "goods", use: addGoods)
        
        suppliers.patch(SupplierContent.self, at: Supplier.parameter, use: update)
        
        suppliers.delete(Supplier.parameter, use: delete)
        suppliers.delete(Supplier.parameter, "goods", use: removeGoods)
    }
    
    func index(_ request: Request) throws -> Future<[Supplier]> {
        return Supplier.query(on: request).all()
    }
    
    func show(_ request: Request)throws -> Future<Supplier> {
        return try request.parameters.next(Supplier.self)
    }
    
    func goods(_ request: Request)throws -> Future<[Goods]> {
        return try request.parameters.next(Supplier.self).flatMap { supplier in
            return try supplier.goods.query(on: request).all()
        }
    }
    
    func create(_ request: Request, _ supplier: Supplier)throws -> Future<Supplier> {
        return supplier.create(on: request)
    }
    
    func addGoods(_ request: Request)throws -> Future<[Goods]> {
        let supplier = try request.parameters.next(Supplier.self)
        let goodsID = request.content.get(Goods.ID.self, at: "goods")
        let goods = goodsID.and(result: request).flatMap(Goods.find).unwrap(or: Abort(.badRequest, reason: "Unable to find supplier with ID"))
        
        return flatMap(to: (supplier: Supplier, goods: Goods).self, supplier, goods) { supplier, goods in
            return supplier.addGoods(goods: goods, on: request)
            }.map { supplier in
                return [supplier.goods]
        }
    }
    
    func removeGoods(_ request: Request)throws -> Future<HTTPStatus> {
        let supplier = try request.parameters.next(Supplier.self)
        let goodsID = request.content.get(Goods.ID.self, at: "goods")
        let goods = goodsID.and(result: request).flatMap(Goods.find).unwrap(or: Abort(.badRequest, reason: "Unable to find supplier with ID"))

        return flatMap(to: HTTPStatus.self, goods, supplier) { goods, supplier in
            return supplier.removeGoods(goods: goods, on: request).transform(to: .noContent)
        }
    }
    
    func update(_ request: Request, _ body: SupplierContent)throws -> Future<Supplier> {
        let supplier = try request.parameters.next(Supplier.self)
        return supplier.map(to: Supplier.self, { supplier in
            supplier.address = body.address ?? supplier.address
            supplier.name = body.name ?? supplier.name
            supplier.phone = body.phone ?? supplier.phone
            return supplier
        }).update(on: request)
    }
    
    func delete(_ request: Request)throws -> Future<HTTPStatus> {
        return try request.parameters.next(Supplier.self).delete(on: request).transform(to: .noContent)
    }
    
}
