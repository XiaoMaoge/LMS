--[[-------------------------------------------------------------

Author:     Y.Zhang, york.zhang@sparkingfuture.com
Date:       2016-08-14 12:46:47
Version:    0.1
Company:    SparkingFuture LLC.

                Copyright (c) 2015, Y.Zhang

-------------------------------------------------------------]]--

import(".MsgDef")
import(".OperationDef")
--import(".CardDef")

GLOBAL {
NET_STATE = {
  CONNECT_SUC = 1,--网络连接成功
  CONNECT_FAIL = 2,--网络连接失败
  CONNECT_CHECK_OK = 4,--网络校验成功
},
HTTP_STATE_SUCCESS = 200, --http请求成功
DEVICE_INFO = {},

-- 服务器地址
-- SERVER_HOST = "115.159.48.163",
-- SERVER_PORT = 15200,
PROJ_VERSION = "v 1.2.5.20170117_r",
QUICK_LOGIN = true, --是否快速登录绕过微信
QUICK_START_SUB_GAME = false, --是否快速开始子游戏，绕过热更新
IOS_BACK_DELAY = true, --ios默认需要延时切换后台不立即断线
TEST_MODE = false,--是否开启测试模式
SERVER_LIST = {

    {
        --HOST = "llmj-gw.gz.1251697691.clb.myqcloud.com",
        HOST = "llmj-ifm-ios.gate.xingyuhudong.com",
        --HOST = "192.168.1.231",
        --PORT = 17765,
        PORT = 9104,
        TYPE = 1
    }, 
    {
        --HOST = "119.29.47.205",
        --HOST = "192.168.1.231",
        --PORT = 17765,
        PORT = 9104,
        TYPE = 0
    },  
    {
        -- HOST = "119.29.18.169",
        --PORT = 17765,
        PORT = 9104,
        TYPE = 0
    },
    {
         --HOST = "139.199.188.249",
         PORT = 9104,
         TYPE = 0
     }  
},

TEST_SERVER_LIST ={
    {
        HOST = "119.29.222.68",
        -- HOST = "192.168.1.175",
        --PORT = 17765,
        PORT = 9104,
        TYPE = 1
    }, 
},

GAME_LIST = { --游戏列表后期应该是从服务器拉去配置
    {
        game_name = "开始游戏",
        game_id =   0x00070101,
        game_part = "app.part.mjlogin.LYLoginPart", --游戏大厅界面入口
    },
    -- {
    --     game_name = "血流麻将",
    --     game_id = 2,
    --     game_part = "app.ycmj.YcLobbyPart", --游戏大厅界面入口
    -- },{
    --     game_name = "湖南麻将",
    --     game_id = 3,
    --     game_part = "app.ycmj.YcLobbyPart", --游戏大厅界面入口
    -- }
},


--数据存取
enUserData = {
    KEY_SOUND_MUTE = "KEY_SOUND_MUTE",
    KEY_MUSIC_MUTE = "KEY_MUSIC_MUTE",
    ASSETS_TOKEN = "ASSETS_TOKEN",
    KEY_CUR_MUSIC = "KEY_CUR_MUSIC",
    KEY_CUR_SOUND = "KEY_CUR_SOUND",
},


--模块定义
ModuleDef = {
    NET_MOD =1,--网络
    AUDIO_MOD = 2,--声音
    STORAGE_MOD = 3,--存储模块
    BRIDGE_MOD = 4,--应用层调用模块
    HTTP_MOD = 5,--http调用
    AI_MOD = 6,--ai简单模块
},


-- 部件ID定义
PartDef = {
    INVALID = 0,
},

-- webview
WEBVIEW = {
  POST_MESSAGE_OPERATION                = 100, -- 客户端向服务器上传来自WEBVIEW数据
  POST_MESSAGE_OPERATION_ACK            = 101, -- 服务器发给客户端的参数
  POST_MESSAGE_OPERATION_OPEN_WEBVIEW   = 102, -- 服务器发给客户端需要打开WEBVIEW链接
},
--

WRITE_LOG_TO_FILE_ENABLE = false  --是否开启日志写文件功能
}
