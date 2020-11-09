#import "FlutterMobileIMSDKPlugin.h"
#import "ClientCoreSDK.h"
#import "ConfigEntity.h"
#import "LocalDataSender.h"

@interface FlutterMobileIMSDKPlugin()
/* MobileIMSDK是否已被初始化. true表示已初化完成，否则未初始化. */
@property (nonatomic) BOOL _init;
/* 收到服务端的登陆完成反馈时要通知的观察者（因登陆是异步实现，本观察者将由
 *  ChatBaseEvent 事件的处理者在收到服务端的登陆反馈后通知之）*/
@property (nonatomic, copy) ObserverCompletion onLoginSucessObserver;// block代码块一定要用copy属性，否则报错！

@end
@implementation FlutterMobileIMSDKPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"flutter_MobileIMSDK"
            binaryMessenger:[registrar messenger]];
  FlutterMobileIMSDKPlugin* instance = [[FlutterMobileIMSDKPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

//- (void)initForLogin {
//    // 准备好异步登陆结果回调block（将在登陆方法中使用）
//    self.onLoginSucessObserver = ^(id observerble ,id data) {
//       
//        // 服务端返回的登陆结果值
//        int code = [(NSNumber *)data intValue];
//        // 登陆成功
//        if(code == 0)
//        {
//            // TODO 提示：登陆MobileIMSDK服务器成功后的事情在此实现即可
//            // TODO 提示：登陆MobileIMSDK服务器成功后的事情在此实现即可
//            // TODO 提示：登陆MobileIMSDK服务器成功后的事情在此实现即可
//            // TODO 提示：登陆MobileIMSDK服务器成功后的事情在此实现即可
//            // TODO 提示：登陆MobileIMSDK服务器成功后的事情在此实现即可
//            
//            // 进入主界面
////            [CurAppDelegate switchToMainViewController];
//        }
//        // 登陆失败
//        else
//        {
//           
//        }
//        
//        //## try to bug FIX ! 20160810：此observer本身执行完成才设置为nil，解决之前过早被nil而导致有时怎么也无法跳过登陆界面的问题
//        // * 取消设置好服务端反馈的登陆结果观察者（当客户端收到服务端反馈过来的登陆消息时将被通知）【1】
//        [[[IMClientManager sharedInstance] getBaseEventListener] setLoginOkForLaunchObserver:nil];
//    };
//}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  } else {
      if([call.method isEqualToString:@"initMobileIMSDK"]) {
          [self initMobileIMSDK:call result:result];
      }
      else if ([call.method isEqualToString:@"login"]){
          [self login:call result:result];
      }
     
    result(FlutterMethodNotImplemented);
      [ConfigEntity registerWithAppKey:@""];
  }
}

- (void)initMobileIMSDK:(FlutterMethodCall*)call result:(FlutterResult)result 
{
    if(!self._init && [call.arguments isKindOfClass:NSDictionary.class])
    {
        NSString *serverIP = call.arguments[@"serverIP"];
        NSString *serverPort = call.arguments[@"serverPort"];
        // 设置AppKey
        [ConfigEntity registerWithAppKey:@"5418023dfd98c579b6001741"];
        
        // 设置服务器ip和服务器端口
      [ConfigEntity setServerIp:serverIP];
      [ConfigEntity setServerPort:serverPort];
        
        // 使用以下代码表示不绑定固定port（由系统自动分配），否则使用默认的7801端口
//      [ConfigEntity setLocalUdpSendAndListeningPort:-1];
        
        // RainbowCore核心IM框架的敏感度模式设置
//      [ConfigEntity setSenseMode:SenseMode10S];
        
        // 开启DEBUG信息输出
        [ClientCoreSDK setENABLED_DEBUG:YES];
        
        // 设置事件回调
      
        [ClientCoreSDK sharedInstance].chatBaseEvent = self;
        [ClientCoreSDK sharedInstance].chatMessageEvent = self;
        [ClientCoreSDK sharedInstance].messageQoSEvent = self;
        
        self._init = YES;
    }
}

