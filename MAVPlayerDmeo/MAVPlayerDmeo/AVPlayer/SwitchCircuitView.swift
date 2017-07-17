//
//  SwitchCircuitView.swift
//  BangDemo
//
//  Created by yizhilu on 2017/6/28.
//  Copyright © 2017年 Magic. All rights reserved.
//

import UIKit
import SnapKit
class SwitchCircuitView: UIView {

    /** *切换线路按钮 */
    var switchCircuitBtn : UIButton?
    /** *切换到哪个线路 */
    var switchCircuitLB : UILabel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        switchCircuitBtn = UIButton.init(type: .custom)
        switchCircuitBtn?.setImage(MIMAGE("切换"), for: .normal)
        
        switchCircuitLB = UILabel()
        switchCircuitLB?.text = "线路一"
        switchCircuitLB?.font = FONT(13)
        switchCircuitLB?.textColor = Whit
        
        self.addSubview(switchCircuitBtn!)
        self.addSubview(switchCircuitLB!)
        
        switchCircuitBtn?.snp.makeConstraints({ (make) in
            make.centerY.equalTo(self)
            make.width.height.equalTo(40)
            make.left.equalTo(self).offset(5)
        })
        
        switchCircuitLB?.snp.makeConstraints({ (make) in
            make.left.equalTo(switchCircuitBtn!.snp.right).offset(3)
            make.centerY.equalTo(self)
            make.height.equalTo(30)
        })
        switchCircuitBtn?.addTarget(self, action: #selector(switchCircuit(button:)), for: .touchUpInside)
    }
    
    /*
     * 线路切换
     */
    @objc private func switchCircuit(button:UIButton){
        button.isSelected = !button.isSelected
        if button.isSelected {
            self.switchCircuitLB?.text = "线路二"
        }else{
            self.switchCircuitLB?.text = "线路一"
        }
        ParsingEncrypteString().exchangeViewWith(videoUrl: MPlayerView.shared.videoParseCode!, reconnect: true, videoType: MPlayerView.shared.videoType!) { (url) in
            MPlayerView.shared.exchangeWithURL(videoURLStr: url)
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
