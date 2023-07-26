//
//  ContentView.swift
//  Infinate-Scroll-SwiftUI
//
//  Created by Fahim Rahman on 2023-07-25.
//

import SwiftUI
import DynamicJSON

struct ContentView: View {
    
    @State private var jsonData = JSON()
    @State private var imageURLArray = [String]()
    @State private var currentPage = 0
    @State private var contentLimit = 10
    @State private var isLoading = false
    
    var body: some View {
        List {
            ForEach(0..<(self.imageURLArray.count), id: \.self) { i in
                LazyVStack {
                    AsyncImage(url: URL(string: self.imageURLArray[i]), scale: 0.5) { image in
                        image.resizable()
                            .aspectRatio(16/9, contentMode: .fit)
                            .cornerRadius(10)
                            .padding(.horizontal)
                            .padding(.vertical, 5)
                    }
                    placeholder: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(.black.opacity(0.1))
                                .aspectRatio(16/9, contentMode: .fit)
                                .padding(.horizontal)
                                .padding(.vertical, 5)
                            ProgressView()
                                .progressViewStyle(.circular)
                        }
                    }
                    .onAppear {
                        if self.imageURLArray[i] == self.imageURLArray.last {
                            self.loadMoreItems()
                        }
                    }
                }
            }
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets())
        }
        .listStyle(PlainListStyle())
        .clipped()
        .task {
            NetworkManager.shared.makeGenericAPIRequest(url: "https://picsum.photos/v2/list?page=\(self.currentPage)&limit=\(contentLimit)", method: .get) { result in
                do {
                    self.jsonData = JSON(try result.get())
                    for i in 0..<(self.jsonData.array?.count ?? 0) {
                        self.imageURLArray.append(self.jsonData[i].download_url.string ?? "")
                    }
                }
                catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    private func loadMoreItems() {
        guard !isLoading else { return }
        isLoading = true
        currentPage += 1
        NetworkManager.shared.makeGenericAPIRequest(url: "https://picsum.photos/v2/list?page=\(self.currentPage)&limit=\(contentLimit)", method: .get) { result in
            do {
                self.jsonData = JSON(try result.get())
                for i in 0..<(self.jsonData.array?.count ?? 0) {
                    self.imageURLArray.append(self.jsonData[i].download_url.string ?? "")
                }
            } catch {
                print(error.localizedDescription)
            }
            isLoading = false
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
