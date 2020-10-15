//
//  ViewController.swift
//  NStackDemo
//
//  Created by Marius Constantinescu on 15/10/2020.
//

import UIKit

class ViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var label: UILabel! {
        didSet {
            label.text = lo.defaultSection.ok
        }
    }

    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

    }




}

