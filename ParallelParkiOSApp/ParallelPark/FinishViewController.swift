//
//  FinishViewController.swift
//  ParallelPark
//
//  Created by Saumya Rawat on 5/9/21.
//  Copyright © 2021 MIT. All rights reserved.
//

import UIKit
import AVFoundation


class FinishViewController: UIViewController {

    var textSent:String = ""
    @IBOutlet weak var textLabel:UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textLabel?.text = textSent

        speak(text: textSent)

        // Do any additional setup after loading the view.
    }

    @IBAction func buttonPressed(_ sender: UIButton) {
        let VC = self.storyboard?.instantiateViewController(withIdentifier: "StartViewController") as! StartViewController
        self.present(VC, animated: true, completion: nil)
    }
    
    func speak(text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
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
