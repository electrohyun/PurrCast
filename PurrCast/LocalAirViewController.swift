import UIKit

final class LocalAirViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var regionButton: UIButton!
    @IBOutlet weak var regionTableView: UITableView!

    private let airKoreaService = AirKoreaService()
    private var airItems: [AirQualityItem] = []

    private let regions = [
        "서울", "부산", "대구", "인천", "광주",
        "대전", "울산", "세종", "경기", "강원",
        "충북", "충남", "전북", "전남",
        "경북", "경남", "제주"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        regionTableView.dataSource = self
        regionTableView.delegate = self
        regionTableView.rowHeight = 72
        regionTableView.separatorStyle = .none

        setupRegionMenu()
        fetchRegionAir(sidoName: "서울")
    }

    private func setupRegionMenu() {
        let actions = regions.map { region in
            UIAction(title: region) { [weak self] _ in
                self?.regionButton.setTitle("\(region) ▾", for: .normal)
                self?.fetchRegionAir(sidoName: region)
            }
        }

        regionButton.menu = UIMenu(title: "지역 선택", children: actions)
        regionButton.showsMenuAsPrimaryAction = true
        regionButton.setTitle("서울 ▾", for: .normal)
        regionButton.setTitleColor(.systemBlue, for: .normal)
    }

    private func fetchRegionAir(sidoName: String) {
        airKoreaService.fetchAirQuality(sidoName: sidoName) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let items):
                    print("\(sidoName) 지역 데이터 개수:", items.count)
                    self?.airItems = items
                    self?.regionTableView.reloadData()

                case .failure(let error):
                    print("지역별 대기질 API 실패:", error)
                    self?.airItems = []
                    self?.regionTableView.reloadData()
                }
            }
        }
    }

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return airItems.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "AirCell",
            for: indexPath
        ) as! AirTableViewCell

        let item = airItems[indexPath.row]

        cell.stationLabel.text = item.stationName ?? "-"
        cell.pm10Label.text = valueText(item.pm10Value)
        cell.pm25Label.text = valueText(item.pm25Value)
        cell.statusLabel.text = gradeText(item.khaiGrade)

        cell.backgroundColor = .clear
        cell.contentView.backgroundColor = .clear
        cell.selectionStyle = .none

        return cell
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
}
