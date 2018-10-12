import Vapor
import FluentMySQL

final class Goods: Content {
    static let entity = "goods"

    var id: UUID?
    var name: String
    var manufacturer: String
    var storageConditions: String
    var package: String
    var expirationDate: Double
    var goodsTypeID: GoodsType.ID
    
    init(name: String, manufacturer: String, storageConditions: String, package: String, expirationDate: Double, goodsTypeID: GoodsType.ID) {
        self.name = name
        self.manufacturer = manufacturer
        self.storageConditions = storageConditions
        self.package = package
        self.expirationDate = expirationDate
        self.goodsTypeID = goodsTypeID
    }
}

extension Goods: MySQLUUIDModel {}
extension Goods: Migration {}
extension Goods: Parameter {}
extension Goods {
    var goodsType: Parent<Goods, GoodsType>? {
        return parent(\.goodsTypeID)
    }
    
    var orders: Children<Goods, Order> {
        return children(\.goodsID)
    }
}
