import Foundation

final class BlogRemoteDataSource: @unchecked Sendable {
    private let network: NetworkClientProtocol
    private let blogURL: String

    init(network: NetworkClientProtocol, blogURL: String = AppConfig.blogURL) {
        self.network = network
        self.blogURL = blogURL
    }

    /// Fetches the blog page HTML and parses article entries.
    /// Simplified parser targeting common blog structures.
    func fetchPosts() async throws -> [BlogPost] {
        guard let url = URL(string: blogURL) else {
            throw NetworkError.invalidURL(blogURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = AppConfig.networkTimeoutSeconds

        let (data, _) = try await URLSession.shared.data(for: request)
        guard let html = String(data: data, encoding: .utf8) else {
            return []
        }

        return parseHTML(html)
    }

    private func parseHTML(_ html: String) -> [BlogPost] {
        var posts: [BlogPost] = []

        // Match common blog patterns: <a href="...">title</a> with dates
        let linkPattern = #"<a[^>]*href=[\"']([^\"']*)[\"'][^>]*>([^<]+)</a>"#
        guard let regex = try? NSRegularExpression(pattern: linkPattern) else { return [] }

        let range = NSRange(html.startIndex..., in: html)
        let matches = regex.matches(in: html, range: range)

        for (index, match) in matches.enumerated() where index < 50 {
            guard let urlRange = Range(match.range(at: 1), in: html),
                  let titleRange = Range(match.range(at: 2), in: html) else { continue }

            let href = String(html[urlRange])
            let title = String(html[titleRange]).trimmingCharacters(in: .whitespacesAndNewlines)

            guard !title.isEmpty, title.count > 2,
                  !href.contains("javascript:"),
                  !href.contains("#") else { continue }

            let fullURL = href.hasPrefix("http") ? href : "\(blogURL)\(href)"
            posts.append(BlogPost(
                id: "\(index)",
                title: title,
                url: fullURL,
                publishedAt: nil
            ))
        }

        return posts
    }
}
