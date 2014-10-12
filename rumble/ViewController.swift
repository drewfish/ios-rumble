//
//  ViewController.swift
//  rumble
//
//  Created by Andrew Folta on 10/11/14.
//  Copyright (c) 2014 Andrew Folta. All rights reserved.
//

import UIKit


class ViewController: UIViewController {
    @IBOutlet weak var seismoView: SeismoView!
    var seismoModel: SeismoModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        seismoModel = SeismoModel()
        seismoModel?.delegate = seismoView
    }

    override func viewDidAppear(animated: Bool) {
        seismoModel?.start()
    }

    override func viewWillDisappear(animated: Bool) {
        seismoModel?.stop()
    }
}

