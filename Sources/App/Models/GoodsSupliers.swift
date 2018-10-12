import Vapor
import FluentMySQL

final class GoodsSuppliers: MySQLPivot {
    typealias Left = Goods
    typealias Right = Supplier
    
    static var leftIDKey: LeftIDKey = \.goodsID
    static var rightIDKey: RightIDKey = \.supplierID
    
    var id: Int?
    var goodsID: UUID
    var supplierID: UUID
    
    init(left: Goods, right: Supplier)throws {
        self.goodsID = try left.requireID()
        self.supplierID = try right.requireID()
    }
}

extension GoodsSuppliers: Migration {}

extension Goods {
    var suppliers: Siblings<Goods, Supplier, GoodsSuppliers> {
        return siblings()
    }
    
    func addSupplier(supplier: Supplier, on connection: DatabaseConnectable) -> Future<(goods: Goods, supplier: Supplier)> {
        return Future.flatMap(on: connection) {
            let pivot = try GoodsSuppliers(left: self, right: supplier)
            return pivot.save(on: connection).transform(to: (self, supplier))
        }
    }
    
    func removeSupplier(supplier: Supplier, on connection: DatabaseConnectable) -> Future<(goods: Goods, supplier: Supplier)> {
        return self.suppliers.detach(supplier, on: connection).transform(to: (self, supplier))
    }
}

extension Supplier {
    var goods: Siblings<Supplier, Goods, GoodsSuppliers> {
        return siblings()
    }
    
    func addGoods(goods: Goods, on connection: DatabaseConnectable) -> Future<(supplier: Supplier, goods: Goods)> {
        return Future.flatMap(on: connection) {
            let pivot = try GoodsSuppliers(left: goods, right: self)
            return pivot.save(on: connection).transform(to: (self, goods))
        }
    }
    
    func removeGoods(goods: Goods, on connection: DatabaseConnectable) -> Future<(supplier: Supplier, goods: Goods)> {
        return self.goods.detach(goods, on: connection).transform(to: (self, goods))
    }
}