- (void)login:(FlutterMethodCall*)call result:(FlutterResult)result {
    if([call.arguments isKindOfClass:NSDictionary.class]) {
        NSString *loginUserIdStr = call.arguments[@"loginUserIdStr"];
        NSString *loginTokenStr = call.arguments[@"loginTokenStr"];
        
        // * 发送登陆数据包(提交登陆名和密码)
        int code = [[LocalDataSender sharedInstance] sendLogin:loginUserIdStr withToken:loginTokenStr];
        if(code == COMMON_CODE_OK)
        {
    //        [self E_showToastInfo:@"提示" withContent:@"登陆请求已发出。。。" onParent:self.view];
        }
        else
        {
    //        NSString *msg = [NSString stringWithFormat:@"登陆请求发送失败，错误码：%d", code];
    //        [self E_showToastInfo:@"错误" withContent:msg onParent:self.view];
    //        
    //        // * 登陆信息没有成功发出时当然无条件取消显示登陆进度条
    //        [self.onLoginProgress showProgressing:NO onParent:self.view];
        }
    }
    else {
        
    }    
}
    
#pragma mark - ChatBaseEvent
    /*!
     * 本地用户的登陆结果回调事件通知。
     *
     * @param errorCode 服务端反馈的登录结果：0 表示登陆成功，否则为服务端自定义的出错代码（按照约定通常为>=1025的数）
     */
    - (void)onLoginResponse:(int)errorCode
    {
        if (errorCode == 0)
        {
            NSLog(@"【DEBUG_UI】IM服务器登录/连接成功！");
            
            // UI显示
//            [CurAppDelegate refreshConnecteStatus];
//            [[CurAppDelegate getMainViewController] showIMInfo_green:[NSString stringWithFormat:@"登录成功,errorCode=%d", errorCode]];
        }
        else
        {
            NSLog(@"【DEBUG_UI】IM服务器登录/连接失败，错误代码：%d", errorCode);
            
            // UI显示
//            [[CurAppDelegate getMainViewController] showIMInfo_red:[NSString stringWithFormat:@"IM服务器登录/连接失败,code=%d", errorCode]];
        }
        
        // 此观察者只有开启程序首次使用登陆界面时有用
//        if(self.loginOkForLaunchObserver != nil)
//        {
//            self.loginOkForLaunchObserver(nil, [NSNumber numberWithInt:errorCode]);
//            
//            //## Try bug FIX! 20160810：上方的observer作为block代码应是被异步执行，此处立即设置nil的话，实测
//            //##                        中会遇到怎么也登陆不进去的问题（因为此observer已被过早的nil了！）
//    //        self.loginOkForLaunchObserver = nil;
//        }
    }

    /*!
     * 与服务端的通信断开的回调事件通知。
     *
     * <br>
     * 该消息只有在客户端连接服务器成功之后网络异常中断之时触发。
     * 导致与与服务端的通信断开的原因有（但不限于）：无线网络信号不稳定、WiFi与2G/3G/4G等同开情
     * 况下的网络切换、手机系统的省电策略等。
     *
     * @param errorCode 本回调参数表示表示连接断开的原因，目前错误码没有太多意义，仅作保留字段，目前通常为-1
     */
    - (void) onLinkClose:(int)errorCode
    {
        NSLog(@"【DEBUG_UI】与IM服务器的网络连接出错关闭了，error：%d", errorCode);
        
        // UI显示
//        [CurAppDelegate refreshConnecteStatus];
//        [[CurAppDelegate getMainViewController] showIMInfo_red:[NSString stringWithFormat:@"与IM服务器的连接已断开, 自动登陆/重连将启动! (%d)", errorCode]];
    }

#pragma mark - ChatMessageEvent

/*!
 * 收到普通消息的回调事件通知。
 * <br>
 * 应用层可以将此消息进一步按自已的IM协议进行定义，从而实现完整的即时通信软件逻辑。
 *
 * @param fingerPrintOfProtocal 当该消息需要QoS支持时本回调参数为该消息的特征指纹码，否则为null
 * @param userid 消息的发送者id（RainbowCore框架中规定发送者id=“0”即表示是由服务端主动发过的，否则表示的是其它客户端发过来的消息）
 * @param dataContent 消息内容的文本表示形式
 */
