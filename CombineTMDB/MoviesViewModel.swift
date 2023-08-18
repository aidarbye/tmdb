//
//  MoviesViewModel.swift
//  CombineTMDB
//
//  Created by Айдар Нуркин on 18.08.2023.
//

import Foundation
import Combine

final class MoviesViewModel: ObservableObject {
    var movieAPI = MovieStore.shared
    // input
    @Published var indexEndpoint:Int = 2
    // output
    @Published var movies = [Movie]()
    
    private var cancellableSet: Set<AnyCancellable> = []
    
    init() {
        $indexEndpoint
            .flatMap { (indexEndpoint) -> AnyPublisher<[Movie],Never> in
                self.movieAPI.fetchMovies(from: Endpoint(index: indexEndpoint)!)
                    .replaceError(with: [])
                    .eraseToAnyPublisher()
            }
            .assign(to: \.movies, on: self)
            .store(in: &self.cancellableSet)
    }
    
    deinit {
        for cancel in cancellableSet {
            cancel.cancel()
        }
    }
    
}
