//
//  MovieStore.swift
//  CombineTMDB
//
//  Created by Айдар Нуркин on 18.08.2023.
//

import Foundation
import Combine

public enum Endpoint: String, CustomStringConvertible, CaseIterable {
    case nowPlaying = "now_playing"
    case upcoming
    case popular
    case topRated = "top_rated"
    
    public var description: String {
        switch self {
        case .nowPlaying: return "Now Playing"
        case .popular: return "Popular"
        case .topRated: return "Top Rated"
        case .upcoming: return "Upcoming"
        }
    }
    
    public init?(index: Int) {
        switch index {
        case 0: self = .nowPlaying
        case 1: self = .popular
        case 2: self = .upcoming
        case 3: self = .topRated
        default: return nil
        }
    }
    
    public init?(description: String) {
        guard let first = Endpoint.allCases.first(where: { $0.description == description })
        else { return nil }
        self = first
    }
    
}

protocol MovieService {
    func fetchMovies(from endpoint: Endpoint) -> Future<[Movie],MovieStoreAPIError>
}

public class MovieStore: MovieService {
    public static let shared = MovieStore()
    private init() {}
    private let apiKey = "4ed7c21ef3798670d96ebd185966f99a"
    private let baseAPIURL = "https://api.themoviedb.org/3"
    private let urlSession = URLSession.shared
    private var subscriptions = Set<AnyCancellable>()
    private let jsonDecoder: JSONDecoder = {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-mm-dd"
        jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)
        return jsonDecoder
    }()
    
    func fetchMovies(from endpoint: Endpoint) -> Future<[Movie], MovieStoreAPIError> {
        return Future<[Movie],MovieStoreAPIError> { [unowned self] promise in
            guard let url = self.generateURL(with: endpoint) else {
                return promise(.failure(.urlError(URLError(URLError.unsupportedURL))))
            }
            self.urlSession.dataTaskPublisher(for: url)
            .tryMap { (data,response) -> Data in
                guard let httpResponse = response as? HTTPURLResponse, 200...299 ~= httpResponse.statusCode else {
                    throw MovieStoreAPIError.responseError(
                        (response as? HTTPURLResponse)?.statusCode ?? 500
                    )
                }
                return data
            }
            .decode(type: MoviesResponse.self, decoder: self.jsonDecoder)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    switch error {
                    case let urlError as URLError:
                        promise(.failure(.urlError(urlError)))
                    case let decodingError as DecodingError:
                        promise(.failure(.decodingError(decodingError)))
                    case let apiError as MovieStoreAPIError:
                        promise(.failure(apiError))
                    default:
                        promise(.failure(.genericError))
                    }
                }
            }, receiveValue: {
                promise(.success( $0.results ))
            })
            .store(in: &subscriptions)
        }
    }
    private func generateURL(with endpoint: Endpoint) -> URL? {
        guard var urlComponents = URLComponents(string: "\(baseAPIURL)/movie/\(endpoint.rawValue)") else {
            return nil
        }
        let queryItems = [URLQueryItem(name: "api_key", value: apiKey)]
        urlComponents.queryItems = queryItems
        return urlComponents.url
    }
}
