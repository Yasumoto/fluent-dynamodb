import Fluent

struct FluentDynamoDBDriver: Provider {
    func register(_ services: inout Services) throws {
        try services.register(FluentProvider())
        //
    }
    
    func didBoot(_ container: Container) throws -> EventLoopFuture<Void> {
        return container.eventLoop.future()
    }
    
    public init() {
        
    }
}
