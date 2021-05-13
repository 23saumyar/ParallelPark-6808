//
//  FinishViewController.swift
//  ParallelPark
//
//  Created by Saumya Rawat on 5/9/21.
//  Copyright © 2021 MIT. All rights reserved.
//

import UIKit

class FinishViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func buttonPressed(_ sender: UIButton) {
        let VC = self.storyboard?.instantiateViewController(withIdentifier: "StartViewController") as! StartViewController
        self.present(VC, animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
