//
//  FirstViewController.swift
//  FlappyBird-ios
//
//  Created by Wei Lun Hsu on 2020/10/18.
//

import UIKit

class FirstViewController: UIViewController {

    @IBAction func toGameViewAction(_ sender: UIButton) {
        self.performSegue(withIdentifier: "toGameView", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
}