- (void) onRecieveMessage:(NSString *)fingerPrintOfProtocal withUserId:(NSString *)dwUserid andContent:(NSString *)dataContent andTypeu:(int)typeu
{
    NSLog(@"【DEBUG_UI】[%d]收到来自用户%@的消息:%@", typeu, dwUserid, dataContent);
    
    // UI显示
    // Make toast with an image & title
//    [[CurAppDelegate getMainView] makeToast:dataContent
//                duration:3.0
//                position:@"center"
//                   title:[NSString stringWithFormat:@"%@说：", dwUserid]
//                   image:[UIImage imageNamed:@"qzone_mark_img_myvoice.png"]];
//    [[CurAppDelegate getMainViewController] showIMInfo_black:[NSString stringWithFormat:@"%@说：%@", dwUserid, dataContent]];
}

/*!
 * 服务端反馈的出错信息回调事件通知。
 *
 * @param errorCode 错误码，定义在常量表 ErrorCode 中有关服务端错误码的定义
 * @param errorMsg 描述错误内容的文本信息
 * @see ErrorCode
 */
- (void) onErrorResponse:(int)errorCode withErrorMsg:(NSString *)errorMsg
{
    NSLog(@"【DEBUG_UI】收到服务端错误消息，errorCode=%d, errorMsg=%@", errorCode, errorMsg);
    
    // UI显示
//    if(errorCode == ForS_RESPONSE_FOR_UNLOGIN)
//    {
//        NSString *content = [NSString stringWithFormat:@"服务端会话已失效，自动登陆/重连将启动! (%d)", errorCode];
//        [[CurAppDelegate getMainViewController] showIMInfo_brightred:content];
//    }
//    else
//    {
//        NSString *content = [NSString stringWithFormat:@"Server反馈错误码：%d,errorMsg=%@", errorCode, errorMsg];
//        [[CurAppDelegate getMainViewController] showIMInfo_red:content];
//    }
}

#pragma mark - MessageQoSEvent

/*!
 * 消息未送达的回调事件通知.
 *
 * @param lostMessages 由MobileIMSDK QoS算法判定出来的未送达消息列表（此列表
 * 中的Protocal对象是原对象的clone（即原对象的深拷贝），请放心使用哦），应用层
 * 可通过指纹特征码找到原消息并可以UI上将其标记为”发送失败“以便即时告之用户
 */
- (void) messagesLost:(NSMutableArray*)lostMessages
{
    NSLog(@"【DEBUG_UI】收到系统的未实时送达事件通知，当前共有%li个包QoS保证机制结束，判定为【无法实时送达】！", (unsigned long)[lostMessages count]);
    
//    // UI显示
//    [[CurAppDelegate getMainViewController] showIMInfo_brightred:[NSString stringWithFormat:@"[消息未成功送达]共%li条!(网络状况不佳或对方id不存在)", [lostMessages count]]];
}

/*!
 * 消息已被对方收到的回调事件通知.
 * <p>
 * <b>目前，判定消息被对方收到是有两种可能：</b>
 * <br>
 * 1) 对方确实是在线并且实时收到了；<br>
 * 2) 对方不在线或者服务端转发过程中出错了，由服务端进行离线存储成功后的反馈
 * （此种情况严格来讲不能算是“已被收到”，但对于应用层来说，离线存储了的消息
 * 原则上就是已送达了的消息：因为用户下次登陆时肯定能通过HTTP协议取到）。
 *
 * @param theFingerPrint 已被收到的消息的指纹特征码（唯一ID），应用层可据此ID
 * 来找到原先已发生的消息并可在UI是将其标记为”已送达“或”已读“以便提升用户体验
 */
- (void) messagesBeReceived:(NSString *)theFingerPrint
{
    if(theFingerPrint != nil)
    {
        NSLog(@"【DEBUG_UI】收到对方已收到消息事件的通知，fp=%@", theFingerPrint);
        
        // UI显示
//        [[CurAppDelegate getMainViewController] showIMInfo_blue:[NSString stringWithFormat:@"[收到应答]%@", theFingerPrint]];
    }
}

@end
