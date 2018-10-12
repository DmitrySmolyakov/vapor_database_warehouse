import Vapor
import FluentMySQL
import FluentSQL

struct EmployeeContent: Content {
    var fullName: String?
    var age: Int?
    var gender: Int?
    var address: String?
    var phoneNumber: String?
    var passportData: String?
    var positionID: Position.ID?
}

struct EmployeeWithPositions: Content {
    var employes: [Employee]?
    var positions: [Position]?
}

final class EmployesController: RouteCollection {
    func boot(router: Router) throws {
        let employees = router.grouped("employees")
        
        employees.get(use: index)
        employees.get(Employee.parameter, use: show)
        
        employees.post(Employee.self, use: create)
        
        employees.patch(EmployeeContent.self, at: Employee.parameter, use: update)
        
        employees.delete(Employee.parameter, use: delete)
    }
    
    func index(_ request: Request) throws -> Future<EmployeeWithPositions> {
        let employee = Employee.query(on: request).all()
        let positions = Position.query(on: request).all()
        
        return map(to: EmployeeWithPositions.self, employee, positions) { employee, positions in
            EmployeeWithPositions(employes: employee, positions: positions)
        }
    }
    
    func show(_ request: Request)throws -> Future<Employee> {
        return try request.parameters.next(Employee.self)
    }
    
    func create(_ request: Request, _ user: Employee)throws -> Future<Employee> {
        return user.create(on: request)
    }
    
    func update(_ request: Request, _ body: EmployeeContent)throws -> Future<Employee> {
        let employee = try request.parameters.next(Employee.self)
        return employee.map(to: Employee.self, { employee in
            employee.fullName = body.fullName ?? employee.fullName
            employee.age = body.age ?? employee.age
            employee.gender = body.gender ?? employee.gender
            employee.address = body.address ?? employee.address
            employee.phoneNumber = body.phoneNumber ?? employee.phoneNumber
            employee.passportData = body.passportData ?? employee.passportData
            employee.positionID = body.positionID ?? employee.positionID
            return employee
        }).update(on: request)
    }
    
    func delete(_ request: Request)throws -> Future<HTTPStatus> {
        return try request.parameters.next(Employee.self).delete(on: request).transform(to: .noContent)
    }
}
