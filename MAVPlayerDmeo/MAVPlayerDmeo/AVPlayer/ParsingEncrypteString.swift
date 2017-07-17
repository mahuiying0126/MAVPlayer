//
//  ParsingEncrypteString.swift
//  BangDemo
//
//  Created by yizhilu on 2017/7/6.
//  Copyright © 2017年 Magic. All rights reserved.
//

import UIKit

class ParsingEncrypteString: NSObject {
    
    /// 初始化播放器URL请求
    ///
    /// - Parameters:
    ///   - urlString: videUrlID
    ///   - fileType: 文件类型:VIDEO&AUDIO
    ///   - isLocal: 是否为本地播放
    ///   - success: 将码转为链接,block回调
    func parseStringWith(urlString:String,fileType:String,isLocal:Bool,success: @escaping (_ videoUrl:String) -> ()) {
        MediaServer.setDebugMode(false)
        if isLocal {
            MediaServer.prepareLocalFileAsync(urlString, channel: CHANNEL_LOW, speed: SPEED_10X, completion: { (error, url) in
                if !(error != nil) {
                    success(url!)
                }
            })
        }else{
            MediaServer.prepareNetworkStreamAsync(urlString, reconnect: false, completion: { (error, res) in
                if !(error != nil) {
                    var url = ""
                    if fileType == "VIDEO" {
                       url = res?["video_high_url"] as! String
                    }else{
                        url = res?["mp3_audio_url"] as! String
                    }
                    success(url)
                }
            })
        }
    }
    
    
    /// 切换视频音频初始化方法
    ///
    /// - Parameters:
    ///   - videoUrl: videoID 视频码
    ///   - reconnect: YES
    ///   - videoType: 视频类型:VIDEO & AUDIO
    ///   - success: 解码回调
    func exchangeViewWith(videoUrl:String,reconnect:Bool,videoType:String,success:@escaping (_ videoID:String) -> ()){
        MediaServer.setDebugMode(false)
        MediaServer.prepareNetworkStreamAsync(videoUrl, reconnect: reconnect) { (error,res) in
            if !(error != nil) {
                var url = ""
                if videoType == "VIDEO" {
                    url = res?["video_high_url"] as! String
                }else{
                    url = res?["mp3_audio_url"] as! String
                }
                success(url)
            }
        }
    }
    
    /// 切换高清度方法
    ///
    /// - Parameters:
    ///   - videoId: 视频的id
    ///   - type: 视频类型:音频 || 视频
    ///   - channel: 高清还是标清
    ///   - local: 是否为本地
    ///   - success: 解析成功回调
    func exchangeSDorHDWithUrl(videoId:String,type:String,channel:Int32,local:Bool,success:@escaping(_ videoId:String) -> ()) {
        MediaServer.setDebugMode(false)
        if local {
            MediaServer.prepareLocalFileAsync(videoId, channel: channel, speed: SPEED_10X, completion: { (error, url) in
                if !(error != nil) {
                    success(url!)
                }
            })
        }else{
            MediaServer.prepareNetworkStreamAsync(videoId, reconnect: false, completion: { (error, res) in
                var url:String
                if !(error != nil) {
                    if type == "VIDEO" {
                        if channel == CHANNEL_LOW {
                            url = res?["video_low_url"] as! String
                        }else{
                            url = res?["video_high_url"] as! String
                        }
                    }else{
                        url = res?["mp3_audio_url"] as! String
                    }
                    success(url)
                }
            })
        }
    }
    
    
}
