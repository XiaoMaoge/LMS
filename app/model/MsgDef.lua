--[[-------------------------------------------------------------

Author:     Y.Zhang, york.zhang@sparkingfuture.com
Date:       2016-08-14 13:44:41
Version:    0.1
Company:    SparkingFuture LLC.

                Copyright (c) 2015, Y.Zhang

-------------------------------------------------------------]]--

GLOBAL {

MsgDef = {
    MSG_NONE                   = 0x0,

    MSG_HEART_BEATING          = 0xa10001,
    MSG_HEART_BEATING_ACK      = 0xa10002,

    MSG_GAME_LOGIN             = 0xc30001,
    MSG_GAME_LOGIN_ACK         = 0xc30023,

    MSG_LINK_VALIDATION        = 0xa10003,
    MSG_LINK_VALIDATION_ACK    = 0xa10004,

    MSG_CREATE_VIP_ROOM        = 0xc30100, --创建vip房间
    MSG_ENTER_VIP_ROOM         = 0xc30102,
    MSG_ENTER_VIP_ROOM_ACK     = 0xc30103,

    MSG_GAME_UPDATE_PLAYER_PROPERTY = 0xc30002, --更新玩家信息
    MSG_REQUEST_START_GAME     = 0xc30003,
    MSG_REQUEST_START_GAME_ACK = 0xc30004,
    
    MSG_PLAYER_OPERATION_NTF   = 0xc30061, --提醒玩家进行操作
    MSG_PLAYER_OPERATION       = 0xc30062,

    MSG_GAME_OPERATION         = 0xc30008,
    MSG_GAME_OPERATION_ACK     = 0xc30009,

    -- 牌局开始
    MSG_GAME_START             = 0xc30060,

    -- webview
    MSG_POST_USER_INFO          = 0xc30067,
    MSG_POST_USER_INFO_ACK      = 0xc30068,
    --

    MSG_GAME_OVER_ACK          = 0xc3000d, --游戏结束通知
    MSG_GAME_VIP_ROOM_CLOSE    = 0xc30200, --解散房间通知 
    MSG_GAME_OTHERLOGIN_ACK    = 0xc30205, --异地登录
    MSG_GET_PATCH_VESION       = 0x01000005, --获取版本更新信息
    MSG_GET_PATCH_VESION_ACK   = 0x01000006, --获取版本更新信息回复

    MSG_TALKING_IN_GAME        = 0xc30300, --聊天消息

    MSG_GET_GAME_LIST_CONFIG_REQ = 0x01000001, --C2S 合辑获取游戏列表
    MSG_GET_GAME_LIST_CONFIG_RSP = 0x01000002, --S2C 合辑获取游戏列表
    MSG_GET_IP_LIST_CONFIG_REQ = 0x01000003,
    MSG_GET_IP_LIST_CONFIG_RSP = 0x01000004,
    MSG_GET_LUNBOTU_REQ = 0x0100000b, --C2S 获取轮播图信息
    MSG_GET_LUNBOTU_RSP = 0x0100000c, --C2C 获取轮播图信息
},

-- result字段
MsgResult = {
    CMD_EXE_OK                          = 0,
    CMD_EXE_FAILED                      = 1000,
    WRONG_PASSWORD                      = 1001,
    FANGKIA_NOT_FOUND                   = 1100,  -- 房卡不足
    GOLD_LOW_THAN_MIN_LIMIT             = 1101,  -- 金币低于下限
    GOLD_HIGH_THAN_MAX_LIMIT            = 1102,  -- 金币超过上限
    CAN_ENTER_VIP_ROOM                  = 1103,  -- 可以进入VIP房间
    VIP_TABLE_IS_FULL                   = 1104,  -- vip桌子已经满座了
    VIP_TABLE_IS_GAME_OVER              = 1105,  -- VIP桌子已经结束了
    IS_PLAYING_CAN_NOT_ENTER_ROOM       = 1106,  -- 正在游戏中不能进入其他房间

    TODAY_GAME_RECORD_OUT_LIMIT_IN_ROOM = 1200,  -- 今日输赢超过房间上限
    TODAY_GAME_RECORD_OUT_LIMIT_IN_GAME = 1201,  -- 今日输赢超过游戏上限

    VIP_TABLE_NOT_FOUND                 = 1300,  -- 桌子未找到
},

-- 胡
MahjongHuCode = {
    DIAN_PAO          = 0x0002, -- 点炮
    MYSELF_ZHUANG_JIA = 0x0004, -- 自己是不是庄家
    ZI_MO             = 0x0008, -- 自摸
    QIANG_GANG_HU     = 0x010, -- 抢杠胡
    HUA_ZHU           = 0x020, -- 花猪
    DAI_GEN           = 0x040, -- 有四张一样的在手里，胡牌的时候，不包括杠
    CHA_HUA_ZHU       = 0x080, -- 查花猪
    TING              = 0x0100, -- 是否听牌
    TARGET_ZHUANG_JIA = 0x0200, -- 输赢的对方是庄家
    DAI_YAO_JIU       = 0x00400, -- 带幺九
    QINGYISE          = 0x00800, -- 清一色
    JIN_GOU_GOU       = 0x01000, -- 金钩钓，玩家胡牌时，其他牌都被用作碰牌、杠牌；手牌中只剩下唯一的一张牌，不计对对胡。
    LONG_QI_DUI       = 0x02000, -- 龙七对，玩家手牌为暗七对牌型，没有碰过或者杠过，并且有四张牌是一样的
    JIANG_JIN_GOU_GOU = 0x04000, -- 将金钩钓,指金钩钓里手牌、碰牌和杠牌的牌必须是2、5、8。
    PENG_PENG_HU      = 0x08000, -- 碰碰胡
    SHANG_PAO         = 0x10000, -- 杠上炮
    QIXIAODUI         = 0x20000, -- 七小对
    SHI_BA_LUO_HAN    = 0x40000, -- 十八罗汉
    SHANG_KAI_HUA     = 0x80000, -- 杠上花
    WIN               = 0x100000, -- 赢
    LOSE              = 0x200000, -- 输
    TIAN_HU           = 0x400000, -- 天胡
    DI_HU             = 0x800000, -- 地胡
    CHA_DA_JIAO       = 0x1000000, -- 查大叫
    LIU_JU            = 0x2000000, -- 流局
    DIAN_PAO_HU       = 0x4000000, -- 点炮胡
    PING_HU_ZI_MO     = 0x8000000, -- 平胡自摸加1番
    PING_HU           = 0x10000000, -- 平胡
    DIAN_GANG         = 0x20000000, -- 点杠
},

}




