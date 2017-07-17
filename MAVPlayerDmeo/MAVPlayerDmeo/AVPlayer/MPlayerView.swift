//
//  MPlayerView.swift
//  BangDemo
//
//  Created by yizhilu on 2017/6/28.
//  Copyright © 2017年 Magic. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

/**
 * 定义两个枚举:
 *  1.PanDirection手势:包含水平移动方向和垂直移动方向
 *  2.PlayerStatus播放状态:播放,暂停,缓存等
 **/

/// 滑动手势
///
/// - PanDirectionHorizontalMoved: 横向移动
/// - PanDirectionVerticalMoved: 纵向移动
enum PanDirection{
    case HorizontalMoved
    
    case VerticalMoved
}

/// 播放器状态
///
/// - PlayerBuffering: 正在缓冲
/// - PlayerReadyToPlay: 准备播放
/// - PlayerPlaying: 正在播放状态
/// - PlayerPaused: 播放暂停状态
/// - PlayerComplete: 播放完成
/// - PlayerFaild: 播放失败
enum PlayerStatus {
    case PlayerBuffering
    case PlayerReadyToPlay
    case PlayerPlaying
    case PlayerPaused
    case PlayerComplete
    case PlayerFaild
}

/// 播放器两个代理事件
@objc protocol MPlayerViewDelegate {
    
    func closePlayer()
    func setBackgroundTime(_ currTime:Float,_ totTime:Float)
}
final class MPlayerView: UIView,UIGestureRecognizerDelegate {
    /** *播放器*/
    var player : AVPlayer?
    private var playerItem : AVPlayerItem?
    private var playerLayer : AVPlayerLayer?
    weak var mPlayerDelegate : MPlayerViewDelegate?
    /** *用来保存快进的总时长 */
    private var sumTime : CMTime?
    /** *快进快退显示label */
    private var horizontalLabel : UILabel?
    /** *手势,枚举 */
    private var panDirection : PanDirection?
    /** *是否在调节音量 */
    private var isVolume = Bool()
    /** *声音进度条 */
    private var volumeViewSlider : UISlider?
    /** *播放器状态 */
    var status : PlayerStatus?
    /** *音频背景 */
    var musicBackGround : UIImageView?
    /** *顶部背景 */
    private var topImageView : UIImageView?
    /** *关闭按钮 */
    private var closeBtn : UIButton?
    /** *本地倍速按钮 */
    private var rateBtn : UIButton?
    /** *本地倍速展示 */
    var ratelabel : UILabel?
    /** *音频视频切换，倍速三个按钮 */
    var rateView : RateView?
    /** *中间暂停按钮 */
    var centerPlayOrPauseBtn : UIButton?
    /** *锁定屏幕 */
    private var lockBtn : UIButton?
    /** *切换线路 */
    private var switchCircuitView : SwitchCircuitView?
    /** *重播 */
    private var repeatBtn : UIButton?
    /** *底部遮罩 */
    private var bottomImageView : UIImageView?
    /** *底部播放暂停播放按钮 */
    private var playOrPauseBtn : UIButton?
    /** *全屏播放按钮 */
    private var fullScreenBtn : UIButton?
    /** *当前时间 */
    private var currentTimeLB : UILabel?
    /** *总时间 */
    private var totalTimeLB : UILabel?
    /** *时间滑动条 */
    private var slider : UISlider?
    /** *清晰度按钮 */
    var resolutionBtn : UIButton?
    /** *菊花 */
    private var activeView : UIActivityIndicatorView?
    /** *提示文字,快进快退 */
    private var activeLB : UILabel?
    /** *切换到视频 */
    var exchangeVideoBtn : UIButton?
    /** *视频非解析的码 */
    var videoParseCode : String?
    /** *视频类型 */
    var videoType : String?
    /** *清晰度 */
    var chanel : Int32?
    /** *是否为本地视频 */
    var isLOCAL = Bool()
    /** *当前时长 */
    final var currentTime : NSInteger?
    /** *总时长 */
    final var totalTime : NSInteger?
    /** *显示控制层定时器 */
    private var timer : Timer?
    /** *是否正在拖动进度条 */
    private var progressDragging : Bool?
    /** *控制层是否显示 */
    private var controlViewIsShowing : Bool?
    /** *是否锁屏屏幕 */
    private var isLocked = Bool()
    /** *是否全屏 */
    private var isFullScreen = Bool()
    /** *时间观察 */
    private var timeObserve : Any?
    private var resolutionView : ResolutionView?
    /** *是否播放完毕 */
    var playEnd = Bool()
    /** *当前倍速 */
    var rateValue : Float?
    
