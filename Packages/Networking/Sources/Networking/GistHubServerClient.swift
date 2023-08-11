import Foundation
import Networkable
import Models

public protocol GistHubServerClient {
    /// Get starred gists from the user name.
    func starredGists(fromUserName userName: String, page: Int) async throws -> GistsResponse

    func discoverGists(page: Int) async throws -> GistsResponse
    func discoverStarredGists(page: Int) async throws -> GistsResponse
    func discoverForkedGists(page: Int) async throws -> GistsResponse

    func search(from query: String, page: Int) async throws -> GistsResponse
}

public final class DefaultGistHubServerClient: GistHubServerClient {
    private let session: NetworkSession

    public init(session: NetworkSession = .gisthubapp) {
        self.session = session
    }

    public func starredGists(fromUserName userName: String, page: Int) async throws -> GistsResponse {
        let gists: [Gist] = try await session.data(for: API.starredGists(userName: userName, page: page))
        return GistsResponse(gists: gists, hasNextPage: !gists.isEmpty)
    }

    public func discoverGists(page: Int) async throws -> GistsResponse {
        let gists: [Gist] = try await session.data(for: API.discoverGists(page: page))
        return GistsResponse(gists: gists, hasNextPage: !gists.isEmpty)
    }

    public func discoverStarredGists(page: Int) async throws -> GistsResponse {
        let gists: [Gist] = try await session.data(for: API.discoverStarredGists(page: page))
        return GistsResponse(gists: gists, hasNextPage: !gists.isEmpty)
    }

    public func discoverForkedGists(page: Int) async throws -> GistsResponse {
        let gists: [Gist] = try await session.data(for: API.discoverForkedGists(page: page))
        return GistsResponse(gists: gists, hasNextPage: !gists.isEmpty)
    }

    public func search(from query: String, page: Int) async throws -> GistsResponse {
        let gists: [Gist] = try await session.data(for: API.search(query: query, page: page))
        return GistsResponse(gists: gists, hasNextPage: !gists.isEmpty)
    }
}

extension DefaultGistHubServerClient {
    enum API: Request {
        case starredGists(userName: String, page: Int)
        case discoverGists(page: Int)
        case discoverStarredGists(page: Int)
        case discoverForkedGists(page: Int)
        case search(query: String, page: Int)

        var url: String {
            switch self {
            case let .starredGists(userName, page):
                return "/users/\(userName)/starred?page=\(page)"
            case let .discoverGists(page):
                return "/discover?page=\(page)"
            case let .discoverStarredGists(page):
                return "/discover/starred?page=\(page)"
            case let .discoverForkedGists(page):
                return "/discover/forked?page=\(page)"
            case let .search(query, page):
                return "/search?q=\(query)&p=\(page)"
            }
        }

        var headers: [String: String]? {
            nil
        }

        var method: Networkable.Method {
            .get
        }

        func body() throws -> Data? {
            nil
        }
    }
}
