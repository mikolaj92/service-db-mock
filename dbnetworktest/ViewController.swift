//
//  ViewController.swift
//  dbnetworktest
//
//  Created by Patryk Mikolajczyk on 05/03/2017.
//  Copyright © 2017 Patryk Mikolajczyk. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // every time you get data from model it takes it directly from db, so while reloading data it's stay fresh. realm is fast enough so dont worry
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    var modelTakeOne: Model? {
        return Model.getModel1()
    }
    
    // view model is lazy loaded once(). it might be different than model. there are no realm models everywhere. there is layer between realm and view controllers.
    lazy var modelTakeTwo: ViewModel2? = {
        return ViewModel2.getModel2()
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        Model.save()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        label1.text = modelTakeOne?.property1
        label2.text = modelTakeTwo?.property1
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

