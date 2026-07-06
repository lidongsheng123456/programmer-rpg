import Foundation

/// 博客远程数据源，从博客 API 拉取文章列表
final class BlogRemoteDataSource: @unchecked Sendable {
    private let network: NetworkClientProtocol; private let blogURL: String
    init(network: NetworkClientProtocol, blogURL: String = AppConfig.blogURL) { self.network = network; self.blogURL = blogURL }

    func fetchPosts() async throws -> [BlogPost] {
        guard let url = URL(string: blogURL) else { throw NetworkError.invalidURL(blogURL) }
        var req = URLRequest(url: url); req.httpMethod = "GET"; req.timeoutInterval = AppConfig.networkTimeoutSeconds
        let (data, _) = try await URLSession.shared.data(for: req)
        guard let html = String(data: data, encoding: .utf8) else { return [] }
        return parseHTML(html)
    }

    private func parseHTML(_ html: String) -> [BlogPost] {
        var posts: [BlogPost] = []
        let pattern = #"<a[^>]*href=[\"']([^\"']*)[\"'][^>]*>([^<]+)</a>"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
        let range = NSRange(html.startIndex..., in: html)
        for (i, m) in regex.matches(in: html, range: range).enumerated() where i < 50 {
            guard let ur = Range(m.range(at: 1), in: html), let tr = Range(m.range(at: 2), in: html) else { continue }
            let href = String(html[ur]); let title = String(html[tr]).trimmingCharacters(in: .whitespacesAndNewlines)
            guard !title.isEmpty, title.count > 2, !href.contains("javascript:"), !href.contains("#") else { continue }
            let full = href.hasPrefix("http") ? href : "\(blogURL)\(href)"
            posts.append(BlogPost(id: "\(i)", title: title, url: full, publishedAt: nil))
        }
        return posts
    }
}