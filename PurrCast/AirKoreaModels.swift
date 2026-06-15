import Foundation

struct AirKoreaResponse: Codable {
    let response: AirKoreaResponseData
}

struct AirKoreaResponseData: Codable {
    let body: AirKoreaBody
}

struct AirKoreaBody: Codable {
    let items: [AirQualityItem]
}

struct AirQualityItem: Codable {
    let sidoName: String?
    let stationName: String?
    let dataTime: String?

    let pm10Value: String?
    let pm25Value: String?

    let khaiValue: String?
    let khaiGrade: String?
}
