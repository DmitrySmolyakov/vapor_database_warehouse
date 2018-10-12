import Vapor
import FluentMySQL
import FluentSQL

struct PositionContent: Content {
    var name: String?
    var salary: Double?
    var responsibility: String?
    var requirements: String?
}

final class PositionController: RouteCollection {
    func boot(router: Router) throws {
        let positions = router.grouped("positions")
        
        positions.get(use: index)
        positions.get(Position.parameter, use: show)
        
        let positionID = positions.grouped(Position.parameter)
        positionID.get("employees", use: getPositionEmployees)
        
        positions.post(Position.self, use: create)
        
        positions.patch(PositionContent.self, at: Position.parameter, use: update)
        
        positions.delete(Position.parameter, use: delete)
    }
    
    func index(_ request: Request) throws -> Future<[Position]> {
        return Position.query(on: request).all()
    }
    
    func show(_ request: Request)throws -> Future<Position> {
        return try request.parameters.next(Position.self)
    }
    
    func getPositionEmployees(_ request: Request) throws -> Future<[Employee]> {
        let position = try request.parameters.next(Position.self)
        return position.flatMap({ (position) -> EventLoopFuture<[Employee]> in
            return try position.employees.query(on: request).all()
        })
    }
    
    func create(_ request: Request, _ position: Position)throws -> Future<Position> {
        return position.create(on: request)
    }
    
    func update(_ request: Request, _ body: PositionContent)throws -> Future<Position> {
        let position = try request.parameters.next(Position.self)
        return position.map(to: Position.self, { position in
            position.name = body.name ?? position.name
            position.salary = body.salary ?? position.salary
            position.responsibility = body.responsibility ?? position.responsibility
            position.requirements = body.requirements ?? position.requirements
            return position
        }).update(on: request)
    }
    
    func delete(_ request: Request)throws -> Future<HTTPStatus> {
        return try request.parameters.next(Position.self).delete(on: request).transform(to: .noContent)
    }
}
