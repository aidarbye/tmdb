//
//  ContentView.swift
//  CombineTMDB
//
//  Created by Айдар Нуркин on 18.08.2023.
//

import SwiftUI
import Combine

fileprivate let formatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter
}()

struct ContentView: View {
    @EnvironmentObject var moviewViewModel: MoviesViewModel
    
    var body: some View {
        VStack {
            Text("\(moviewViewModel.indexEndpoint)")
            Stepper("Enter your index", value: $moviewViewModel.indexEndpoint, in: 0...3)
                .padding()
            Picker("", selection: $moviewViewModel.indexEndpoint) {
                Text("\(Endpoint(index: 0)!.description)").tag(0)
                Text("\(Endpoint(index: 1)!.description)").tag(1)
                Text("\(Endpoint(index: 2)!.description)").tag(2)
                Text("\(Endpoint(index: 3)!.description)").tag(3)
            }
            .pickerStyle(.segmented)
            List {
                ForEach(moviewViewModel.movies) { movie in
                    HStack {
                        MoviePosterImage(imageLoader: ImageLoaderCache.shared.loaderFor(path: movie.posterPath, size: .medium), posterSize: .medium)
                        VStack {
                            Text("\(movie.title)").font(.title)
                            Text("\(movie.overview)")
                                .lineLimit(3)
                            HStack {
                                Text(formatter.string(from: movie.releaseDate))
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                }
            }
            .listStyle(.plain)
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(MoviesViewModel())
    }
}