    /// 创建播放器单例
    static let shared = MPlayerView()
    private override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
     /// 初始化播放器视图
     ///
     /// - Parameters:
     ///   - frame: 播放器尺寸
     ///   - url: videoUrl(hhtp://非加密链接)
     ///   - type: 类型:音频 || 视频
     ///   - parseString: 需要解析的码
     func initWithFrame(frame:CGRect,videoUrl:String,type:String) -> MPlayerView {
        self.backgroundColor = UIColor.black
        //开启屏幕旋转
        let appde = UIApplication.shared.delegate as! AppDelegate
        appde.allowRotation = true
        self.frame = frame
        self.videoType = type
        rateValue = 1.0
        chanel = CHANNEL_HIGH
        isFullScreen = false
        isLocked = false
        self.status = .PlayerBuffering
        ///屏幕旋转监听
        self.listeningRotating()
        ///页面布局,菊花,倒计时
        self.playWithUrl(url: videoUrl)
        ///增加点击手势
        self.addGesture()
        ///增加滑动手势
        self.addPanGesture()
        ///获取系统音量
        self.configureVolume()
        ///亮度,视图暂时没有做
        return self
    }
    
    
    /*
     * 初始化playerItem,play
     *
     */
    private func playWithUrl(url:String){
        self.playerItem = getPlayItemWithURLString(url: url)
        self.player = AVPlayer.init(playerItem: self.playerItem)
        self.playerLayer = AVPlayerLayer.init(player: self.player)
        self.playerLayer?.frame = self.layer.bounds
        self.playerLayer?.videoGravity = AVLayerVideoGravityResize
        self.layer.addSublayer(playerLayer!)
        self.player?.play()
        ///页面布局
        self.makeSubViewsConstraints()
        ///开启菊花
        self.startAnimation()
        
    }
    
    /*
     * 初始化playerItem
     */
    private func getPlayItemWithURLString(url:String) -> AVPlayerItem{

        let Item = AVPlayerItem.init(url: NSURL.init(string: url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlPathAllowed)!)! as URL)
        
        if playerItem == Item {
            return playerItem!
        }
        
        if (playerItem != nil) {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
            playerItem?.removeObserver(self, forKeyPath: "status")
            playerItem?.removeObserver(self, forKeyPath: "loadedTimeRanges")
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(moviePlayDidEnd(note:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: Item)
        Item.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.new, context: nil)
        Item.addObserver(self, forKeyPath: "loadedTimeRanges", options: NSKeyValueObservingOptions.new, context: nil)
        return Item
    }
    
    /*
     * 切换视频调用方法
     */
    func exchangeWithURL(videoURLStr:String)  {
        
        self.playerItem = self.getPlayItemWithURLString(url: videoURLStr)
        self.player?.replaceCurrentItem(with: self.playerItem)
        self.player?.seek(to: CMTimeMake(Int64(currentTime!), 1))
        self.player?.rate = self.rateValue!
//        self.player?.play()
    }
    
