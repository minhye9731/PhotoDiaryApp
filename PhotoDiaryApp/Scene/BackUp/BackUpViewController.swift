//
//  BackUpViewController.swift
//  PhotoDiaryApp
//
//  Created by 강민혜 on 8/28/22.
//

import UIKit
import Zip


class BackUpViewController: BaseViewController {
    
    let mainView = BackUpView()
    
    var backupFiles: [String] = [] {
        didSet {
            self.mainView.tableView.reloadData()
        }
    }
    
    // MARK: - lifecycle
    override func loadView() {
        self.view = mainView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        fetchBackUpFiles()
    }
    
    override func configure() {
        mainView.tableView.delegate = self
        mainView.tableView.dataSource = self
        
        mainView.backUpButton.addTarget(self, action: #selector(backupButtonClicked), for: .touchUpInside)
        
        mainView.restoreButton.addTarget(self, action: #selector(restoreButtonClicked), for: .touchUpInside)
    }
    
    func fetchBackUpFiles() {
        self.backupFiles = fetchDocumentZipFile()
    }
    
    // MARK: - 백업 버튼 클릭
    @objc func backupButtonClicked() {
        var urlPaths = [URL]()
        
        guard let path = documentDirectoryPath() else { return }
        
        let realmFile = path.appendingPathComponent("default.realm")
        
        // realmfile 유효여부 확인
        guard FileManager.default.fileExists(atPath: realmFile.path) else {
            showAlertMessage(title: "백업할 파일이 없습니다")
            return
        }
        
        urlPaths.append(URL(string: realmFile.path)!)
        
        // 2) 백업 파일을 압축: URL
        do {
            let zipFilePath = try Zip.quickZipFiles(urlPaths, fileName : "sesacDiary_1")
            print("Archive Location: \(zipFilePath.lastPathComponent)")
            
            // 3) ctivityViewController - 외부로 연결할 수 있게끔
            showActivityViewController()
            fetchBackUpFiles()
            
        } catch {
            showAlertMessage(title: "압축을 실패했습니다")
        }
    }
    
    // MARK: - 복구 버튼 클릭
    @objc func restoreButtonClicked() {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.archive], asCopy: true)
        
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        
        // 가져와서 보여주려면 파일을 저장해두어야 함
        self.present(documentPicker, animated: true)
    }
    
    func showActivityViewController() {
        
        // 도큐먼트 위치에 백업 파일 확인
        guard let path = documentDirectoryPath() else {
            showAlertMessage(title: "도큐먼트 위치에 오류가 있습니다")
            return
        }
        
        let backupFileURL = path.appendingPathComponent("sesacDiary_1.zip")
        
        let vc = UIActivityViewController(activityItems: [backupFileURL], applicationActivities: [])
        self.present(vc, animated: true)
    }

}

// MARK: - tableview 설정 관련
extension BackUpViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchDocumentZipFile().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: BackUpTableViewCell.reuseIdentifier) as? BackUpTableViewCell else { return UITableViewCell() }
        
        let fileName = fetchDocumentZipFile()[indexPath.row]
        
        // 파일용량을 뽑아서 여기에 담아
        
        cell.titleLabel.text = "\(fileName) - (파일용량)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let urls = extractURLS()
        let fileName = fetchDocumentZipFile()[indexPath.row]
        
        print("fileName : \(fileName)")

        // 복구하기 함수만 그대로 추출해서 담아봄
        guard let selectedFileURL = urls.first else {
            showAlertMessage(title: "선택하신 파일을 찾을 수 없습니다.")
            return
        }
        
        guard let path = documentDirectoryPath() else {
            showAlertMessage(title: "도큐먼트 위치에 오류가 있습니다.")
            return
        }
        
        let sandboxFileURL = path.appendingPathComponent(selectedFileURL.lastPathComponent)
        
        if FileManager.default.fileExists(atPath: sandboxFileURL.path) {
            
            // 1)
            let fileURL = path.appendingPathComponent("\(fileName)")
            
            do {
                try Zip.unzipFile(fileURL, destination: path, overwrite: true, password: nil, progress: { progress in
                    print("progress(1): \(progress)")
                }, fileOutputHandler: { unzippedFile in
                    print("unzippedFile(1): \(unzippedFile)")
                    self.showAlertMessage(title: "복구가 완료되었습니다.(1)")
                })
            } catch {
                showAlertMessage(title: "압축 해제에 실패했습니다.(1)")
            }
            
        } else {
            // 2)
            do {
                // 파일 앱의 zip -> 도큐먼트 폴더에 복사
                try FileManager.default.copyItem(at: selectedFileURL, to: sandboxFileURL)
                
                let fileURL = path.appendingPathComponent("\(fileName)") // 폴더 생성, 폴더 안에 파일 저장
                
                try Zip.unzipFile(fileURL, destination: path, overwrite: true, password: nil, progress: { progress in
                    print("progress(2): \(progress)")
                }, fileOutputHandler: { unzippedFile in
                    print("unzippedFile(2): \(unzippedFile)")
                    self.showAlertMessage(title: "복구가 완료되었습니다.(2)")
                })
                
            } catch {
                showAlertMessage(title: "압축 해제에 실패했습니다.(2)")
            }
            
        }

        
    }
    
}

