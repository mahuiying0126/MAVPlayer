# MAVPlayer
自定义AV播放器视图
简单说一下工程结构，所有关于播放的东西以及布局都是在`AVPlayer`文件夹下，视频播放的布局是基于`SnapKit`三方库来布局了，因为在OC里用惯了`Masonry `所以工程里依然沿用这个库。因为项目里面有线路切换和音视频切换功能，，如果你有未加密的视频链接或者音频链接直接把sdk删掉也是可以的，也是可以正常播放的。

关键代码是放在`MPlayerView`这个文件中，辅助视图布局的三个文件分别是：`RateView`音视频倍速切换`ResolutionView`高清度切换`SwitchCircuitView`线路切换。

刚开始做的时候，把所有的功能代码都全部放入`MPlayerView `这个文件中，发现耦合度太多，代码可读性差，所以我将代码拆出来各自负责的模块放入各自的功能，比如高清度切换功能，实现的功能就是放在`ResolutionView `文件下。

在这里就不贴太多的代码，我将在本文末放demo的下载地址。现在就简单聊一下实现过程吧。视频播放界面我用的是一个单例实现的，刚开始不是用单例实现，但是为了把代码拆出来放到各自的功能区所以用单例实现是最好的方法。由于swift放弃了OC里的`dispatch_once`实现单例方法，swift3.0以后的单例写法：

	/// 创建播放器单例
	static let shared = MPlayerView()
	private override init(frame: CGRect) {
	    super.init(frame: frame)
	 }
	required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

在swift3.0之后重写init方法必须实现`required init`方法，这么做也是为了安全，因为在OC里`init`方法并不能保证子类完成初始化，增加`required`“这是由初始化方法的完备性需求所决定的，以保证类型的安全。

由于swift里面有严格的类型检查，就比如在做手势滑动的时候，手势刚开始滑动的时候肯定需要记录一下当前播放器的位置我在项目中是定义的`sumTime`属性是一个`CMTime`类型，如果在OC里大可不必这样，来看一下swift与OC代码的区别

swift写法

	/// 给sumTime初值
	let time = self.player?.currentTime()
	self.sumTime = CMTimeMake((time?.value)!, (time?.timescale)!)

OC写法

	// 给sumTime初值
	CMTime time = self.player.currentTime;
	self.sumTime  = time.value/time.timescale;

滑动的距离是一个`Double`类型，而`self.sumTime `是CMTime类型，俩者肯定不能想加算出结束滑动的距离，所以将double类型转换成CMTime类型用以下方法：

	CMTime.init(seconds: Double.init(value/200), preferredTimescale: CMTimeScale(NSEC_PER_SEC))

如果是OC的话直接括号强转类型即可实现。

知道滑动的距离和记录滑动前的距离俩者想加即是当前位置，转化成CMTime类型：

	self.sumTime = CMTimeAdd(self.sumTime!, addend)

手势是滑动了，但是进度条也是要跟着一起滑动的，有人说我把进度条刷新放到player的代理里面，手势滑动完只需要把时间传给播放器，播放器根据当前时间和总时间去更新进度条，这样做也对，但是有一点就是，如果网速不好，手势已经滑动到5分钟了，而进度条还停留在1分钟的地方，播放器缓存完毕了，进度条会瞬间跳到5分钟，从而造成卡顿的假象体验也不是很好，所以解决这个方法是手势滑动的时候也更新进度条，但是手势滑动的时候都是CMTime类型，怎么转成`Float`类型，因为`slider?.value`是float类型。可以这样：通过`CMTimeGetSeconds`方法得到一个`Float64`再通过`Float.init`方法得到一个float类型，看一下实现：

	let sliderTime = CMTimeGetSeconds(self.sumTime!)/CMTimeGetSeconds(totalMovieDuration)
	self.slider?.value = Float.init(sliderTime)

想查看整个过程可以看`播放器手势添加与创建`这一块，我已经用`MARK:`标记起来了。

一个视频播放实现起来并不困难，只要处理好`player`与`platitem`就行了。最难得就是，如果手机屏幕旋转，怎么能让视频跟着屏幕自适应呢，我在工程里面通过`UIDevice`变化添加的是屏幕旋转监听：

	/**
	  *  监听设备旋转通知
	  */
	 private func listeningRotating()  {
	        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
	        NotificationCenter.default.addObserver(self, selector: #selector(onDeviceOrientationChange), name:NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }

如果用户把屏幕旋转关掉，就是控制中心那个开关，用户旋转屏幕，怎么能让画面跟着跑呢，我百度的很多资料，试了也很多方法，但是都不理想，用的还是OC的代码，因为swift里面移除了`NSInvocation`属性，用的依然是OC的屏幕强制旋转，只能使用桥接文件：

	+ (void)interfaceOrientation:(UIInterfaceOrientation)orientation{
	    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
	        SEL selector = NSSelectorFromString(@"setOrientation:");
	        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
	        [invocation setSelector:selector];
	        [invocation setTarget:[UIDevice currentDevice]];
	        int val  = orientation;
	        // 从2开始是因为0 1 两个参数已经被selector和target占用
	        [invocation setArgument:&val atIndex:2];
	        [invocation invoke];
	    }
	}

大概就介绍这么多,如果还有不明白的知识点可以去demo中自己去查.
