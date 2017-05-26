--[[-------------------------------------------------------------

Author:     Y.Zhang, york.zhang@sparkingfuture.com
Date:       2016-08-24 15:30:17
Version:    0.1
Company:    SparkingFuture LLC.

                Copyright (c) 2015, Y.Zhang

-------------------------------------------------------------]]--

GLOBAL {
    GameOperation = {
        REQUEST_UPDATE_PALYER_DATA  = 1002,

        -- 服务器通知客户端，多人战斗开始
        MULTI_PLAY_START  = 1003,
        -- 服务器通知客户端，桌子上坐上一个新玩家
        TABLE_ADD_NEW_PLAYER = 1004,
        -- 服务器通知客户端，桌子上有玩家离开
        PLAYER_LEFT_TABLE  = 1005,
        -- 服务器通知客户端，本局时间到，游戏结束
        GAME_TIME_OVER = 1006,

        -- 客户端通知服务器，购买物品
        BUY_ITEM = 1007,

        -- 客户端通知服务器，使用道具
        USE_ITEM = 1008,
        -- 客户端通知服务器，更换头像
        CHANGE_HEAD = 1009,

        -- 客户端通知服务器，游戏结束，玩家继续游戏
        CONTINUE_GAME = 1010,
        -- 客户端通知服务器，游戏结束，玩家返回大厅
        BACK_TO_LOBBY = 1011,

        -- 客户端通知服务器，购买单机生命值
        BUY_LIFE = 1012,

        -- 客户端通知服务器，购买大礼包
        BUY_BIG_GIFT = 1013,

        -- 客户端通知服务器，领取礼品卡
        EXCHANGE_GIFT_CODE = 1014,

        -- 客户端通知服务器，修改名字
        CHANGENAME = 1015,

        -- 客户端通知服务器，死了重生
        DEAD_ALIVE = 1016,

        -- 客户端通知服务器，晶石换金币
        GEM_EXCHANGE_GOLD = 1017,

        -- 客户端通知服务器第一局新手指引结束
        GUIDE_GAME_OVER = 1018,

        -- 个人信息修改操作ID定义
        CHANGED_PASSWORD = 1025,        -- 修改密码
        CHANGED_LOGO     = 1026,        -- 修改头象
        CHANGED_CANFRIEND = 1027,       -- 是否允许加好友


        GOT_GOLD_AUTO_SAVE = 1028,      -- 系统救济，赠送金币

        SET_TUOGUAN      = 1029,        -- 设置托管状态

        ROOM_DISMISS  = 1030,       -- 房主离开，房间解散
        CHANGEPLAYERACCOUNT  = 1031,        -- 修改玩家账号

        COMPLETE_ACCOUNT_AND_PASSWORD = 1033,   -- 补全帐号和密码

        APPLY_CLOSE_VIP_ROOM = 1034,        -- 房主申请解散VIP房间

        -- 同意好友验证消息
        AGREE_FRIEND_APPLY_RESULT  = 1035,

        -- 拒绝好友验证消息
        REJECT_FRIEND_APPLY_RESULT  = 1036,

        -- 绑定手机号码
        COMPLETE_PHONE_NUMBER = 1037,

        -- 上传位置信息
        UPLOAD_CITY_NAME = 1038,

        UPLOAD_RECOMMANDER = 1039,

        BUY_DIAMOND  = 1050,
    },

    MahjongOperation = {
        NONE                     = 0x0,   -- 无操作
        CHI                      = 0x01,  -- 吃
        PENG                     = 0x02,  -- 碰
        AN_GANG                  = 0x04,  -- 暗杠
        MING_GANG                = 0x08,  -- 明杠
        CHU                      = 0x10,  -- 出牌
        HU                       = 0x20,  -- 胡牌
        TING                     = 0x40,  -- 听牌
        CANCEL                   = 0x80,  -- 给玩家提示操作，玩家点取消
        BU_HUA                   = 0x100, -- 补花

        QIANG_JIN                = 0x200, -- 抢金
        SAN_JIN_DAO              = 0x400, -- 三金倒
        SI_JIN_DAO               = 0x800, -- 四金倒
        WU_JIN_DAO               = 0x1000, -- 五金倒
        LIU_JIN_DAO              = 0x2000, -- 六金倒

        DAN_YOU                  = 0x4000, -- 单游
        SHUANG_YOU               = 0x8000, -- 双游
        SAN_YOU                  = 0x10000, -- 三游

        CHA_PAI                  = 0x20000, -- 查牌
        CHA_HUA                  = 0x40000, -- 查花
        JIN_PAI                  = 0x80000, -- 通知金牌
        GANG                     = 0x2000000, -- 杠        
		BU_GANG 				 = 0x100000,-- 补杠
		GANG_NOTIFY				 = 0x9914878,--玩家杠的通知

        OFFLINE                  = 0x4000000, -- 短线
        ONLINE                   = 0x8000000, -- 断线后又上线
        AUTO_CHU                 = 0xC000000, -- 听牌后自动出牌
        GAME_OVER                = 0x10000000, -- 牌局结束
        GAME_OVER_CHANGE_TABLE   = 0x14000000, -- 牌局结束，玩家选择换桌
        GAME_OVER_CONTINUE       = 0x18000000, -- 牌局结束，玩家选择继续开始游戏
        SEARCH_VIP_ROOM          = 0x1C000000, -- 客户端通知服务器查找vip房间
        ADD_CHU_CARD             = 0x20000000, -- 32768玩家打出的牌，没有被人吃碰胡，在打这个牌的玩家面前摆一张牌
        SHOW_TABLE_TIPS          = 0x24000000,-- 显示提示在桌面
        TIP                      = 0x28000000,-- 131072提示当前谁在操作
        PLAYER_HU_CONFIRMED      = 0x2C000000,     -- 玩家点胡，此局结束显示结果
        OVERTIME_AUTO_CHU        = 0x30000000,     -- 524288超时自动出牌
        EXTEND_CARD_REMIND       = 0x34000000,    -- 提醒房主续卡
        EXTEND_CARD_SUCCESSFULLY = 0x38000000,    -- 提醒房主续卡成功
        WAITING_OR_CLOSE_VIP     = 0x3C000000,    -- VIP房间有人逃跑，是否继续等待
        NO_START_CLOSE_VIP       = 0x40000000,    -- VIP房间超时未开始游戏，房间结束
        EXTEND_CARD_FAILED       = 0x44000000,   -- 提醒房主续卡失败
        HU_CARD_LIST_UPDATE      = 0x48000000,  -- 268435456提醒玩家可以胡的牌
        BU_GANG                  = 0x4C000000,  -- 补杠，自己摸起来，3个已经碰了，再补杠
        REMOE_CHU_CARD           = 0x50000000,  -- 1073741824玩家打出的牌，被吃碰杠走了
        GET_CLOSE_VIP_ROOM_MSG   = 0x54000000,  --查询关闭房间全量
        NOTIFY_CHA               = 0x58000000,  --通知谁查牌了
    },

    -- 客户端定义，用于播放音效
    PlayerOperationType = {
        PENG      = 1,
        HU        = 2,
        ZIMO      = 3,
        GANG      = 4,
        PIAOHU    = 5,
        QIXIAODUI = 6,
        QINGYISE  = 7,
    },
}
