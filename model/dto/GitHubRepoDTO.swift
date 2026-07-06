import Foundation

/// GitHub 仓库 DTO
struct GitHubRepoDTO: Decodable {
    let id: Int; let name: String; let fullName: String; let description: String?; let language: String?
    let stargazersCount: Int; let forksCount: Int; let updatedAt: Date
    func toDomain() -> GitHubProfile.Repo {
        GitHubProfile.Repo(id: id, name: name, fullName: fullName, description: description, language: language, stargazersCount: stargazersCount, forksCount: forksCount, updatedAt: updatedAt)
    }
}
struct GitHubUserDTO: Decodable {
    let login: String; let avatarUrl: String; let followers: Int; let publicRepos: Int
    func toDomain(stars: Int, events: [GitHubProfile.Event], repos: [GitHubProfile.Repo]) -> GitHubProfile {
        GitHubProfile(username: login, avatarURL: avatarUrl, followers: followers, publicRepos: publicRepos, totalStars: stars, events: events, repos: repos)
    }
}