// MARK: - UIDocumentPickerDelegate - restore 관련
extension BackUpViewController: UIDocumentPickerDelegate {
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print(#function)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        
        guard let selectedFileURL = urls.first else {
            showAlertMessage(title: "선택하신 파일을 찾을 수 없습니다.")
            return
        }
        
        guard let path = documentDirectoryPath() else {
            showAlertMessage(title: "도큐먼트 위치에 오류가 있습니다.")
            return
        }
        
        let sandboxFileURL = path.appendingPathComponent(selectedFileURL.lastPathComponent)
        
        if FileManager.default.fileExists(atPath: sandboxFileURL.path) {
            
            // 1)
            let fileURL = path.appendingPathComponent("sesacDiary_1.zip")
            
            do {
                try Zip.unzipFile(fileURL, destination: path, overwrite: true, password: nil, progress: { progress in
                    print("progress(1): \(progress)")
                }, fileOutputHandler: { unzippedFile in
                    print("unzippedFile(1): \(unzippedFile)")
                    self.showAlertMessage(title: "복구가 완료되었습니다.(1)")
                })
            } catch {
                showAlertMessage(title: "압축 해제에 실패했습니다.")
            }
            
        } else {
            // 2)
            do {
                // 파일 앱의 zip -> 도큐먼트 폴더에 복사
                try FileManager.default.copyItem(at: selectedFileURL, to: sandboxFileURL)
                
                let fileURL = path.appendingPathComponent("sesacDiary_1.zip") // 폴더 생성, 폴더 안에 파일 저장
                
                try Zip.unzipFile(fileURL, destination: path, overwrite: true, password: nil, progress: { progress in
                    print("progress(2): \(progress)")
                }, fileOutputHandler: { unzippedFile in
                    print("unzippedFile(2): \(unzippedFile)")
                    self.showAlertMessage(title: "복구가 완료되었습니다.(2)")
                })
                
            } catch {
                showAlertMessage(title: "압축 해제에 실패했습니다.")
            }
        }
    }
    
    // 커스텀
    func customDocumentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt selectedFileURL: URL) {

        guard let path = documentDirectoryPath() else {
            showAlertMessage(title: "도큐먼트 위치에 오류가 있습니다.")
            return
        }
        
        let sandboxFileURL = path.appendingPathComponent(selectedFileURL.lastPathComponent)
        
        if FileManager.default.fileExists(atPath: sandboxFileURL.path) {
            let fileURL = path.appendingPathComponent("sesacDiary_1.zip")
            
            do {
                try Zip.unzipFile(fileURL, destination: path, overwrite: true, password: nil, progress: { progress in
                    print("progress: \(progress)")
                }, fileOutputHandler: { unzippedFile in
                    print("unzippedFile: \(unzippedFile)")
                    self.showAlertMessage(title: "복구가 완료되었습니다.")
                })
            } catch {
                showAlertMessage(title: "압축 해제에 실패했습니다.")
            }
            
        } else {
            
            do {
                // 파일 앱의 zip -> 도큐먼트 폴더에 복사
                try FileManager.default.copyItem(at: selectedFileURL, to: sandboxFileURL)
                
                let fileURL = path.appendingPathComponent("sesacDiary_1.zip") // 폴더 생성, 폴더 안에 파일 저장
                
                try Zip.unzipFile(fileURL, destination: path, overwrite: true, password: nil, progress: { progress in
                    print("progress: \(progress)")
                }, fileOutputHandler: { unzippedFile in
                    print("unzippedFile: \(unzippedFile)")
                    self.showAlertMessage(title: "복구가 완료되었습니다.")
                })
                
            } catch {
                showAlertMessage(title: "압축 해제에 실패했습니다.")
            }
        }
    }
}
