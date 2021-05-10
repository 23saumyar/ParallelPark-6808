//
//  StartViewController.swift
//  ParallelPark
//
//  Created by Saumya Rawat on 5/9/21.
//  Copyright © 2021 MIT. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {
    
    override func viewDidLoad() {
        print("start screen loaded")
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func start(sender: UIButton) {
        print(sender.tag.description)
        let VC = self.storyboard?.instantiateViewController(withIdentifier: "InProgressViewController") as! InProgressViewController
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