    //MARK: - 播放器手势添加与创建
    /*
     * 增加单点手势
     */
    private func addGesture(){
        let oneRecognizer = UITapGestureRecognizer()
        oneRecognizer.addTarget(self, action: #selector(tapOneClick(gesture:)))
        self.addGestureRecognizer(oneRecognizer)
    }
    
    /*
     * 添加平移手势，用来控制音量、亮度、快进快退
     */
    private func addPanGesture(){
        let panGest = UIPanGestureRecognizer.init(target: self, action: #selector(panDirection(pan:)))
        self.addGestureRecognizer(panGest)
        
    }
    
    /*
     * 手势点击事件
     */
    @objc private func tapOneClick(gesture:UIGestureRecognizer){
        if !playEnd {
            if controlViewIsShowing! {
                hideControlView()
                cancleDelay()
                controlViewIsShowing = false
            }else{
                self.showControlView()
                controlViewIsShowing = true
            }
        }else{
            self.closeBtn?.isHidden = false
        }
    }
    
    /*
     * Pan手势事件
     */
    @objc private func panDirection(pan:UIPanGestureRecognizer){
        if (!(self.repeatBtn?.isHidden)!) {
            return
        }
        /// 获取手指点在屏幕上的位置
        let locationPoint = pan.location(in: self)
        /// 根据上次和本次移动的位置，算出一个速率的point
        let veloctyPoint = pan.velocity(in: self)
        switch pan.state {
        case .began:
            /// 使用绝对值来判断移动的方向
            let x = fabs(veloctyPoint.x)
            let y = fabs(veloctyPoint.y)
            if x > y {
                self.horizontalLabel?.isHidden = false
                self.panDirection = PanDirection.HorizontalMoved
                /// 给sumTime初值
                let time = self.player?.currentTime()
                self.sumTime = CMTimeMake((time?.value)!, (time?.timescale)!)
                ///暂停视频播放
                self.player?.pause()
            }else if x < y {
                self.panDirection = .VerticalMoved
                /// 开始滑动的时候,状态改为正在控制音量
                if locationPoint.x > self.bounds.size.width/2 {
                    self.isVolume = true
                }else{
                    self.isVolume = false
                }
            }
            break
        case .changed:
            switch self.panDirection! {
            case .HorizontalMoved:
                /// 移动中一直显示快进label
                self.horizontalLabel?.isHidden = false
                /// 水平移动的方法只要x方向的值
                self.horizontalMoved(value: veloctyPoint.x)
                break
            case .VerticalMoved:
                ///垂直移动方法只要y方向的值
                self.verticalMoved(value: veloctyPoint.y)
                break
            }
            break
        case .ended:
            switch self.panDirection! {
            case .HorizontalMoved:
                
                self.player?.play()
                self.horizontalLabel?.isHidden = true
                ///快进、快退时候把开始播放按钮改为播放状态
                self.seekTime(dragedTime: self.sumTime!)
                self.sumTime = CMTime.init(seconds: 0.0, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
                break
            case.VerticalMoved:
                self.isVolume = false
                self.horizontalLabel?.isHidden = true
                break;
                
            }
            break
        default:
            break
        }
        
        
    }
    
    /*
     * 手势:水平移动
     */
    private func horizontalMoved(value:CGFloat){
        ///开启菊花
        self.startAnimation()
        var style = String()
        if value < 0 {
            style = "<<"
        }
        if value > 0 {
            style = ">>"
        }
        if value == 0 {
            return
        }
        /// 将平移距离转成CMTime格式
        let addend = CMTime.init(seconds: Double.init(value/200), preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        
        self.sumTime = CMTimeAdd(self.sumTime!, addend)
        /// 总时间
        let totalTime = self.playerItem?.duration
        
        let totalMovieDuration = CMTimeMake((totalTime?.value)!, (totalTime?.timescale)!)
        
        if self.sumTime! > totalMovieDuration {
            self.sumTime = totalMovieDuration
        }
        ///最小时间0
        let small = CMTime.init(seconds: 0.0, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        if self.sumTime! < small {
            self.sumTime = small
        }
        
        let nowTime = self.timeStringWithTime(times: NSInteger(CMTimeGetSeconds(self.sumTime!)))
        let durationTime = self.timeStringWithTime(times: NSInteger(CMTimeGetSeconds(totalMovieDuration)))
        
        self.horizontalLabel?.text = String.init(format: "%@ %@ / %@",style, nowTime, durationTime)
        let sliderTime = CMTimeGetSeconds(self.sumTime!)/CMTimeGetSeconds(totalMovieDuration)
        self.slider?.value = Float.init(sliderTime)
        self.currentTimeLB?.text = nowTime
    }
    
    /*
     * 手势:上下移动
     */
    private func verticalMoved(value:CGFloat){
        
        self.isVolume ? (self.volumeViewSlider?.value -= Float(value / 10000)) : (UIScreen.main.brightness -= value / 10000)
    }
    
    /*
     * 时间转化
     */
    private func timeStringWithTime(times:NSInteger) -> String{
        let min = times / 60
        let sec = times % 60
        let timeString = String.init(format: "%02zd:%02zd", min,sec)
        return timeString
    }
    
    /*
     * 从XXX秒开始播放视频
     */
    private func seekTime(dragedTime:CMTime){
        
        if self.player?.currentItem?.status == .readyToPlay {
            self.player?.seek(to: dragedTime, completionHandler: { (finished) in
                self.player?.play()
            })
        }
    }
    
    /*
     * 获取系统音量
     */
    private func configureVolume(){
        let volumeView = MPVolumeView()
        volumeViewSlider = nil
        for view in volumeView.subviews {
            if NSStringFromClass(view.classForCoder) == "MPVolumeSlider" {
                volumeViewSlider = view as? UISlider
                break
            }
        }
    
        ///监听耳机插入和拔掉通知
        NotificationCenter.default.addObserver(self, selector: #selector(audioRouteChangeListenerCallback(notification:)), name: NSNotification.Name.AVAudioSessionRouteChange, object: nil)
    }
    
    /*
     * 耳机监听拔插事件
     */
    @objc private func audioRouteChangeListenerCallback(notification:NSNotification){
        
        let interuptionDict = notification.userInfo! as NSDictionary
        let routeChangeReason = interuptionDict.value(forKey: AVAudioSessionRouteChangeReasonKey) as! AVAudioSessionRouteChangeReason
        switch routeChangeReason {
        case .newDeviceAvailable:
            // 耳机插入
            break
        case .oldDeviceUnavailable:
            // 耳机拔掉
            self.player?.play()
            break
        default:
            break
        }
    }
    
    //MARK: - 延迟延迟与显示控制层
    /*
     * 延时5秒隐藏控制层
     */
    private func DelayOperation()  {
        self.timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(hideControlView), userInfo: nil, repeats: false)
    }
    
    /*
     * 暂停倒计时
     */
    @objc private func cancleDelay(){
        if (self.timer != nil) {
            self.timer?.invalidate()
            self.timer = nil
        }
    }
    
    /*
     * 隐藏控制层
     */
    @objc private func hideControlView(){
        UIView.animate(withDuration: 0.35) { 
            self.controlViewIsShowing = false
            self.bottomImageView?.alpha = 0.0
            if self.playEnd {
                self.topImageView?.alpha = 1.0
            }else{
                self.topImageView?.alpha = 0.0
            }
            self.lockBtn?.isHidden = true
            self.rateView?.isHidden = true
            self.resolutionView?.isHidden = true
            self.switchCircuitView?.isHidden = true
            self.centerPlayOrPauseBtn?.isHidden = true
            self.closeBtn?.isHidden = true
        }
        
        cancleDelay()
        
    }

    /*
     *  显示控制层
     */
    @objc private func showControlView(){
        UIView.animate(withDuration:0.35) { [weak self] in
            self?.controlViewIsShowing = true
            self?.bottomImageView?.alpha = 1.0
            self?.topImageView?.alpha = 1.0
            self?.lockBtn?.isHidden = false
            self?.rateView?.isHidden = (self?.isLOCAL)! ? true : false
            self?.centerPlayOrPauseBtn?.isHidden = false
            self?.switchCircuitView?.isHidden = (self?.isLOCAL)! ? true : false
            self?.closeBtn?.isHidden = false
            if(!(self?.isFullScreen)!){
                self?.resolutionView?.isHidden = true
            }
        }
        
        self.DelayOperation()
        
    }
    
    //MARK:公共方法
    /*
     * 开启菊花
     */
    private func startAnimation(){
        self.activeView?.startAnimating()
        self.activeLB?.isHidden = false
        self.centerPlayOrPauseBtn?.isHidden = true
    }
    
    /*
     * 关闭菊花
     */
    private func stopAnimation(){
        self.activeView?.stopAnimating()
        self.centerPlayOrPauseBtn?.isHidden = controlViewIsShowing! ? false : true
        self.activeLB?.isHidden = true

    }

    /*
     * 播放器关闭
     */
    private func closPlaer(){
        let appde = UIApplication.shared.delegate as! AppDelegate
        appde.allowRotation = false
        NotificationCenter.default.removeObserver(self)
        if (self.timeObserve != nil) {
            self.player?.removeTimeObserver(self.timeObserve as Any)
            self.timeObserve = nil
        }
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
        playerItem?.removeObserver(self, forKeyPath: "status")
        playerItem?.removeObserver(self, forKeyPath: "loadedTimeRanges")
        self.player?.currentItem?.cancelPendingSeeks()
        self.player?.currentItem?.asset.cancelLoading()
        self.player?.pause()
        self.removeFromSuperview()
        self.player?.replaceCurrentItem(with: nil)
        self.player = nil
        self.playerItem = nil
    }
    
    //MARK:播放器属性添加与监听
    /*
     * item播放完毕通知
     */
    @objc private func moviePlayDidEnd(note:Notification){
        hideControlView()
        self.repeatBtn?.isHidden = false
        self.playEnd = true
        topImageView?.alpha = 1.0
        self.status = .PlayerComplete
    }
   
    /*
     * 添加属性观察
     */
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "status" {
            let status = playerItem!.status
            switch status {
            case .readyToPlay:
                self.playerItem?.audioTimePitchAlgorithm = AVAudioTimePitchAlgorithmTimeDomain
                self.status! = .PlayerReadyToPlay
                stopAnimation()
                //时间刷新,倍速
                addTimeObserve()
                enableAudioTracks(isable: true, playerItem: self.playerItem!)
                break
            case .failed:
                self.status! = .PlayerFaild
                break
            default:
                break
            }
        }else if keyPath == "loadedTimeRanges"{
            self.repeatBtn?.isHidden = true
            
        }
    }
    
    /*
     * 实时刷新数据
     */
    private func addTimeObserve(){
        self.timeObserve = self.player?.addPeriodicTimeObserver(forInterval: CMTimeMake(1, 1), queue: nil, using: { [weak self](time) in
            if #available(iOS 10.0, *) {
                if self?.player?.timeControlStatus == .playing {
                    self?.status = PlayerStatus.PlayerPlaying
                }else if self?.player?.timeControlStatus == .paused {
                    self?.status = PlayerStatus.PlayerPaused
                }else if self?.player?.timeControlStatus == .waitingToPlayAtSpecifiedRate {
                    self?.status = PlayerStatus.PlayerBuffering
                }
            }
            if (self?.playerItem != nil) {
                let currentItem = self?.playerItem
                let currentTime = CMTimeGetSeconds((currentItem?.currentTime())!)
                let totalTime = CMTimeGetSeconds(CMTimeMake((currentItem?.duration.value)!, (currentItem?.duration.timescale)!))
                ///代理实现
                self?.mPlayerDelegate?.setBackgroundTime(Float(currentTime), Float(totalTime))
                if (currentItem?.seekableTimeRanges.count)! > 0 && (currentItem?.duration.timescale)! != 0 {
                    self?.totalTime = NSInteger(totalTime)
                    self?.currentTime = NSInteger(currentTime)
                    let currentTimeString = self?.timeStringWithTime(times: NSInteger(currentTime))
                    let totalTimeString = self?.timeStringWithTime(times: NSInteger(totalTime))
                    self?.slider?.value = Float(currentTime / totalTime)
                    self?.currentTimeLB?.text = currentTimeString
                    self?.totalTimeLB?.text = totalTimeString
                }

            }
            
        })
    }
    
    /*
     * 倍速调用
     */
    private func enableAudioTracks(isable:Bool,playerItem:AVPlayerItem){
        for track in playerItem.tracks {
            if track.assetTrack.mediaType == AVMediaTypeAudio {
                track.isEnabled = isable
            }
        }
    }
    
    
    
    //MARK:按钮点击事件
    /*
     * 中间大按钮播放暂停
     */
    @objc private func playOrPauseButtonClick(sender:UIButton){
        
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            self.player?.pause()
        }else{
            self.player?.play()
        }
    }
    
    /*
     * 本地切倍速
     */
    @objc private func clickRateBtnEvent(){
        
        self.rateValue! += 0.2
        if self.rateValue! >= 1.2 && self.rateValue! < 1.3 {
            self.rateValue = 1.2
        }else if self.rateValue! >= 1.4 && self.rateValue! < 1.5 {
            self.rateValue = 1.5
        }else if self.rateValue! > 1.5 {
            self.rateValue = 1.0
        }
        
        self.player?.rate = self.rateValue!
        if isLOCAL {
            rateBtn?.setImage(MIMAGE("选中倍速"), for: .normal)
            ratelabel?.textColor = UIColorFromRGB(0xf6a54a)
            ratelabel?.text = String.init(format: "倍速 %.1fx", self.rateValue!)
            
        }else{
            rateView?.rateLB?.text = String.init(format: "倍速 %.1fx", self.rateValue!)
            rateView?.videoLB?.textColor = Whit
            rateView?.audioLB?.textColor = Whit
            rateView?.rateLB?.textColor = UIColorFromRGB(0xf6a54a)
            rateView?.rateBtn?.setImage(MIMAGE("选中倍速"), for: .normal)
            rateView?.audioBtn?.setImage(MIMAGE("音频"), for: .normal)
            rateView?.videoBtn?.setImage(MIMAGE("视频"), for: .normal)
            
        }
    }
    
    /*
     *高清度页面显示与否
     */
    @objc private func resolutionBtnClick(button:UIButton){
        if videoType == "VIDEO" {
            if (self.resolutionView?.isHidden)! {
               self.resolutionView?.isHidden = false
            }else{
                self.resolutionView?.isHidden = true
            }
        }
    }

    /*
     * 重播按钮
     */
    @objc private func repeatBtnClick(button:UIButton){
        button.isSelected = !button.isSelected
        self.playEnd = false
        ParsingEncrypteString().parseStringWith(urlString: self.videoParseCode!, fileType: self.videoType!
        , isLocal: isLOCAL) { [weak self](url) in
            self?.playWithUrl(url: url)
        }
    }
    
    /*
     *  全屏按钮点击事件
     */
    @objc private func fullScreenClick(sender:UIButton){
        sender.isSelected = !sender.isSelected
        if isLocked {
            return
        }
        
        let orientation = UIDevice.current.orientation
        switch orientation {
            
        case .portraitUpsideDown:
            ///如果是UpsideDown就直接回到竖屏
            interfaceOrientation(orientation: .portrait)
        case .portrait:
            ///如果是竖屏就直接右旋转
            interfaceOrientation(orientation: .landscapeRight)
            break
        case .landscapeLeft:
            ///如果是小屏一律右旋转，如果是大屏的LandscapeLeft，就竖屏
            if !isFullScreen {
                interfaceOrientation(orientation: .landscapeRight)
            }else{
                interfaceOrientation(orientation: .portrait)
            }
            break
        case .landscapeRight:
            ///如果是小屏一律右旋转，如果是大屏的LandscapeLeft，就竖屏
            if !isFullScreen {
                interfaceOrientation(orientation: .landscapeRight)
            }else{
                interfaceOrientation(orientation: .portrait)
            }
            break
            
        default:
            if !self.isFullScreen {
                self.isFullScreen = true
                interfaceOrientation(orientation: .landscapeRight)
            }else{
                self.isFullScreen = false
                interfaceOrientation(orientation: .portrait)
            }
            break
        }
    }
    
    /*
     * 锁屏按钮
     */
    @objc private func lockBtnClick(sender:UIButton){
        sender.isSelected = !sender.isSelected
        if isLocked {
            isLocked = false
        }else{
            isLocked = true
        }
    }
    
    /*
     * 关闭播放器按钮
     */
    @objc private func closePlayer(sender:UIButton){
        if !isLocked {
            if isFullScreen {
                fullScreenClick(sender: UIButton())
            }else{
                UIApplication.shared.isStatusBarHidden = false
                ///关闭播放器代理
                self.mPlayerDelegate?.closePlayer()
                closPlaer()
            }
            
        }
    }
    
    /*
     * 进度条滑动事件
     */
    @objc private func progressSliderTouchBegan(slider:UISlider){
        self.startAnimation()
        self.player?.pause()
    }
    
    @objc private func progressSliderValueChanged(slider:UISlider){
        if (totalTime != nil)  {
            let chageTime = slider.value * Float(totalTime!)
            self.currentTimeLB?.text = String.init(format: "%@", self.timeStringWithTime(times: NSInteger(chageTime)))
        }
    }
    
    @objc private func progressSliderTouchEnded(slider:UISlider){
        if (totalTime != nil) {
            self.player?.seek(to: CMTimeMake(Int64(slider.value * Float(totalTime!)), 1))
            self.player?.play()
            self.centerPlayOrPauseBtn?.isSelected = false
        }
    }
    
    //MARK:屏幕相关设置以及屏幕布局
    /**
     *  监听设备旋转通知
     */
   private func listeningRotating()  {
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(onDeviceOrientationChange), name:NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    /**
     *  强制屏幕转屏
     *  orientation 屏幕方向
     */
    private func interfaceOrientation(orientation:UIInterfaceOrientation){
        if isLocked {
            return
        }
        ///swift移除了NSInvocation 暂时找不到强制旋转方法,只能桥接
        DeviceTool.interfaceOrientation(orientation)
    }
    
    /**
     *  屏幕方向发生变化会调用这里
     */
    @objc private func onDeviceOrientationChange()  {
        
        if isLocked {
            return
        }
        
        let orientation = UIDevice.current.orientation
        
        switch orientation {
        case .portraitUpsideDown:
            let frame = UIScreen.main.applicationFrame
            self.center = CGPoint.init(x: frame.origin.x + ceil(frame.size.width/2), y: frame.origin.y + ceil(frame.size.height/2))
            self.frame = frame
            self.centerPlayOrPauseBtn?.setImage(MIMAGE("Player_pause_btn"), for: .normal)
            self.centerPlayOrPauseBtn?.setImage(MIMAGE("Player_play_btn"), for: .selected)
            self.resolutionBtn?.snp.updateConstraints({ (make) in
                make.right.equalTo(fullScreenBtn!.snp.left).offset(-2)
                make.top.equalTo(bottomImageView!)
                make.size.equalTo(CGSize.init(width:isLOCAL ? 0 : 40, height: 40))
            })
            
            self.fullScreenBtn?.isSelected = true
            self.isFullScreen = true
            
            break
            
        case .portrait:
            let frame = UIScreen.main.applicationFrame
            self.center = CGPoint.init(x: frame.origin.x + ceil(frame.size.width/2), y: frame.origin.y + ceil((frame.size.width*9/16)/2))
            self.frame = CGRect.init(x: frame.origin.x, y: frame.origin.x, width: frame.size.width, height: Screen_width * 9/16)
            self.centerPlayOrPauseBtn?.setImage(MIMAGE("Player_pause_btn_small"), for: .normal)
            self.centerPlayOrPauseBtn?.setImage(MIMAGE("Player_play_btn_small"), for: .selected)
            self.resolutionBtn?.snp.updateConstraints({ (make) in
                make.right.equalTo(fullScreenBtn!.snp.left).offset(-2)
                make.top.equalTo(bottomImageView!)
                make.size.equalTo(CGSize.init(width:isLOCAL ? 0 : 40, height: 40))
            })
            self.fullScreenBtn?.isSelected = false
            self.resolutionView?.isHidden = true
            self.isFullScreen = false
            break
            
        case .landscapeLeft:
            
            let frame = UIScreen.main.applicationFrame
            self.center = CGPoint.init(x: frame.origin.x + ceil(frame.size.width/2), y: frame.origin.y + ceil(frame.size.height/2))
            self.frame = frame
            self.centerPlayOrPauseBtn?.setImage(MIMAGE("Player_pause_btn"), for: .normal)
            self.centerPlayOrPauseBtn?.setImage(MIMAGE("Player_play_btn"), for: .selected)
            self.resolutionBtn?.snp.updateConstraints({ (make) in
                make.right.equalTo(fullScreenBtn!.snp.left).offset(-2)
                make.top.equalTo(bottomImageView!)
                make.size.equalTo(CGSize.init(width:isLOCAL ? 0 : 40 , height: 40))
            })
            self.fullScreenBtn?.isSelected = true
            self.isFullScreen = true
            break
            
        case .landscapeRight:
            let frame = UIScreen.main.applicationFrame
            self.center = CGPoint.init(x: frame.origin.x + ceil(frame.size.width/2), y: frame.origin.y + ceil(frame.size.height/2))
            self.frame = frame
            self.centerPlayOrPauseBtn?.setImage(MIMAGE("Player_pause_btn"), for: .normal)
            self.centerPlayOrPauseBtn?.setImage(MIMAGE("Player_play_btn"), for: .selected)
            self.resolutionBtn?.snp.updateConstraints({ (make) in
                make.right.equalTo(fullScreenBtn!.snp.left).offset(-2)
                make.top.equalTo(bottomImageView!)
                make.size.equalTo(CGSize.init(width: isLOCAL ? 0 : 40, height: 40))
            })
            self.fullScreenBtn?.isSelected = true
            self.isFullScreen = true
            break
            
        default:
            break
        }
        self.playerLayer?.frame = self.frame
    }
    
    
    /**
     *  页面布局
     */
    private func makeSubViewsConstraints(){
        ///音频背景图片
        self.musicBackGround = {
            let musicBackGround = UIImageView()
            musicBackGround.image = MIMAGE("音频模式")
            musicBackGround.isHidden = true
            self.addSubview(musicBackGround)
            musicBackGround.snp.makeConstraints({ (make) in
                make.left.right.width.height.equalTo(self)
            })
            return musicBackGround
        }()
        
        ///顶部操作条
        self.topImageView = {
            let temptopImageView = UIImageView()
            temptopImageView.image = MIMAGE("Player_top_shadow")
            temptopImageView.isUserInteractionEnabled = true
            self.addSubview(temptopImageView)
            temptopImageView.snp.makeConstraints({ (make) in
                make.left.top.right.equalTo(self).offset(0)
                make.height.equalTo(40)
            })
            return temptopImageView
        }()
        
        /// 关闭播放器按钮
        self.closeBtn = {
            let tempCloseBtn = UIButton.init(type: .custom)
            tempCloseBtn.setImage(MIMAGE("Player_close"), for: .normal)
            tempCloseBtn.addTarget(self, action: #selector(closePlayer(sender:)), for: .touchUpInside)
            topImageView?.addSubview(tempCloseBtn)
            tempCloseBtn.snp.makeConstraints({ (make) in
                make.left.equalTo(self.snp.left).offset(5)
                make.top.equalTo(self.snp.top).offset(0)
                make.size.equalTo(CGSize.init(width: 40, height: 40))
            })
            return tempCloseBtn
        }()
        
        /// 锁屏按钮
        
//        self.lockBtn = {
//            
//            let lockBtn = UIButton.init(type: .custom)
//            lockBtn.setImage(MIMAGE("Player_unlock-nor"), for: .normal)
//            lockBtn.setImage(MIMAGE("Player_lock-nor"), for: .selected)
//            lockBtn.addTarget(self, action: #selector(lockBtnClick(sender:)), for: .touchUpInside)
//            self.addSubview(lockBtn)
//            lockBtn.snp.makeConstraints({ (make) in
//                make.left.equalTo(self.snp.left).offset(5);
//                make.centerY.equalTo(self)
//                make.size.equalTo(CGSize.init(width: 40, height: 40));
//            })
//            return lockBtn
//        }()
        
        self.switchCircuitView = {
            let switchCircuitView = SwitchCircuitView()
            self.addSubview(switchCircuitView)
            switchCircuitView.isHidden = isLOCAL ? true : false
            switchCircuitView.snp.makeConstraints({ (make) in
                make.left.equalTo(self.snp.left)
                make.centerY.equalTo(self)
                make.size.equalTo(CGSize.init(width: 100, height: 40))
            })
            return switchCircuitView
        }()
        
        ///重播按钮
        self.repeatBtn = {
            let tempBtn = UIButton.init(type: .custom)
            tempBtn.setImage(MIMAGE("Player_repeat_video"), for: .normal)
            tempBtn.addTarget(self, action: #selector(repeatBtnClick(button:)), for: .touchUpInside)
            tempBtn.isHidden = true
            self.addSubview(tempBtn)
            tempBtn.snp.makeConstraints({ (make) in
                make.center.equalTo(self)
            })
            return tempBtn
        }()
        
        ///本地倍速按钮
        self.rateBtn = {
            let tempRate = UIButton.init(type: .custom)
            tempRate.setImage(MIMAGE("倍速-"), for: .normal)
            tempRate.addTarget(self, action: #selector(clickRateBtnEvent), for: .touchUpInside)
            
            tempRate.isHidden = isLOCAL ? false : true
            self.addSubview(tempRate)
            tempRate.snp.makeConstraints({ (make) in
                make.centerY.equalTo(self)
                make.right.equalTo(self).offset(-5)
                make.width.height.equalTo(40)
            })
            return tempRate
        }()
        
        ///倍速显示label
        self.ratelabel = {
            
            let rateLabel = UILabel()
            rateLabel.font = FONT(15)
            rateLabel.textColor = UIColor.white
            rateLabel.text = "倍速 1.0X"
            rateLabel.isHidden = isLOCAL ? false : true
            self.addSubview(rateLabel)
            rateLabel.snp.makeConstraints({ (make) in
                make.right.equalTo(rateBtn!.snp.left).offset(-3)
                make.centerY.equalTo(repeatBtn!)
                make.height.equalTo(40)
            })
            return ratelabel
        }()
        
        ///右侧操作图
        self.rateView = {
            let tempRateView = RateView.init(frame: CGRect.init(x: 0, y: 0, width: 40, height: 140))
            tempRateView.image = MIMAGE("背景")
            tempRateView.isHidden = isLocked ? true : false
            tempRateView.rateLB?.text = "倍速 1.0x"
            self.addSubview(tempRateView)
            tempRateView.snp.makeConstraints({ (make) in
                make.top.equalTo(self).offset(10)
                make.right.equalTo(self).offset(-5)
                make.width.equalTo(40)
                make.height.equalTo(130)
            })
            
            return tempRateView
            
        }()
        
        /// 底部操作条
        self.bottomImageView = {
            let tempBottom = UIImageView()
            tempBottom.image = MIMAGE("Player_bottom_shadow")
            tempBottom.isUserInteractionEnabled = true
            self.addSubview(tempBottom)
            tempBottom.snp.makeConstraints({ (make) in
                make.left.bottom.right.equalTo(self).offset(0);
                make.height.equalTo(40);
            })
            return tempBottom
        }()
        
        /// 中间播放暂停按钮
        self.centerPlayOrPauseBtn = {
            let tempPlayBtn = UIButton()
            tempPlayBtn.setImage(MIMAGE("Player_pause_btn_small"), for: .normal)
            tempPlayBtn.setImage(MIMAGE("Player_play_btn_small"), for: .selected)
            tempPlayBtn.addTarget(self, action: #selector(playOrPauseButtonClick(sender:)), for: .touchUpInside)
            
            self.addSubview(tempPlayBtn)
            tempPlayBtn.snp.makeConstraints({ (make) in
                
                make.center.equalTo(self)
                make.size.equalTo(CGSize.init(width: 80, height: 80))
            })
            
            return tempPlayBtn
            
        }()
        
        ///全屏退出全屏按钮
        self.fullScreenBtn = {
            let fullBtn = UIButton.init(type: .custom)
            fullBtn.setImage(MIMAGE("Player_fullscreen"), for: .normal)
            fullBtn.setImage(MIMAGE("Player_shrinkscreen"), for: .selected)
            fullBtn.addTarget(self, action: #selector(fullScreenClick(sender:)), for: .touchUpInside)
            bottomImageView!.addSubview(fullBtn)
            fullBtn.snp.makeConstraints({ (make) in
                make.right.equalTo(bottomImageView!.snp.right).offset(-2);
                make.top.equalTo(bottomImageView!);
                make.size.equalTo(CGSize.init(width: 40, height: 40));
            })
            return fullBtn
        }()
        
        /// 切换清晰度按钮
        self.resolutionBtn = {
            let resolBtn = UIButton.init(type: .custom)
            resolBtn.setTitle("高清", for: .normal)
            resolBtn.titleLabel?.font = FONT(14)
            resolBtn.addTarget(self, action: #selector(resolutionBtnClick(button:)), for: .touchUpInside)
            bottomImageView?.addSubview(resolBtn)
            resolBtn.snp.makeConstraints({ (make) in
                make.right.equalTo(fullScreenBtn!.snp.left).offset(-1)
                make.top.equalTo(bottomImageView!)
                make.size.equalTo(CGSize.init(width: 0, height: 40))
            })
            return resolBtn
        }()
        
        /// 清晰度界面
        self.resolutionView = {
            let temp = ResolutionView.init(frame: CGRect.zero)
            temp.backgroundColor = UIColor.darkGray
            temp.isHidden = true
            
            self.addSubview(temp)
            temp.snp.makeConstraints({ (make) in
                make.centerX.equalTo(resolutionBtn!)
                make.bottom.equalTo(resolutionBtn!.snp.top)
                make.size.equalTo(CGSize.init(width: 40, height: 60))
            })
            return temp
        }()
        
        /// 总时间
        self.totalTimeLB = {
            let tem = UILabel()
            tem.font = FONT(12)
            tem.textColor = Whit
            tem.text = "00:00"
            bottomImageView?.addSubview(tem)
            tem.snp.makeConstraints({ (make) in
                make.right.equalTo(resolutionBtn!.snp.left).offset(-3)
                make.top.equalTo(fullScreenBtn!.snp.top)
                make.height.equalTo(40)
            })
            return tem
        }()
        /// 当前时间
        self.currentTimeLB = {
            let tempLabel = UILabel()
            tempLabel.font = FONT(12)
            tempLabel.textColor = Whit
            tempLabel.text = "00:00"
            bottomImageView?.addSubview(tempLabel)
            tempLabel.snp.makeConstraints({ (make) in
                make.left.equalTo(bottomImageView!.snp.left).offset(3)
                make.top.equalTo(fullScreenBtn!.snp.top)
                make.height.equalTo(40)
            })
            return tempLabel
        }()
        
        /// 滑动进度条
        self.slider = {
            let tempSlider = UISlider()
            tempSlider.setThumbImage(MIMAGE("Player_slider"), for: .normal)
            tempSlider.maximumValue = 1.0
            tempSlider.addTarget(self, action: #selector(progressSliderTouchBegan(slider:)), for: .touchDown)
            tempSlider.addTarget(self, action: #selector(progressSliderValueChanged(slider:)), for: .valueChanged)
            tempSlider.addTarget(self, action: #selector(progressSliderTouchEnded(slider:)), for: .touchCancel)
            bottomImageView?.addSubview(tempSlider)
            tempSlider.snp.makeConstraints({ (make) in
                make.left.equalTo(currentTimeLB!.snp.right).offset(3)
                make.top.height.equalTo(currentTimeLB!)
                make.right.equalTo(totalTimeLB!.snp.left).offset(-8)
            })
            return tempSlider
        }()
        
        ///菊花
        self.activeView = {
            let activew = UIActivityIndicatorView()
            activew.activityIndicatorViewStyle = .white
            self.addSubview(activew)
            activew.snp.makeConstraints({ (make) in
                make.center.equalTo(self)
            })
            return activew
        }()
        ///本地倍速显示
        self.activeLB = {
            let temp = UILabel()
            temp.text = "正在加载"
            temp.font = FONT(13)
            temp.textColor = Whit
            temp.isHidden = true
            self.addSubview(temp)
            temp.snp.makeConstraints({ (make) in
                make.top.equalTo(activeView!.snp.bottom)
                make.height.equalTo(20)
                make.centerX.equalTo(activeView!)
            })
            return temp
        }()
        
        self.horizontalLabel = {
            let tempLabel = UILabel()
            tempLabel.font = FONT(13)
            tempLabel.textColor = Whit
            tempLabel.isHidden = true
            tempLabel.textAlignment = .center
            self.addSubview(tempLabel)
            tempLabel.snp.makeConstraints({ (make) in
                make.width.equalTo(150)
                make.height.equalTo(33)
                make.bottom.equalTo(self).offset(-15)
                
            })
            return tempLabel
            
        }()
        self.controlViewIsShowing = true
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}
