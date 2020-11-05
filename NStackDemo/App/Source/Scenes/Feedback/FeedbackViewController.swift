//
//  FeedbackViewController.swift
//  NStackDemo
//
//  Created by Jigna Patel on 04.11.20.
//

import UIKit
import NStackSDK
import LocalizationManager

class FeedbackViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var mainView: UIView!

    @IBOutlet weak var feedbackTypeView: UIView! {
        didSet {
            feedbackTypeView.layer.borderWidth = 0.25
            feedbackTypeView.layer.borderColor = UIColor.lightGray.cgColor
            feedbackTypeView.layer.cornerRadius = 8.0
        }
    }

    @IBOutlet weak var feedbackTypeLabel: UILabel!

    @IBOutlet weak var nameTextField: UITextField! {
        didSet {
            nameTextField.placeholder = tr.feedback.enterName
        }
    }

    @IBOutlet weak var emailTextField: UITextField! {
        didSet {
            emailTextField.placeholder = tr.feedback.enterEmail
        }
    }

    @IBOutlet weak var messageTextView: UITextView! {
        didSet {
            messageTextView.layer.borderWidth = 0.5
            messageTextView.layer.borderColor = UIColor.systemGray.cgColor
        }
    }

    @IBOutlet weak var selectImageView: UIView! {
        didSet {
            selectImageView.layer.borderWidth = 0.25
            selectImageView.layer.borderColor = UIColor.lightGray.cgColor
            selectImageView.layer.cornerRadius = 8.0
        }
    }

    @IBOutlet weak var selectImageButton: UIButton! {
        didSet {
            selectImageButton.setTitle(tr.feedback.selectImage, for: .normal)
        }
    }

    @IBOutlet weak var imageView: UIImageView!

    @IBOutlet weak var submitButton: UIButton! {
        didSet {
            submitButton.setTitle(tr.defaultSection.submit, for: .normal)
            submitButton.backgroundColor = UIColor.systemBlue
            submitButton.setTitleColor(.white, for: .normal)
            submitButton.layer.cornerRadius = 8.0
        }
    }

    @IBOutlet weak var pickerView: UIView!

    @IBOutlet weak var feedbackTypePicker: UIPickerView! {
        didSet {
            feedbackTypePicker.dataSource = self
            feedbackTypePicker.delegate = self
        }
    }

    // MARK: - Properties
    private var feedbackTypes: [FeedbackType] = [.bug, .feedback]
    private var selectedFeedbackTypeIndex: Int!
    private var imagePickerController = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = tr.feedback.feedbackTitle
        pickerView.isHidden = true

        //Set initial value selected in UIPicker
        selectedFeedbackTypeIndex = self.feedbackTypes.firstIndex(of: FeedbackType.bug) ?? 0
        guard let selectedFeedbackTypeIndex = selectedFeedbackTypeIndex else { return }
        self.feedbackTypePicker.selectRow(selectedFeedbackTypeIndex, inComponent: 0, animated: true)
        feedbackTypeLabel.text = feedbackTypes[selectedFeedbackTypeIndex].rawValue
    }

    // MARK: - Callbacks -

    @IBAction func pickerCancelButtonTapped(_ sender: Any) {
        pickerView.hideView(mainViewHeight: mainView.frame.size.height)
    }

    @IBAction func pickerDoneButtonTapped(_ sender: Any) {
        feedbackTypeLabel.text = feedbackTypes[selectedFeedbackTypeIndex ?? 0].rawValue
        pickerView.hideView(mainViewHeight: mainView.frame.size.height)
    }


    @IBAction func selectFeedbackTypeButtonTapped(_ sender: Any) {
        self.view.endEditing(true)
        pickerView.showView(mainViewHeight: mainView.frame.size.height)
    }

    @IBAction func selectImageButtonTapped(_ sender: Any) {
        self.view.endEditing(true)
        imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        present(imagePickerController, animated: true)
    }

    @IBAction func submitButtonTapped(_ sender: Any) {
        self.view.endEditing(true)
        sendFeedback()
    }
    
}

// MARK: - UIPickerViewDataSource, UIPickerViewDelegate
extension FeedbackViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return feedbackTypes.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        selectedFeedbackTypeIndex = row
        return feedbackTypes[row].rawValue
    }
}

// MARK: - UIImagePickerControllerDelegate
extension FeedbackViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image: UIImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            imageView.image = image
        }
        imagePickerController.dismiss(animated: true, completion: nil)
    }

    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        imagePickerController.dismiss(animated: true)
    }
}

// MARK: - API call
extension FeedbackViewController {
    func sendFeedback() {
        guard let version =  Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
            return
        }
        NStack.sharedInstance.feedbackManager?.provideFeedback(type: feedbackTypes[selectedFeedbackTypeIndex], appVersion: version, message: messageTextView.text, image: imageView.image, name: nameTextField.text, email: emailTextField.text, completion: { (isCompleted) in
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        })
    }
}
