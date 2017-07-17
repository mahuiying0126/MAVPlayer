//
//  RateView.swift
//  BangDemo
//
//  Created by yizhilu on 2017/6/28.
//  Copyright © 2017年 Magic. All rights reserved.
//

import UIKit

class RateView: UIImageView {
    
    /** *倍速展示 */
    var rateLB : UILabel?
    /** *倍速按钮 */
    var rateBtn : UIButton?
    /** *音频展示 */
    var audioLB : UILabel?
    /** *音频按钮 */
    var audioBtn : UIButton?
    /** *视频展示 */
    var videoLB : UILabel?
    /** *视频按钮 */
    var videoBtn : UIButton?
    
   
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isUserInteractionEnabled = true
        rateLB = UILabel()
        rateLB?.textColor = Whit
        rateLB?.font = FONT(14)
        
        rateBtn = UIButton.init(type: .custom)
        rateBtn?.setImage(MIMAGE("倍速-"), for: .normal)
        rateBtn?.setTitleColor(Whit, for: .normal)
        
        audioLB = UILabel()
        audioLB?.textColor = Whit
        audioLB?.text = "音频"
        audioLB?.font = FONT(14)
        
        audioBtn = UIButton.init(type: .custom)
        audioBtn?.setImage(MIMAGE("音频"), for: .normal)
        audioBtn?.setTitleColor(Whit, for: .normal)
        
        videoLB = UILabel()
        videoLB?.textColor = Whit
        videoLB?.font = FONT(14)
        videoLB?.text = "视频"
        
        videoBtn = UIButton.init(type: .custom)
        videoBtn?.setImage(MIMAGE("视频"), for: .normal)
        videoBtn?.setTitleColor(Whit, for: .normal)
        
        self.addSubview(rateLB!)
        self.addSubview(rateBtn!)
        self.addSubview(audioLB!)
        self.addSubview(audioBtn!)
        self.addSubview(videoLB!)
        self.addSubview(videoBtn!)
        
        videoBtn?.snp.makeConstraints({ (make) in
            make.centerX.equalTo(self)
            make.top.equalTo(self.snp.top).offset(3)
            make.width.height.equalTo(40)
        })
        
        videoLB?.snp.makeConstraints({ (make) in
            make.centerY.equalTo(videoBtn!)
            make.height.equalTo(videoBtn!)
            make.right.equalTo(videoBtn!.snp.left).offset(-5)
        })
        
        audioBtn?.snp.makeConstraints({ (make) in
            make.centerX.equalTo(self)
            make.top.equalTo(videoBtn!.snp.bottom).offset(3)
            make.width.height.equalTo(videoBtn!)
        })
        
        audioLB?.snp.makeConstraints({ (make) in
            make.centerY.equalTo(audioBtn!)
            make.height.equalTo(audioBtn!)
            make.right.equalTo(audioBtn!.snp.left).offset(-5)
        })
        
        rateBtn?.snp.makeConstraints({ (make) in
            make.centerX.equalTo(self)
            make.top.equalTo(audioBtn!.snp.bottom).offset(3)
            make.width.height.equalTo(videoBtn!)
        })
        
        rateLB?.snp.makeConstraints({ (make) in
            make.centerY.equalTo(rateBtn!)
            make.height.equalTo(rateBtn!)
            make.right.equalTo(rateBtn!.snp.left).offset(-5)
        })
        
        videoBtn?.addTarget(self, action: #selector(clickVideoBtnEvent), for: .touchUpInside)
        audioBtn?.addTarget(self, action: #selector(clickAudioBtnEvent), for: .touchUpInside)
        rateBtn?.addTarget(self, action: #selector(clickRateBtnEvent), for: .touchUpInside)
    }
    
    /*
     * 切换视频
     */
    @objc private func clickVideoBtnEvent(){
        MPlayerView.shared.musicBackGround?.isHidden = true
        videoLB?.textColor = UIColorFromRGB(0xf6a54a)
        audioLB?.textColor = Whit
        rateLB?.textColor = Whit
        rateBtn?.setImage(MIMAGE("倍速-"), for: .normal)
        audioBtn?.setImage(MIMAGE("音频"), for: .normal)
        videoBtn?.setImage(MIMAGE("选中视频"), for: .normal)
        if MPlayerView.shared.videoType == "AUDIO" {
            MPlayerView.shared.videoType = "VIDEO"
            ParsingEncrypteString().parseStringWith(urlString: MPlayerView.shared.videoParseCode!, fileType: MPlayerView.shared.videoType!, isLocal: MPlayerView.shared.isLOCAL, success: { (url) in
                MPlayerView.shared.exchangeWithURL(videoURLStr: url)
            })
        }
    }

    /*
     * 切音频
     */
    @objc private func clickAudioBtnEvent(){
        MPlayerView.shared.musicBackGround?.isHidden = false
        videoLB?.textColor = Whit
        audioLB?.textColor = UIColorFromRGB(0xf6a54a)
        rateLB?.textColor = Whit
        rateBtn?.setImage(MIMAGE("倍速-"), for: .normal)
        audioBtn?.setImage(MIMAGE("选中音频"), for: .normal)
        videoBtn?.setImage(MIMAGE("视频"), for: .normal)
        if MPlayerView.shared.videoType == "VIDEO" {
            MPlayerView.shared.videoType = "AUDIO"

            ParsingEncrypteString().parseStringWith(urlString: MPlayerView.shared.videoParseCode!, fileType: MPlayerView.shared.videoType!, isLocal: MPlayerView.shared.isLOCAL, success: { (url) in
                MPlayerView.shared.exchangeWithURL(videoURLStr: url)
            })
        }
        MPlayerView.shared.exchangeVideoBtn?.isHidden = false
    }
    
    /*
     * 切倍速
     */
    @objc private func clickRateBtnEvent(){
        
        MPlayerView.shared.rateValue! += 0.2
        if MPlayerView.shared.rateValue! >= 1.2 && MPlayerView.shared.rateValue! < 1.3 {
            MPlayerView.shared.rateValue = 1.2
        }else if MPlayerView.shared.rateValue! >= 1.4 && MPlayerView.shared.rateValue! < 1.5 {
            MPlayerView.shared.rateValue = 1.5
        }else if MPlayerView.shared.rateValue! > 1.5 {
            MPlayerView.shared.rateValue = 1.0
        }
        
        MPlayerView.shared.player?.rate = MPlayerView.shared.rateValue!
        
        MPlayerView.shared.centerPlayOrPauseBtn?.isSelected = false
        if MPlayerView.shared.isLOCAL {
            rateBtn?.setImage(MIMAGE("选中倍速"), for: .normal)
            MPlayerView.shared.ratelabel?.textColor = UIColorFromRGB(0xf6a54a)
            MPlayerView.shared.ratelabel?.text = String.init(format: "倍速 %.1fx", MPlayerView.shared.rateValue!)
            
        }else{
            rateLB?.text = String.init(format: "倍速 %.1fx", MPlayerView.shared.rateValue!)
            videoLB?.textColor = Whit
            audioLB?.textColor = Whit
            rateLB?.textColor = UIColorFromRGB(0xf6a54a)
            rateBtn?.setImage(MIMAGE("选中倍速"), for: .normal)
            audioBtn?.setImage(MIMAGE("音频"), for: .normal)
            videoBtn?.setImage(MIMAGE("视频"), for: .normal)
            
        }
    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
