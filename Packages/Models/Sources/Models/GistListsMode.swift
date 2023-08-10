//
//  GistListsMode.swift
//  GistHub
//
//  Created by Khoa Le on 10/12/2022.
//

import Foundation
import SwiftUI

public enum GistListsMode: Hashable {
    case currentUserGists
    case userStarredGists(userName: String?)
    case userGists(userName: String)
    case search(query: String)
    case discover(mode: DiscoverGistsMode)

    public var navigationTitle: String {
        switch self {
        case .currentUserGists, .search:
            return "Gists"
        case .userStarredGists:
            return "Starred Gists"
        case .userGists:
            return "Gists"
        case .discover:
            return "Discover Gists"
        }
    }

    public var promptSearchText: String {
        switch self {
        case .userStarredGists:
            return "Search Starred Gists"
        case .currentUserGists, .userGists:
            return "Search Gists"
        case .discover, .search:
            return ""
        }
    }

    public var navigationStyle: NavigationBarItem.TitleDisplayMode {
        switch self {
        case .search, .userGists, .userStarredGists:
            return .inline
        default:
            return .large
        }
    }

    public var shouldShowSearch: Bool {
        switch self {
        case .currentUserGists, .userStarredGists, .userGists:
            return true
        case .discover, .search:
            return false
        }
    }

    public var shouldShowMenuView: Bool {
        switch self {
        case .discover:
            return true
        default:
            return false
        }
    }
}

public enum DiscoverGistsMode: Int, Identifiable, Hashable {
    case all
    case forked
    case starred

    public var id: Int {
        rawValue
    }

    public static let allCases: [DiscoverGistsMode] = [.all, .forked, .starred]

    public var title: String {
        switch self {
        case .all:
            return "All Gists"
        case .forked:
            return "Forked"
        case .starred:
            return "Starred"
        }
    }
}
