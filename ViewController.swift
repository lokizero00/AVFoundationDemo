//
//  ViewController.swift
//  AVFoundationDemo
//
//  Created by lokizero00 on 2017/9/13.
//  Copyright © 2017年 lokizero00. All rights reserved.
//

import UIKit
import AudioToolbox
import AVFoundation

class ViewController: UIViewController {
    @IBOutlet weak var systemSoundButton:UIButton!
    @IBOutlet weak var systemAlertButton:UIButton!
    @IBOutlet weak var vibrationButton:UIButton!
    @IBOutlet weak var currentTimeLabel:UILabel!
    @IBOutlet weak var allTimeLabel:UILabel!
    @IBOutlet weak var sliderMusic:UISlider!
    @IBOutlet weak var sliderSound:UISlider!
    @IBOutlet weak var playButton:UIButton!
    @IBOutlet weak var pauseButton:UIButton!
    @IBOutlet weak var stopButton:UIButton!
    @IBOutlet weak var currentSoundLabel:UILabel!
    
    var audioPlayer:AVAudioPlayer!
    var _timer:Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        systemSoundButton.addTarget(self, action: #selector(self.systemSound), for: .touchUpInside)
        systemAlertButton.addTarget(self, action: #selector(self.systemAlert), for: .touchUpInside)
        vibrationButton.addTarget(self, action: #selector(self.systemVibration), for: .touchUpInside)
        
        sliderMusic.addTarget(self, action: #selector(self.sliderMusicValueChanged), for: .valueChanged)
        sliderSound.addTarget(self, action: #selector(self.sliderSoundValueChanged), for: .valueChanged)
        
        playButton.addTarget(self, action: #selector(self.audioPlay), for: .touchUpInside)
        pauseButton.addTarget(self, action: #selector(self.audioPause), for: .touchUpInside)
        stopButton.addTarget(self, action: #selector(self.audioStop), for: .touchUpInside)
        
        prepareAudioPlayer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func systemSound(){
        var soundID:SystemSoundID=0
        let path=Bundle.main.path(forResource: "shake", ofType: "caf")
        
        let baseURL=NSURL(fileURLWithPath: path!)
        
        AudioServicesCreateSystemSoundID(baseURL, &soundID)
        
        AudioServicesPlaySystemSound(soundID)
    }
    
    func systemAlert(){
        var soundID:SystemSoundID=0
        let path=Bundle.main.path(forResource: "shake", ofType: "caf")
        
        let baseURL=NSURL(fileURLWithPath:path!)
        
        AudioServicesCreateSystemSoundID(baseURL, &soundID)
        
        AudioServicesPlayAlertSound(soundID)
        
    }
    
    func systemVibration(){
        let soundID=SystemSoundID(kSystemSoundID_Vibrate)
        
        AudioServicesPlaySystemSound(soundID)
    }
    
    func audioPlay(){
        if audioPlayer.isPlaying {
            return
        }
        
        audioPlayer.play()
        
        sliderMusic.minimumValue=0.0
        sliderMusic.maximumValue=Float(audioPlayer.duration)
        sliderSound.minimumValue=0.0
        sliderSound.maximumValue=10
        
        currentSoundLabel.text="\(audioPlayer.volume)"
        
        _timer=Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.updateTime), userInfo: nil, repeats: true)
        
        
    }
    
    func audioPause(sender:UIButton){
        let title=sender.title(for: .normal)
        if title == "Pause" && audioPlayer.isPlaying {
            audioPlayer.pause()
            sender.setTitle("Continue", for: .normal)
        }else if title=="Continue" {
            sender.setTitle("Pause", for: .normal)
            audioPlayer.play()
        }
    }
    
    func audioStop(){
        if audioPlayer.isPlaying {
            audioPlayer.stop()
            audioPlayer.currentTime=0
            currentTimeLabel.text="00:00:00"
            allTimeLabel.text="00:00:00"
        }
    }
    
    func sliderSoundValueChanged(sender:UISlider){
        audioPlayer.volume=sender.value
        currentSoundLabel.text="\(sender.value)"
    }
    
    func prepareAudioPlayer(){
        let mp3Path=Bundle.main.path(forResource: "your memory", ofType: "mp3")
        let fileUrl=URL(fileURLWithPath: mp3Path!)
        
        do{
            audioPlayer=try AVAudioPlayer(contentsOf: fileUrl)
        }catch{
            print("初始化播放器失败：\(error.localizedDescription)")
        }
        
        audioPlayer.prepareToPlay()
    }
    
    func updateTime(){
        let cuTime:Float=Float(audioPlayer.currentTime)
        
        sliderMusic.value=cuTime
        
        let duTime:Float=Float(audioPlayer.duration)
        
        let hour1:Int=Int(cuTime/(60*60))
        let minute1:Int=Int(cuTime/60)
        let second1:Int=Int(cuTime.truncatingRemainder(dividingBy: 60))
        
        let hour2:Int=Int(duTime/(60*60))
        let minute2:Int=Int(duTime/60)
        let second2:Int=Int(duTime.truncatingRemainder(dividingBy: 60))
        
        currentTimeLabel.text=NSString(format: "%.2d:%.2d:%.2d", hour1,minute1,second1) as String
        allTimeLabel.text=NSString(format: "%.2d:%.2d:%.2d", hour2,minute2,second2) as String
    }
    
    func sliderMusicValueChanged(sender:UISlider){
        audioPlayer.currentTime=TimeInterval(sender.value)
        audioPlayer.play()
    }

    @IBAction func goToRecord(_ sender: UIButton) {
        let nextCtl=AVAudioRecorderViewController(nibName: "AVAudioRecorderViewController", bundle: Bundle.main)
        self.present(nextCtl, animated: true, completion: nil)
    }
    
    @IBAction func goToVideo(_ sender: UIButton) {
        let nextCtl=AVPlayerMainViewController(nibName: "AVPlayerMainViewController", bundle: Bundle.main)
        self.present(nextCtl, animated: true, completion: nil)
    }

}

extension ViewController:AVAudioPlayerDelegate{
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("成功播放结束")
    }
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("音频解码错误")
    }
}

