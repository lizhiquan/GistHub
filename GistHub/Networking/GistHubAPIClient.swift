//
//  GistHubAPIClient.swift
//  GistHub
//
//  Created by Khoa Le on 10/12/2022.
//

import Foundation
import Networkable

protocol GistHubAPIClient {
    /// List gists for the authenticated user.
    func gists() async throws -> [Gist]

    /// List the authenticated user's starred gist.
    func starredGists() async throws -> [Gist]

    /// Get authenticated user info.
    func user() async throws -> User

    /// Star a gist.
    func starGist(gistID: String) async throws

    /// Unstar a gist.
    func unstarGist(gistID: String) async throws

    /// Check if gist is starred.
    func isStarred(gistID: String) async throws

    /// Get a gist.
    func gist(fromGistID gistID: String) async throws -> Gist

    /// Update a gist
    ///
    /// Allows you to update a gist's description and to update, delete, or rename gist files.
    @discardableResult
    func updateGist(
        fromGistID gistID: String,
        description: String?,
        fileName: String,
        content: String
    ) async throws -> Gist

    /// Delete a gist.
    func deleteGist(fromGistID gistID: String) async throws

    /// Get comments of the gist.
    func comments(gistID: String) async throws -> [Comment]
}

final class DefaultGistHubAPIClient: GistHubAPIClient {
    private let session: NetworkSession

    init(session: NetworkSession = .github) {
        self.session = session
    }

    func gists() async throws -> [Gist] {
        try await session.data(for: API.gists)
    }

    func starredGists() async throws -> [Gist] {
        try await session.data(for: API.starredGists)
    }

    func user() async throws -> User {
        try await session.data(for: API.user)
    }

    func starGist(gistID: String) async throws {
        try await session.data(for: API.starGist(gistID: gistID))
    }

    func unstarGist(gistID: String) async throws {
        try await session.data(for: API.unstarGist(gistID: gistID))
    }

    func isStarred(gistID: String) async throws {
        try await session.data(for: API.isStarred(gistID: gistID))
    }

    func gist(fromGistID gistID: String) async throws -> Gist {
        try await session.data(for: API.gist(gistID: gistID))
    }

    func deleteGist(fromGistID gistID: String) async throws {
        try await session.data(for: API.deleteGist(gistID: gistID))
    }

    func comments(gistID: String) async throws -> [Comment] {
        try await session.data(for: API.comments(gistID: gistID))
    }

    @discardableResult
    func updateGist(
        fromGistID gistID: String,
        description: String?,
        fileName: String,
        content: String
    ) async throws -> Gist {
        try await session.data(for: API.updateGist(
            gistID: gistID,
            description: description,
            fileName: fileName,
            content: content
        ))
    }
}

extension DefaultGistHubAPIClient {
    enum API: Request {
        case gists
        case starredGists
        case user
        case starGist(gistID: String)
        case unstarGist(gistID: String)
        case isStarred(gistID: String)
        case gist(gistID: String)
        case updateGist(gistID: String, description: String?, fileName: String, content: String)
        case deleteGist(gistID: String)
        case comments(gistID: String)

        var headers: [String: String]? {
            return [
                "Authorization": "Bearer \(PRIVATE_TOKEN)",
                "Accept": "application/vnd.github+json"
            ]
        }

        var url: String {
            switch self {
            case .gists:
                return "/gists"
            case .starredGists:
                return "/gists/starred"
            case .user:
                return "/user"
            case let .starGist(gistID),
                let .unstarGist(gistID),
                let .isStarred(gistID):
                return "/gists/\(gistID)/star"
            case let .gist(gistID), let .deleteGist(gistID), let .updateGist(gistID, _, _, _):
                return "/gists/\(gistID)"
            case let .comments(gistID):
                return "/gists/\(gistID)/comments"
            }
        }

        var method: Networkable.Method {
            switch self {
            case .gists, .starredGists, .user, .isStarred, .gist, .comments:
                return .get
            case .starGist:
                return .put
            case .unstarGist, .deleteGist:
                return .delete
            case .updateGist:
                return .patch
            }
        }

        func body() throws -> Data? {
            switch self {
            case let .updateGist(_, description, fileName, content):
                struct Request: Codable {
                    let description: String?
                    let files: [String: FileValue]?

                    struct FileValue: Codable {
                        let content: String?
                    }

                    func toData() throws -> Data? {
                        return try? JSONEncoder().encode(self)
                    }
                }
                let content = Request.FileValue(content: content)
                let files: [String: Request.FileValue] = [fileName: content]
                let request = Request(description: description, files: files)
                return try? request.toData()
            default:
                return nil
            }
        }
    }
}
