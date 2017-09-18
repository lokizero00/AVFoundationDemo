//
//  MediaPlayerViewController.swift
//  AVFoundationDemo
//
//  Created by lokizero00 on 2017/9/14.
//  Copyright © 2017年 lokizero00. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class AVPlayerCustomViewController: UIViewController {
    //播放器容器
    @IBOutlet weak var containerView:UIView!
    //播放/暂停按钮
    @IBOutlet weak var playOrPauseButton:UIButton!
    //播放进度
    @IBOutlet weak var progress:UIProgressView!
    //显示播放时间
    @IBOutlet weak var timeLabel:UILabel!
    
    //播放器对象
    var player:AVPlayer?
    //播放资源对象
    var playerItem:AVPlayerItem?
    //时间观察者
    var timeObserver:Any!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createUI()
    }
    
    func addPlayerToAVPlayerLayer(){
        //获取本地视频资源
        guard let path=Bundle.main.path(forResource: "sample01", ofType: "mp4") else{
            return
        }
        
        //播放本地视频
        let url=URL(fileURLWithPath: path)
        //播放网络视频
        // let url = NSURL(string: path)!
        
        playerItem=AVPlayerItem(url: url)
        player=AVPlayer(playerItem: playerItem)
        
        //创建视频播放器图层对象
        let playerLayer=AVPlayerLayer(player: player)
        playerLayer.frame=containerView.bounds
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill //视频填充模式
        containerView.layer.addSublayer(playerLayer)
        
        addProgressObserver()
        addObserver()
    }
    
    //给播放器添加进度更新
    func addProgressObserver(){
        //这里设置每秒执行一次.
        timeObserver=player?.addPeriodicTimeObserver(forInterval: CMTimeMake(Int64(1.0), Int32(1.0)) , queue: DispatchQueue.main, using: {
            [weak self] (time:CMTime) in
            //CMTimeGetSeconds函数是将CMTime转换为秒，如果CMTime无效，将返回NaN
            let currentTime=CMTimeGetSeconds(time)
            let totalTime=CMTimeGetSeconds(self!.playerItem!.duration)
            //更新显示的时间和进度条
            self!.timeLabel.text=self!.formatPlayTime(seconds: CMTimeGetSeconds(time))
            self!.progress.setProgress(Float(currentTime/totalTime), animated: true)
        })
    }
    
    //给AVPlayerItem、AVPlayer添加监控
    func addObserver(){
        //为AVPlayerItem添加status属性观察，得到资源准备好，开始播放视频
        playerItem?.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        //监听AVPlayerItem的loadedTimeRanges属性来监听缓冲进度更新
        playerItem?.addObserver(self, forKeyPath: "loadedTimeRanges", options: .new, context: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.playItemDidReachEnd(notification:)), name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
    }
    
    //将秒转成时间字符串的方法，因为我们将得到秒。
    func formatPlayTime(seconds:Float64)->String{
        let Min=Int(seconds/60)
        let Hor=Int(seconds/(60*60))
        let Sec=Int(seconds.truncatingRemainder(dividingBy: 60))
        return String(format: "%02d:%02d:%02d", Hor,Min,Sec)
    }
    
    //UI初始化
    func createUI(){
        playOrPauseButton.addTarget(self, action: #selector(self.playOrPauseButtonClicked), for: .touchUpInside)
        addPlayerToAVPlayerLayer()
    }
    
    //点击播放/暂停按钮
    func playOrPauseButtonClicked(button:UIButton){
        if let player=player{
            if player.rate==0{  //点击时已暂停
                button.setImage(UIImage(named:"pause"), for: .normal)
                player.play()
            }else if player.rate == 1{  //点击时正在播放
                player.pause()
                button.setImage(UIImage(named:"play"), for: .normal)
            }
        }
    }
    
    //播放结束，回到最开始位置，播放按钮显示带播放图标
    func playItemDidReachEnd(notification:Notification){
        player?.seek(to: kCMTimeZero, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
        progress.progress=0.0
        playOrPauseButton.setImage(UIImage(named:"play"), for: .normal)
    }
    
    ///  通过KVO监控播放器状态
    ///
    /// - parameter keyPath: 监控属性
    /// - parameter object:  监视器
    /// - parameter change:  状态改变
    /// - parameter context: 上下文
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let object=object as? AVPlayerItem else {return}
        guard let keyPath=keyPath else {return}
        if keyPath == "status"{
            if object.status == .readyToPlay {  //当资源准备好播放，那么开始播放视频
//                player?.play()
//                print("正在播放...，视频总长度:\(formatPlayTime(seconds: CMTimeGetSeconds(object.duration)))")
            }else if object.status == .failed || object.status == .unknown {
                print("播放器出错")
            }else if keyPath=="loadedTimeRanges"{
                let loadedTime=avalableDurationWithPlayerItem()
                print("当前加载进度\(loadedTime)")
            }
        }
    }
    
    //计算当前的缓冲进度
    func avalableDurationWithPlayerItem()->TimeInterval{
        guard let loadedTimeRanges=player?.currentItem?.loadedTimeRanges, let first = loadedTimeRanges.first else{
            fatalError()
        }
        
        let timeRange=first.timeRangeValue
        let startSeconds=CMTimeGetSeconds(timeRange.start)  //本次缓冲起始时间
        let durationSecond=CMTimeGetSeconds(timeRange.duration) //缓冲时间
        let result=startSeconds + durationSecond    //缓冲总长度
        return result
    }
    
    //去除观察者 
    func removeObserver(){
        playerItem?.removeObserver(self, forKeyPath: "status")
        playerItem?.removeObserver(self, forKeyPath: "loadedTimeRanges")
        player?.removeTimeObserver(timeObserver)
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
    }
    
    deinit {
        removeObserver()
    }
    
    @IBAction func backClicked(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
