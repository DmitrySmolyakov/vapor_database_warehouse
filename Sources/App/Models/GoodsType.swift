import Vapor
import FluentMySQL

final class GoodsType: Content {
    static let entity = "goodstypes"
    
    var id: UUID?
    var name: String
    var description: String
    var property: String
    
    init(name: String, description: String, property: String) {
        self.name = name
        self.description = description
        self.property = property
    }
}

extension GoodsType: MySQLUUIDModel {}
extension GoodsType: Migration {}
extension GoodsType: Parameter {}
extension GoodsType {
    var goods: Children<GoodsType, Goods> {
        return children(\.goodsTypeID)
    }
}
