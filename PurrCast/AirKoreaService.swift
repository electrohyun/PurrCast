//
//  AirKoreaService.swift
//  PurrCast
//
//  Created by 정기현 on 6/15/26.
//

import Foundation

final class AirKoreaService {
    private let serviceKey = "비밀"

    func fetchAirQuality(sidoName: String, completion: @escaping (Result<[AirQualityItem], Error>) -> Void) {
        var components = URLComponents(string: "https://apis.data.go.kr/B552584/ArpltnInforInqireSvc/getCtprvnRltmMesureDnsty")!

        components.queryItems = [
            URLQueryItem(name: "serviceKey", value: serviceKey),
            URLQueryItem(name: "returnType", value: "json"),
            URLQueryItem(name: "numOfRows", value: "100"),
            URLQueryItem(name: "pageNo", value: "1"),
            URLQueryItem(name: "sidoName", value: sidoName),
            URLQueryItem(name: "ver", value: "1.3")
        ]

        guard let url = components.url else {
            completion(.failure(URLError(.badURL)))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }

            do {
                let decoded = try JSONDecoder().decode(AirKoreaResponse.self, from: data)
                completion(.success(decoded.response.body.items))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
