//
//  MovieStoreAPIError.swift
//  CombineTMDB
//
//  Created by Айдар Нуркин on 18.08.2023.
//

import Foundation

enum MovieStoreAPIError: Error, LocalizedError {
    case urlError(URLError)
    case responseError(Int)
    case decodingError(DecodingError)
    case genericError
    
    var localizedDescription: String {
        switch self {
        case .urlError(let error):
            return error.localizedDescription
        case .decodingError(let error):
            return error.localizedDescription
        case .responseError(let status):
            return "bad response code: \(status)"
        case .genericError:
            return "an unknown error has been occured"
        }
    }
    
}
