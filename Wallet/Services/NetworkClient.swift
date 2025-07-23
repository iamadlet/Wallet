import Foundation

enum NetworkError: Error {
    case invalidURL
    case httpError(Int)
    case noData
    case decodingError(Error)
    case encodingError(Error)
    case transportError(Error)
}

final class NetworkClient {
    private let baseURL: URL
    private let token: String
    private let session: URLSession

    init(baseURL: URL, token: String, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.token = token
        self.session = session
    }

    func request<RequestBody: Encodable, ResponseBody: Decodable>(
        path: String,
        method: String = "GET",
        body: RequestBody
    ) async throws -> ResponseBody {
        guard let url = URL(string: path, relativeTo: baseURL) else {
            print("❌ baseURL = \(baseURL), path = \(path)")
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if !(body is EmptyBody) {
            do {
                let encoder = JSONEncoder()
                encoder.dateEncodingStrategy = .iso8601
                request.httpBody = try encoder.encode(body)
            } catch {
                throw NetworkError.encodingError(error)
            }
        }
        
        print("🌐 Запрос: \(method) \(url.absoluteString)")
        if let body = request.httpBody {
            print("📦 Тело запроса:", String(data: body, encoding: .utf8) ?? "—")
        }

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            print("❌ Ошибка при запросе:", error)
            throw NetworkError.transportError(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.noData
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            print("🚫 HTTP ошибка: \(httpResponse.statusCode)")
            throw NetworkError.httpError(httpResponse.statusCode)
        }
        
        print("✅ Статус: \(httpResponse.statusCode)")
        print("📥 Ответ:", String(data: data, encoding: .utf8) ?? "нельзя декодировать")

        do {
            return try JSONDecoder.withFlexibleISO8601().decode(ResponseBody.self, from: data)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
}

private extension JSONDecoder {
    static func withFlexibleISO8601() -> JSONDecoder {
        let decoder = JSONDecoder()
        let fracFormatter = ISO8601DateFormatter()
        fracFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let baseFormatter = ISO8601DateFormatter()
        baseFormatter.formatOptions = [.withInternetDateTime]
        
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateStr = try container.decode(String.self)
            if let date = fracFormatter.date(from: dateStr) {
                return date
            }
            if let date = baseFormatter.date(from: dateStr) {
                return date
            }
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid date format: \(dateStr)"
            )
        }
        return decoder
    }
}
