//
//  StartViewController.swift
//  ParallelPark
//
//  Created by Saumya Rawat on 5/9/21.
//  Copyright © 2021 MIT. All rights reserved.
//

import UIKit
import AVFoundation

class StartViewController: UIViewController {
    
    override func viewDidLoad() {
        let utterance = AVSpeechUtterance(string: "Welcome to Parallel Park Helper! Click start to look for a space!")
        utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
        
        super.viewDidLoad()
        
        // Speak text
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func start(sender: UIButton) {
        print(sender.tag.description)
        let VC = self.storyboard?.instantiateViewController(withIdentifier: "InProgressViewController") as! InProgressViewController
        self.present(VC, animated: true, completion: nil)

    }
    
    
    // code for UI state changes
    
//    func starting() {
//
//    }
   
//    # if user clicks start, state = 1
//
//    # state 1 - preparing starting position
//
//    # while in state 1:
//        # if mirror in range (3ft+threshold) and side in range (3ft+threshold):
//            # store IMU measurements to determine straightness later
//            # command user to begin backing up until the back measurement goes over 3 ft
//            # switch state
//
//        # if mirror in range and side > (3ft+threshold):
//            # command user to move up until both sensors have measurements in range
//
//        # if mirror > (3ft+threshold) and side in range
//            # command user to back up until both sensors have measurements in range
//
//        # else:
//            # command user to pull up about 3 feet from the car in front of the desired parking spot and try again
//
//
//    # state 2 - backing up until ready to turn wheel
//
//    # while in state 2:
//        # if mirror in range (3ft+threshold) and side in range (3ft+threshold):
//            # command user to begin backing up until the back measurement goes over 3 ft
//            # switch to state 3
//
//        # else if mirror in range and side > range:
//            # command user to turn the wheel one full rotation to the right, making sure no cars are coming, and then start moving backwards slowly
//
//        # else:
//            # print your position doesn't seem right, perhaps try again
//            # switch to state 1
//
//
//    # state 3 - backing up diagonally into spot
//
//    # while in state 3:
//        # check angle
//        # if angle ~ 45 degrees
//            # mirror < (1ft+threshold) or distance starts increasing:
//                # command user to stop, mirror should be at vehicle's tail light
//                # command user to rotate wheel fully to the left and continue backing up until IMU measurements match OG measurements indicating straightened out
//                # command user to straighten wheel
//                # switch to state 4
//        # if angle > 45 degrees:
//            # command user to turn wheel a little in (?) direction
//        # if angle < 45 degrees:
//            # command user to turn wheel a little in (?) direction
//
//
//    # state 4 - straighten wheel and center
//
//    # while in state 4:
//        # if abs(front-back) < threshold (?):
//            # print congratulations!
//            # switch to state 5
//        # else if front > back:
//            # slowly back up
//        # else if back > front:
//            # slowly inch up
//
//
//    # state 5 - completed
//
//    # display completed screen
//
//
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    

}
