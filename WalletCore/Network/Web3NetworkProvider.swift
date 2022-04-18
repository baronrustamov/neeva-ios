// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

public protocol NetworkProviding {
    func request<T: Decodable>(
        target: URLRequestBuilder,
        model: T.Type,
        completion: @escaping (
            Result<T, Error>
        ) -> Void)
}

public class Web3NetworkProvider {

    public static let `default`: Web3NetworkProvider = {
        var service = Web3NetworkProvider()
        return service
    }()
}

extension Web3NetworkProvider: NetworkProviding {
    public func request<T>(
        target: URLRequestBuilder,
        model: T.Type,
        completion: @escaping (Result<T, Error>) -> Void
    ) where T: Decodable {
        URLSession.shared.dataTask(with: target.urlRequest) { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.notFound))
                }
                return
            }

            guard let result = try? JSONDecoder().decode(T.self, from: data) else {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.cannotParseResponse))
                }
                return
            }

            DispatchQueue.main.async {
                completion(.success(result))
            }
        }.resume()
    }
}
