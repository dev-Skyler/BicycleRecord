//
//  SettingViewController.swift
//  BicycleRecord
//
//  Created by 이현호 on 2022/09/29.
//

import Foundation
import UIKit
import SafariServices
import MessageUI

class SettingViewController: BaseViewController {
    
    lazy var setVersion: UILabel = {
        let label = UILabel()
        label.text = "\(currentAppVersion())"
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .gray
        return label
    }()
    
    lazy var tableView: UITableView = {
        let view = UITableView()
        view.rowHeight = 60
        view.backgroundColor = .white
        view.separatorStyle = .none
        view.delegate = self
        view.register(SettingTableViewCell.self, forCellReuseIdentifier: SettingTableViewCell.reuseIdentifier)
        return view
    }()
    
    let titles = ["문의하기", "리뷰 남기기", "개발자 정보", "오픈소스 라이선스 보기", "앱 버전"]
    
    var dataSource: UITableViewDiffableDataSource<Int, String>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        configureDataSource()
    }
    
    override func configure() {
        view.addSubview(tableView)
    }
    
    override func setConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    func currentAppVersion() -> String {
        if let info: [String: Any] = Bundle.main.infoDictionary,
           let currentVersion: String
            = info["CFBundleShortVersionString"] as? String {
            return currentVersion
        }
        return "nil"
    }
    
    func openNotion() {
        guard let url = URL(string: "https://elite-pet-b14.notion.site/Ricle-90a18363c595446fa9ae9ae3a5ae9738") else { return }
        let safariViewController = SFSafariViewController(url: url)
        present(safariViewController, animated: true, completion: nil)
    }
    
    func openMailView() {
        let picker = MFMailComposeViewController()
        picker.mailComposeDelegate = self
        picker.setToRecipients(["ho971122@gmail.com"])
        picker.setSubject("Ricle 문의사항")
        picker.setMessageBody("", isHTML: true)
        present(picker, animated: true, completion: nil)
    }
    
    func openReview() {
        if let appstoreURL = URL(string: "https://apps.apple.com/kr/app/ricle/id6443554916") {
            var components = URLComponents(url: appstoreURL, resolvingAgainstBaseURL: false)
            components?.queryItems = [
              URLQueryItem(name: "action", value: "write-review")
            ]
            guard let writeReviewURL = components?.url else {
                return
            }
            UIApplication.shared.open(writeReviewURL, options: [:], completionHandler: nil)
        }
    }
}

extension SettingViewController: MFMailComposeViewControllerDelegate {
    func sendMail() {
        if MFMailComposeViewController.canSendMail() {
            openMailView()
        } else {
            let alert = UIAlertController(title: "문의하기를 사용하시려면 \n 메일 앱 세팅이 필요합니다.", message: "메일 앱을 세팅하시겠어요?", preferredStyle: UIAlertController.Style.alert)
            let okAction = UIAlertAction(title: "확인", style: .default) { _ in
                if let url = URL(string: "mailto://azimov@demo.com") {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url)
                    } else {
                        let alert = UIAlertController(title: "메일 앱 로드에 실패하셨습니다.", message: "ho971122@gmail.com으로 문의주세요.", preferredStyle: UIAlertController.Style.alert)
                        let ok = UIAlertAction(title: "확인", style: .default)
                        alert.addAction(ok)
                        self.present(alert, animated: true)
                    }
                }
            }
            let cancelAction = UIAlertAction(title: "취소", style: .destructive) { _ in
                let alert = UIAlertController(title: "ho971122@gmail.com으로 문의주세요.", message: nil, preferredStyle: UIAlertController.Style.alert)
                let ok = UIAlertAction(title: "확인", style: .default)
                alert.addAction(ok)
                self.present(alert, animated: true)
            }
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            present(alert, animated: true, completion: nil)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case .sent:
            //메일 발송 성공(인터넷이 안되는 경우도 해당 케이스 가능, 인터넷이 연결되면 메일이 발송됨)
            showToastMessage("메일 발송 성공하셨습니다.")
        case .saved:
            //메일 임시 저장
            showToastMessage("메일이 임시 저장되었습니다.")
        case .cancelled:
            //메일 작성 취소
            showToastMessage("메일 작성을 취소하셨습니다.")
        case .failed:
            //메일 발송 실패 (오류 발생)
            showToastMessage("메일 발송에 실패하였습니다.")
        @unknown default:
            fatalError()
        }
        dismiss(animated: true, completion: nil)
    }
}

extension SettingViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0: sendMail()
        case 1: openReview()
        case 2, 3: openNotion()        
        default: break
        }
    }
}

extension SettingViewController {
    private func configureDataSource() {
        
        dataSource = UITableViewDiffableDataSource(tableView: tableView, cellProvider: { tableView, indexPath, itemIdentifier in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingTableViewCell.reuseIdentifier) as? SettingTableViewCell else { return UITableViewCell() }
            cell.selectionStyle = .none
            cell.setTitle.text = self.titles[indexPath.row]
            if indexPath.row == 4 {
                self.setVersion.sizeToFit()
                cell.accessoryView = self.setVersion
            }
            return cell
        })
        
        tableView.dataSource = dataSource
        
        var snapshot = NSDiffableDataSourceSnapshot<Int, String>()
        snapshot.appendSections([0])
        snapshot.appendItems(titles)
        dataSource.apply(snapshot)
    }
    
}
