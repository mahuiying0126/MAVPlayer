//
//  ResolutionView.swift
//  BangDemo
//
//  Created by yizhilu on 2017/6/28.
//  Copyright © 2017年 Magic. All rights reserved.
//

import UIKit
import SnapKit
class ResolutionView: UIView {

    /** *标清 */
    var SDBtn : UIButton?
    /** *高清 */
    var HDBtn : UIButton?
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        SDBtn = UIButton.init(type: .custom)
        SDBtn?.setTitle("高清", for: .normal)
        SDBtn?.titleLabel?.font = FONT(14)
        SDBtn?.setTitleColor(Whit, for: .normal)
        self.addSubview(SDBtn!)
        
        HDBtn = UIButton.init(type: .custom)
        HDBtn?.setTitle("标清", for: .normal)
        HDBtn?.titleLabel?.font = FONT(14)
        HDBtn?.setTitleColor(Whit, for: .normal)
        self.addSubview(HDBtn!)
        
        SDBtn?.snp.makeConstraints({ (make) in
            make.left.equalTo(self.snp.left)
            make.top.equalTo(self)
            make.size.equalTo(CGSize.init(width: 40, height: 30))
        })
        
        HDBtn?.snp.makeConstraints({ (make) in
            make.left.equalTo(SDBtn!.snp.left)
            make.top.equalTo(SDBtn!.snp.bottom)
            make.size.equalTo(SDBtn!)
        })
        
        SDBtn?.addTarget(self, action: #selector(SDBtnClick(button:)), for: .touchUpInside)
        HDBtn?.addTarget(self, action: #selector(HDBtnClick(button:)), for: .touchUpInside)
        
        
        
    }
    
    /*
     * 高清按钮
     */
    @objc private func SDBtnClick(button:UIButton){
        MPlayerView.shared.resolutionBtn?.setTitle("高清", for: .normal)
        MPlayerView.shared.rateView?.rateLB?.text = "倍速 1.0x"
        MPlayerView.shared.rateView?.rateLB?.textColor = Whit
        self.isHidden = true
        if MPlayerView.shared.chanel ==  CHANNEL_LOW {
            MPlayerView.shared.chanel = CHANNEL_HIGH
            ParsingEncrypteString().exchangeSDorHDWithUrl(videoId: MPlayerView.shared.videoParseCode!, type: MPlayerView.shared.videoType!, channel: MPlayerView.shared.chanel, local: MPlayerView.shared.isLOCAL, success: {(videoUrl) in
                MPlayerView.shared.exchangeWithURL(videoURLStr: videoUrl)
                
            })
            
        }
    }
    /*
     * 标清按钮
     */
    @objc private func HDBtnClick(button:UIButton){
        MPlayerView.shared.resolutionBtn?.setTitle("标清", for: .normal)
        MPlayerView.shared.rateView?.rateLB?.text = "倍速 1.0x"
        MPlayerView.shared.rateView?.rateLB?.textColor = Whit
        self.isHidden = true
        if MPlayerView.shared.chanel == CHANNEL_LOW  {
            MPlayerView.shared.chanel = CHANNEL_HIGH
            ParsingEncrypteString().exchangeSDorHDWithUrl(videoId: MPlayerView.shared.videoParseCode!, type: MPlayerView.shared.videoType!, channel: MPlayerView.shared.chanel, local: MPlayerView.shared.isLOCAL, success: { (videoUrl) in
                MPlayerView.shared.exchangeWithURL(videoURLStr: videoUrl)
                
            })
            
        }
    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}
