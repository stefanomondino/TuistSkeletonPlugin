{{ fileHeader }}

import Combine

import Foundation
import Networking
import ToolKit

public class Client {
    enum REST {
        static func stub(_ config: Config) -> CodableEndpoint<Value> {
            .init(.init(baseURL: config.baseURL,
                        path: "/path/to/resource",
                        queryParameters: ["key": "value"]))
        }
    }

    let rest: RESTDataSource
    public init(rest: RESTDataSource) {
        self.rest = rest
    }

    public func stub(_ config: Config) -> AnyPublisher<Value, NetworkingError> {
        let endpoint = REST.stub(config)
        return rest.getCodable(at: endpoint)
            .eraseToAnyPublisher()
    }
}
