//
//  LanguageSelectionViewController.swift
//  NStackDemo
//
//  Created by Jigna Patel on 03.11.20.
//

import UIKit

class LanguageSelectionViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var mainView: UIView!

    @IBOutlet weak var label: UILabel!

    @IBOutlet weak var selectLanguageButton: UIButton! {
        didSet {
            selectLanguageButton.setTitle("_Select language", for: .normal)
        }
    }

    @IBOutlet weak var pickerView: UIView!

    @IBOutlet weak var languagePicker: UIPickerView! {
        didSet {
            languagePicker.dataSource = self
            languagePicker.delegate = self
        }
    }

    // MARK: - Properties
    var pickerData: [String] = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        label.text = lo.defaultSection.ok
        pickerData = ["Item 1", "Item 2", "Item 3", "Item 4", "Item 5", "Item 6"]
        pickerView.isHidden = true
    }

    // MARK: - Callbacks -
    @IBAction func selectLanguageButtonTapped(_ sender: Any) {
        showPickerView()
    }

    @IBAction func pickerCancelButtonTapped(_ sender: Any) {
        hidePickerView()
    }

    @IBAction func pickerDoneButtonTapped(_ sender: Any) {
        hidePickerView()
    }

    // MARK: - Show/Hide UIPickerView Helper
    func showPickerView() {
        self.view.endEditing(true)
        pickerView.isHidden = false

        pickerView.frame = CGRect(x: pickerView.frame.origin.x, y: mainView.frame.size.height, width: self.pickerView.frame.width, height: pickerView.frame.size.height)

        UIView.animate(withDuration: 0.3) {
            self.pickerView.frame = CGRect(x: self.pickerView.frame.origin.x, y: self.mainView.frame.size.height - self.pickerView.frame.size.height, width: self.pickerView.frame.width, height: self.pickerView.frame.size.height)
        }
    }

    func hidePickerView() {
        UIView.animate(withDuration: 0.3) {
            self.pickerView.frame = CGRect(x: self.pickerView.frame.origin.x, y: self.mainView.frame.size.height, width: self.pickerView.frame.width, height: self.pickerView.frame.size.height)
        } completion: { (_) in
            self.pickerView.isHidden = true
        }
    }

}

// MARK: - UIPickerViewDataSource, UIPickerViewDelegate
extension LanguageSelectionViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
}
