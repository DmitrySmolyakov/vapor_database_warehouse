import Vapor
import FluentMySQL
import FluentSQL

struct GoodsTypeContent: Content {
    var name: String?
    var description: String?
    var property: String?
}

final class GoodsTypeController: RouteCollection {
    func boot(router: Router) throws {
        let goodsTypes = router.grouped("goodstypes")
        
        goodsTypes.get(use: index)
        goodsTypes.get(GoodsType.parameter, use: show)
        
        let goodsTypeID = goodsTypes.grouped(GoodsType.parameter)
        goodsTypeID.get("goods", use: getGoodTypesGoods)
        
        goodsTypes.post(GoodsType.self, use: create)
        
        goodsTypes.patch(GoodsTypeContent.self, at: GoodsType.parameter, use: update)
        
        goodsTypes.delete(GoodsType.parameter, use: delete)
    }
    
    func index(_ request: Request) throws -> Future<[GoodsType]> {
        let goods = GoodsType.query(on: request).all()
        return goods
    }
    
    func show(_ request: Request)throws -> Future<GoodsType> {
        return try request.parameters.next(GoodsType.self)
    }
    
    func getGoodTypesGoods(_ request: Request) throws -> Future<[Goods]> {
        let goodsType = try request.parameters.next(GoodsType.self)
        return goodsType.flatMap({ (goodsType) -> EventLoopFuture<[Goods]> in
            return try goodsType.goods.query(on: request).all()
        })
    }
    
    func create(_ request: Request, _ goodsTypes: GoodsType)throws -> Future<GoodsType> {
        return goodsTypes.create(on: request)
    }
    
    
    func update(_ request: Request, _ body: GoodsTypeContent)throws -> Future<GoodsType> {
        let goodsType = try request.parameters.next(GoodsType.self)
        return goodsType.map(to: GoodsType.self, { goodsType in
            goodsType.name = body.name ?? goodsType.name
            goodsType.description = body.description ?? goodsType.description
            goodsType.property = body.property ?? goodsType.property
            return goodsType
        }).update(on: request)
    }
    
    func delete(_ request: Request)throws -> Future<HTTPStatus> {
        return try request.parameters.next(GoodsType.self).delete(on: request).transform(to: .noContent)
    }
}
