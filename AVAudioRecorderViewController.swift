//
//  AVAudioRecorder.swift
//  AVFoundationDemo
//
//  Created by lokizero00 on 2017/9/14.
//  Copyright © 2017年 lokizero00. All rights reserved.
//

import UIKit
import AVFoundation
//import Speech

class AVAudioRecorderViewController: UIViewController ,AVAudioRecorderDelegate{
    var recorder:AVAudioRecorder?   //录音器
    var player:AVAudioPlayer?       //播放器
    var recorderSettingsDic:[String:AnyObject]?     //录音器设置参数数组
    var volumeTimer:Timer!      //定时器线程，刷新音量
    var aacPath:String?         //录音存储路径
    
    @IBOutlet weak var soundLoadingImageView:UIImageView!   //录音音量显示视图
    
    @IBOutlet weak var downRecordButton:UIButton!
    @IBOutlet weak var playRecordButton:UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        initRecorderParam()
        initScreenViews()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func initScreenViews(){
        downRecordButton.addTarget(self, action: #selector(self.downRecordAction), for: .touchDown)
        downRecordButton.addTarget(self, action: #selector(self.downRecordRelease), for: .touchUpInside)
        soundLoadingImageView.image=UIImage(named: "s0")
        playRecordButton.addTarget(self, action: #selector(self.playAction), for: .touchUpInside)
    }
    
    @objc func playAction(){
        player=nil
        do{
            player=try AVAudioPlayer(contentsOf: URL(fileURLWithPath: aacPath!))
            player?.prepareToPlay()
        }catch{
            print("初始化播放器失败：\(error.localizedDescription)")
        }
        
        if player != nil && !(player?.isPlaying)!{
//            player?.volume=5
            player?.play()
        }
    }
    
    @objc func downRecordAction(){
        //初始化录音器
        do{
            recorder=try AVAudioRecorder(url: URL(fileURLWithPath:aacPath!), settings: recorderSettingsDic!)
            recorder?.isMeteringEnabled=true    //开启仪表计数功能
            
            //准备录音
            recorder?.prepareToRecord()
            
            //开始录音
            recorder?.record()
            
            //启动定时器，定时更新录音音量
            volumeTimer=Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.levelTimer), userInfo: nil, repeats: true)
            
        }catch{
            print("录音器初始化失败：\(error.localizedDescription)")
        }
    }
    
    @objc func downRecordRelease(){
        //停止录音
        recorder?.stop()
        //录制器释放
        recorder=nil
        //暂停定时器
        volumeTimer.invalidate()
        volumeTimer=nil
        
        //界面音量归0
        soundLoadingImageView.image=UIImage(named: "s0")
    }
    
    //更新音量指示器
    @objc func levelTimer(){
        recorder?.updateMeters()    //刷新音量数据
//        let averageV:Float=recorder!.averagePower(forChannel: 0)    //获取音量的平均值
        
        let maxV:Float=recorder!.peakPower(forChannel: 0)   //获取音量的最大值
        
        let lowPassResults:Double=pow(Double(10), Double(0.05*maxV))
        
        if lowPassResults>=0.8 {
            soundLoadingImageView.image=UIImage(named: "s7")
        }else if lowPassResults>=0.7 {
            soundLoadingImageView.image=UIImage(named: "s6")
        }else if lowPassResults>=0.6 {
            soundLoadingImageView.image=UIImage(named: "s5")
        }else if lowPassResults>=0.5 {
            soundLoadingImageView.image=UIImage(named: "s4")
        }else if lowPassResults>=0.4 {
            soundLoadingImageView.image=UIImage(named: "s3")
        }else if lowPassResults>=0.3 {
            soundLoadingImageView.image=UIImage(named: "s2")
        }else if lowPassResults>=0.1 {
            soundLoadingImageView.image=UIImage(named: "s1")
        }else{
            soundLoadingImageView.image=UIImage(named: "s0")
        }
    }
    
    private func initRecorderParam(){
        //初始化录音器
        let session=AVAudioSession.sharedInstance()
        do{
            //设置录音类型
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        }catch{
            print("录音器初始化失败：\(error.localizedDescription)")
        }
        
        do{
            //设置支持后台
            try session.setActive(true)
        }catch{
            print("录音器设置失败：\(error.localizedDescription)")
        }
        
        //获取Document目录
        let docDir=NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        
        //组合录音文件路径
        aacPath=docDir + "/play.aac"
        
        //初始化字典
        recorderSettingsDic=Dictionary()
        
        //为字典添加设置参数
        recorderSettingsDic?.updateValue(NSNumber(value:kAudioFormatMPEG4AAC), forKey: AVFormatIDKey)
        recorderSettingsDic?.updateValue(NSNumber(value:1000), forKey: AVSampleRateKey)
        recorderSettingsDic?.updateValue(NSNumber(value:2), forKey: AVNumberOfChannelsKey)
        recorderSettingsDic?.updateValue(NSNumber(value:8), forKey: AVLinearPCMBitDepthKey)
        recorderSettingsDic?.updateValue(NSNumber(value:false), forKey: AVLinearPCMIsBigEndianKey)
        recorderSettingsDic?.updateValue(NSNumber(value:false), forKey: AVLinearPCMIsFloatKey)
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
