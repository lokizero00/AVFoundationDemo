//
//  AVPlayerMainViewController.swift
//  AVFoundationDemo
//
//  Created by lokizero00 on 2017/9/15.
//  Copyright © 2017年 lokizero00. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class AVPlayerMainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func videoPlayer1Clicked(_ sender: UIButton) {
        let videoPathURL=URL(fileURLWithPath:Bundle.main.path(forResource: "sample01", ofType: "mp4")!)
        var videoPlayer:AVPlayer!
        videoPlayer=AVPlayer(url: videoPathURL)
        let playerViewController=AVPlayerViewController()
        playerViewController.player=videoPlayer
        self.present(playerViewController, animated: true, completion: {
            playerViewController.player?.play()
        })
    }

    @IBAction func videoPlayer2Clicked(_ sender: UIButton) {
        let customController=AVPlayerCustomViewController(nibName: "AVPlayerCustomViewController", bundle: Bundle.main)
        self.present(customController, animated: true, completion: nil)
    }
    
    @IBAction func backClicked(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
