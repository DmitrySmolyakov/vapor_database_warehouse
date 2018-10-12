import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    try router.register(collection: EmployesController())
    try router.register(collection: PositionController())
    try router.register(collection: GoodsController())
    try router.register(collection: GoodsTypeController())
    try router.register(collection: SupplierController())
    try router.register(collection: CustomerController())
    try router.register(collection: OrderController())
    
    // Basic "It works" example
    router.get { req in
        return "It works!"
    }
    
    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "Hello, world!"
    }
}
