//
//  LanguageSelectionViewController.swift
//  NStackDemo
//
//  Created by Jigna Patel on 03.11.20.
//

import UIKit
import NStackSDK
import LocalizationManager
import Foundation

class LanguageSelectionViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var mainView: UIView!

    @IBOutlet weak var label: UILabel!

    @IBOutlet weak var selectLanguageButton: UIButton! {
        didSet {
            selectLanguageButton.setTitle(tr.languageSelection.selectLanguage, for: .normal)
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
    private var allLanguages: [DefaultLanguage] = []

    private var defaultLanguage: DefaultLanguage = (NStack.sharedInstance.localizationManager?.bestFitLanguage)!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        label.text = tr.languageSelection.title
        pickerView.isHidden = true
        getLanguages()
    }

    // MARK: - Callbacks -
    @IBAction func selectLanguageButtonTapped(_ sender: Any) {
        showPickerView()
    }

    @IBAction func pickerCancelButtonTapped(_ sender: Any) {
        hidePickerView()
    }

    @IBAction func pickerDoneButtonTapped(_ sender: Any) {
        setDefaultLanguage(selectedLanguage: defaultLanguage)
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
        return allLanguages.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        defaultLanguage = allLanguages[row]
        return defaultLanguage.name
    }
}

// MARK: - API call
extension LanguageSelectionViewController {
    func getLanguages() {
        NStack.sharedInstance.localizationManager?.fetchAvailableLanguages(completion: { [weak self] languages in
            guard let self = self else { return }
            self.allLanguages = languages
            DispatchQueue.main.async {
                self.languagePicker.reloadAllComponents()
                let selectDefaultRow = self.allLanguages.firstIndex(where: {$0.id == self.defaultLanguage.id})
                self.languagePicker.selectRow(selectDefaultRow ?? 0, inComponent: 0, animated: true)
            }
        })
    }


    func setDefaultLanguage(selectedLanguage: DefaultLanguage) {
        NStack.sharedInstance.localizationManager?.setOverrideLocale(locale: selectedLanguage.locale)
        NStack.sharedInstance.localizationManager?.updateLocalizations { _ in
            DispatchQueue.main.async {
                self.label.text = tr.languageSelection.title
                self.selectLanguageButton.setTitle(tr.languageSelection.selectLanguage, for: .normal)
            }
        } // The one without the completion didnt seem to work
    }
}
