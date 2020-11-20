//
//  GeographyViewController.swift
//  NStackDemo
//
//  Created by Jigna Patel on 06.11.20.
//

import UIKit
import NStackSDK
import LocalizationManager

class GeographyViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var mainView: UIView!

    @IBOutlet weak var countryMainView: UIView! {
        didSet {
            countryMainView.layer.borderWidth = 0.25
            countryMainView.layer.borderColor = UIColor.lightGray.cgColor
            countryMainView.layer.cornerRadius = 8.0
        }
    }

    @IBOutlet weak var selectCountryLabel: UILabel!

    @IBOutlet weak var timezoneMainView: UIView! {
        didSet {
            timezoneMainView.layer.borderWidth = 0.25
            timezoneMainView.layer.borderColor = UIColor.lightGray.cgColor
            timezoneMainView.layer.cornerRadius = 8.0
        }
    }

    @IBOutlet weak var selectTimezoneLabel: UILabel!

    @IBOutlet weak var timezoneTitleLabel: UILabel! {
        didSet {
            timezoneTitleLabel.text = tr.geography.enterLatLng
        }
    }

    @IBOutlet weak var latTextField: UITextField! {
        didSet {
            latTextField.placeholder = tr.geography.enterLatitude
        }
    }

    @IBOutlet weak var lngTextField: UITextField! {
        didSet {
            lngTextField.placeholder = tr.geography.enterLongitude
        }
    }

    @IBOutlet weak var getTimezoneButton: UIButton! {
        didSet {
            getTimezoneButton.setTitle(tr.geography.getTimezone, for: .normal)
        }
    }

    @IBOutlet weak var timezoneValueLabel: UILabel! {
        didSet {
            timezoneValueLabel.text = ""
        }
    }

    @IBOutlet weak var countryPickerMainView: UIView!

    @IBOutlet weak var countryPickerView: UIPickerView! {
        didSet {
            countryPickerView.tag = 100
            countryPickerView.dataSource = self
            countryPickerView.delegate = self
        }
    }

    @IBOutlet weak var countryPickerTitleLabel: UILabel! {
        didSet {
            countryPickerTitleLabel.text = tr.geography.selectCountry
        }
    }

    @IBOutlet weak var timezonePickerMainView: UIView!

    @IBOutlet weak var timezonePickerView: UIPickerView! {
        didSet {
            timezonePickerView.tag = 200
            timezonePickerView.dataSource = self
            timezonePickerView.delegate = self
        }
    }

    @IBOutlet weak var timezonePickerTitleLabel: UILabel! {
        didSet {
            timezonePickerTitleLabel.text = tr.geography.selectTimezone
        }
    }


    // MARK: - Properties
    private var selectedCountryIndex: Int!
    private var selectedTimezoneIndex: Int!

    private var allCountries: [Country] = []
    private var allTimezones: [Timezone] = []

    // MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = tr.geography.geographyTitle
        countryPickerMainView.isHidden = true
        timezonePickerMainView.isHidden = true

        getCountries()
        getTimezones()
    }

    // MARK: - Callbacks -

    @IBAction func getTimezoneButtonTapped(_ sender: Any) {
        self.view.endEditing(true)
        if let latValue = latTextField.text, let lngValue = lngTextField.text, let lat = Double(latValue), let lng = Double(lngValue) {
            getTimezone(lat: lat, lng: lng)
        }
    }
    
    @IBAction func selectCountryButtonTapped(_ sender: Any) {
        self.view.endEditing(true)
        countryPickerMainView.showView(mainViewHeight: mainView.frame.size.height)
        timezonePickerMainView.hideView(mainViewHeight: mainView.frame.size.height)
    }


    @IBAction func selectTimezoneTapped(_ sender: Any) {
        self.view.endEditing(true)
        timezonePickerMainView.showView(mainViewHeight: mainView.frame.size.height)
        countryPickerMainView.hideView(mainViewHeight: mainView.frame.size.height)
    }

    @IBAction func countryPickerCancelButtonTapped(_ sender: Any) {
        countryPickerMainView.hideView(mainViewHeight: mainView.frame.size.height)
    }
    
    @IBAction func countryPickerDoneButtonTapped(_ sender: Any) {
        self.selectCountryLabel.text = self.allCountries[self.selectedCountryIndex].name
        countryPickerMainView.hideView(mainViewHeight: mainView.frame.size.height)
    }


    @IBAction func timezonePickerCancelButtonTapped(_ sender: Any) {
        timezonePickerMainView.hideView(mainViewHeight: mainView.frame.size.height)
    }

    @IBAction func timezonePickerDoneButtonTapped(_ sender: Any) {
        self.selectTimezoneLabel.text = self.allTimezones[self.selectedTimezoneIndex].name + " " + self.allTimezones[self.selectedTimezoneIndex].label
        timezonePickerMainView.hideView(mainViewHeight: mainView.frame.size.height)
    }
    
}

// MARK: - UIPickerViewDataSource, UIPickerViewDelegate
extension GeographyViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 100 {
            return allCountries.count
        } else if pickerView.tag == 200 {
            return allTimezones.count
        }
        return 0

    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 100 {
            return allCountries[row].name
        } else if pickerView.tag == 200 {
            return allTimezones[row].name + " " + allTimezones[row].label
        }
        return ""

    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 100 {
            selectedCountryIndex = row
        } else if pickerView.tag == 200 {
            selectedTimezoneIndex = row
        }
    }
}

// MARK: - API call
extension GeographyViewController {
    private func getCountries() {
        NStack.sharedInstance.geographyManager?.countries(completion: { [weak self] countries in
            guard let self = self else { return }
            _ = countries.map { (country) -> Void in
                self.allCountries.append(contentsOf: country)
            }
            DispatchQueue.main.async {
                self.selectedCountryIndex = 0
                self.countryPickerView.selectRow(self.selectedCountryIndex, inComponent: 0, animated: true)
                self.selectCountryLabel.text = self.allCountries[self.selectedCountryIndex].name
                self.countryPickerView.reloadAllComponents()
            }
        })
    }

    private func getTimezones() {
        NStack.sharedInstance.geographyManager?.timezones(completion: { (timezones, error) in
            guard error == nil else {
                return
            }
            self.allTimezones.append(contentsOf: timezones)
            DispatchQueue.main.async {
                self.selectedTimezoneIndex = 0
                self.timezonePickerView.selectRow(self.selectedTimezoneIndex, inComponent: 0, animated: true)
                self.selectTimezoneLabel.text = self.allTimezones[self.selectedTimezoneIndex].name + " " + self.allTimezones[self.selectedTimezoneIndex].label

                self.timezonePickerView.reloadAllComponents()
            }
        })
    }

    private func getTimezone(lat: Double, lng: Double) {
        NStack.sharedInstance.geographyManager?.timezone(lat: lat, lng: lng, completion: { timezone in
            _ = timezone.map { timezone -> Void in
                DispatchQueue.main.async {
                    self.timezoneValueLabel.text = timezone.name + " " + timezone.label
                }
            }
        })
    }
}
