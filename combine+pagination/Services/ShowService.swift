//
//  ShowService.swift
//  combine+pagination
//
//  Created by Z on 21/01/2023.
//

import Foundation
import Combine

protocol RequestProtocol {
    func getShows(pageNumber: String) -> AnyPublisher<Show, Error>
}

class ShowService: RequestProtocol {
    
    func getShows(pageNumber: String) -> AnyPublisher<Show, Error> {
        
        guard let url = URL(string: "https://api.tvmaze.com/shows?page=\(pageNumber)") else { fatalError("wrong url") }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .receive(on: RunLoop.main)
            .map( \.data )
            .decode(type: Show.self, decoder: JSONDecoder())
            .catch { _ in Empty<Show, Error>() }
            .eraseToAnyPublisher()
    }
}
