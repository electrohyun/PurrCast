import UIKit

final class NyangAirViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var adviceTableView: UITableView!

    private struct AdviceItem {
        let iconName: String
        let text: String
    }

    private let adviceItems: [AdviceItem] = [
        AdviceItem(iconName: "exclamationmark.triangle.fill", text: "오늘의 공기는 보통이에요!"),
        AdviceItem(iconName: "facemask.fill", text: "외출 시 마스크를 착용해요"),
        AdviceItem(iconName: "figure.walk", text: "실외 활동은 가볍게 즐겨요"),
        AdviceItem(iconName: "wind", text: "하루 2번 환기해요"),
        AdviceItem(iconName: "person.2.fill", text: "민감군은 더 주의해요")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        adviceTableView.dataSource = self
        adviceTableView.delegate = self
        adviceTableView.rowHeight = 96
        adviceTableView.separatorStyle = .none
        adviceTableView.backgroundColor = .clear
    }

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return adviceItems.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "AdviceCell",
            for: indexPath
        ) as! AdviceTableViewCell

        let item = adviceItems[indexPath.row]

        cell.iconImageView.image = UIImage(systemName: item.iconName)
        cell.iconImageView.tintColor = .systemTeal
        cell.iconImageView.contentMode = .scaleAspectFit
        cell.adviceLabel.text = item.text

        cell.backgroundColor = .clear
        cell.contentView.backgroundColor = .white
        cell.selectionStyle = .none

        cell.contentView.layer.cornerRadius = 18
        cell.contentView.clipsToBounds = true

        return cell
    }
}
