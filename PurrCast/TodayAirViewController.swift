import UIKit
import CoreLocation

final class TodayAirViewController: UIViewController {

    @IBOutlet weak var locationTitleLabel: UILabel!
    @IBOutlet weak var stationLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var pm10ValueLabel: UILabel!
    @IBOutlet weak var pm25ValueLabel: UILabel!
    @IBOutlet weak var khaiValueLabel: UILabel!
    @IBOutlet weak var khaiGradeLabel: UILabel!

    private let airKoreaService = AirKoreaService()
    private let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        requestCurrentLocation()
    }

    private func requestCurrentLocation() {
        let status = locationManager.authorizationStatus

        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()

        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()

        case .denied, .restricted:
            // 권한 거부 시 기본값
            fetchTodayAir(sidoName: "서울", stationName: "중구")

        @unknown default:
            fetchTodayAir(sidoName: "서울", stationName: "중구")
        }
    }

    private func reverseGeocode(location: CLLocation) {
        let geocoder = CLGeocoder()

        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            if let error = error {
                print("주소 변환 실패:", error)
                self?.fetchTodayAir(sidoName: "서울", stationName: "중구")
                return
            }

            guard let placemark = placemarks?.first else {
                print("placemark 없음")
                self?.fetchTodayAir(sidoName: "서울", stationName: "중구")
                return
            }

            print("administrativeArea:", placemark.administrativeArea ?? "nil")
            print("locality:", placemark.locality ?? "nil")
            print("subAdministrativeArea:", placemark.subAdministrativeArea ?? "nil")
            print("subLocality:", placemark.subLocality ?? "nil")

            let sido = self?.convertToAirKoreaSidoName(placemark.administrativeArea) ?? "서울"

            let district =
                placemark.subLocality ??
                placemark.subAdministrativeArea ??
                placemark.locality ??
                "중구"

            print("최종 선택 지역:", sido, district)

            self?.fetchTodayAir(sidoName: sido, stationName: district)
        }
    }

    private func fetchTodayAir(sidoName: String, stationName: String) {
        airKoreaService.fetchAirQuality(sidoName: sidoName) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let items):
                    let selectedItem =
                        items.first { $0.stationName == stationName } ??
                        items.first { item in
                            guard let name = item.stationName else { return false }

                            let normalizedStation = normalizeAreaName(name)
                            let normalizedCurrent = normalizeAreaName(stationName)

                            return normalizedStation == normalizedCurrent ||
                                   normalizedStation.contains(normalizedCurrent) ||
                                   normalizedCurrent.contains(normalizedStation)
                        } ??
                        items.first

                    guard let item = selectedItem else {
                        self?.showEmptyState()
                        return
                    }

                    self?.updateUI(with: item, sidoName: sidoName)

                case .failure(let error):
                    print("대기질 API 호출 실패:", error)
                    self?.showEmptyState()
                }
            }
        }
    }

    private func updateUI(with item: AirQualityItem, sidoName: String) {
        let stationName = item.stationName ?? "-"

        locationTitleLabel.text = "\(sidoName) \(stationName)"
        stationLabel.text = "측정소: \(stationName)"
        timeLabel.text = "측정시간: \(item.dataTime ?? "-")"

        pm10ValueLabel.text = valueText(item.pm10Value)
        pm25ValueLabel.text = valueText(item.pm25Value)
        khaiValueLabel.text = valueText(item.khaiValue)
        khaiGradeLabel.text = gradeText(item.khaiGrade)
    }

    private func showEmptyState() {
        locationTitleLabel.text = "서울 중구"
        stationLabel.text = "측정소: -"
        timeLabel.text = "측정시간: -"
        pm10ValueLabel.text = "-"
        pm25ValueLabel.text = "-"
        khaiValueLabel.text = "-"
        khaiGradeLabel.text = "-"
    }

    private func valueText(_ value: String?) -> String {
        guard let value,
              value.isEmpty == false,
              value != "-" else {
            return "-"
        }

        return value
    }

    private func gradeText(_ grade: String?) -> String {
        switch grade {
        case "1": return "좋음"
        case "2": return "보통"
        case "3": return "나쁨"
        case "4": return "매우나쁨"
        default: return "-"
        }
    }

    private func convertToAirKoreaSidoName(_ administrativeArea: String?) -> String {
        guard let administrativeArea else {
            return "서울"
        }

        if administrativeArea.contains("서울") { return "서울" }
        if administrativeArea.contains("부산") { return "부산" }
        if administrativeArea.contains("대구") { return "대구" }
        if administrativeArea.contains("인천") { return "인천" }
        if administrativeArea.contains("광주") { return "광주" }
        if administrativeArea.contains("대전") { return "대전" }
        if administrativeArea.contains("울산") { return "울산" }
        if administrativeArea.contains("세종") { return "세종" }
        if administrativeArea.contains("경기") { return "경기" }
        if administrativeArea.contains("강원") { return "강원" }
        if administrativeArea.contains("충청북도") { return "충북" }
        if administrativeArea.contains("충청남도") { return "충남" }
        if administrativeArea.contains("전북") || administrativeArea.contains("전라북도") { return "전북" }
        if administrativeArea.contains("전남") || administrativeArea.contains("전라남도") { return "전남" }
        if administrativeArea.contains("경북") || administrativeArea.contains("경상북도") { return "경북" }
        if administrativeArea.contains("경남") || administrativeArea.contains("경상남도") { return "경남" }
        if administrativeArea.contains("제주") { return "제주" }

        return "서울"
    }
}

extension TodayAirViewController: CLLocationManagerDelegate {

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        requestCurrentLocation()
    }

    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let location = locations.last else {
            fetchTodayAir(sidoName: "서울", stationName: "중구")
            return
        }

        reverseGeocode(location: location)
    }

    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        print("현재 위치 가져오기 실패:", error)
        fetchTodayAir(sidoName: "서울", stationName: "중구")
    }
}

private func normalizeAreaName(_ name: String) -> String {
    return name
        .replacingOccurrences(of: "특별시", with: "")
        .replacingOccurrences(of: "광역시", with: "")
        .replacingOccurrences(of: "특별자치시", with: "")
        .replacingOccurrences(of: "특별자치도", with: "")
        .replacingOccurrences(of: "도", with: "")
        .replacingOccurrences(of: "시", with: "")
        .replacingOccurrences(of: "구", with: "")
        .replacingOccurrences(of: "군", with: "")
        .replacingOccurrences(of: "동", with: "")
        .replacingOccurrences(of: "읍", with: "")
        .replacingOccurrences(of: "면", with: "")
        .trimmingCharacters(in: .whitespacesAndNewlines)
}
