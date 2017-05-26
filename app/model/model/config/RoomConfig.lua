cc.exports.RoomConfig = {}
RoomConfig.TableSeatNum = 4 --座位数
RoomConfig.WaitTime = 15 --等待时间

RoomConfig.HandCardNum = 13 --最大手牌数

RoomConfig.MySeat = 1 --我的位置
RoomConfig.DownSeat = 2 --下家
RoomConfig.FrontSeat = 3 --对家
RoomConfig.UpSeat = 4 --上家

RoomConfig.HandCard = 1 --手牌
RoomConfig.DownCard = 2 --碰杠的牌
RoomConfig.OutCard = 3 --出的牌
RoomConfig.HuCard = 4 --胡的牌
RoomConfig.TingCard  = 5 --听的牌

RoomConfig.Chi = 0x01
RoomConfig.Peng = 0x02
RoomConfig.AnGang = 0x04
RoomConfig.MingGang = 0x08
RoomConfig.BuHua = 0x100
RoomConfig.JinPai = 0x80000


RoomConfig.BuGang = 0x20000000
RoomConfig.Gang = 0x2000000 --血流麻将会冲突

RoomConfig.Character = 0 --万
RoomConfig.Bamboo = 1 --条
RoomConfig.Dot = 2 --筒
RoomConfig.Wind = 3 --风
RoomConfig.Hua =4

RoomConfig.EmptyCard = 0x39
RoomConfig.LYPayAA = 0 --4人分摊


RoomConfig.CardType = {
    [RoomConfig.Character] = "character", --万
    [RoomConfig.Bamboo]    = "bamboo", --条
    [RoomConfig.Dot]       = "dot", --筒
    [RoomConfig.Wind]      = "wind", --风
    [RoomConfig.Hua]      = "hua", --风
}

--红中麻将规则
RoomConfig.Rule = {
	[1] = 0x1, --红中麻将
	[2] = 0x2, --合肥点炮
	[3] = 0x100, --合肥自摸
	[4] = 0x40 --湖南红中
}

--玩法带码
RoomConfig.RuleMa = {
	[0] = 0x80, --无码
	[1] = 0x10, --2码
	[2] = 0x8, --4码
	[3] = 0x20, --6码
	[4] = 0x4, --3码
}

--玩法
RoomConfig.PlayRule = {
	[1] = 0x10000, --个旧
	[2] = 0x20000, --保山
	[3] = 0x800000, --龙岩半自摸
	[4] = 0x1000000, --龙岩全自摸
	[5] = 0x4, --游金4倍
	[6] = 0x5, --游金5倍	
}

--胡的类型
RoomConfig.LONG_YAN_DAN_YOU    		= 0x00400   -- 龙岩,单游
RoomConfig.LONG_YAN_SHUANG_YOU 		= 0x0800    -- 龙岩,双游
RoomConfig.LONG_YAN_SAN_YOU 		= 0x1000    -- 龙岩,三游
RoomConfig.LONG_HUA_HU 				= 0x2000    -- 龙岩,花胡
RoomConfig.LONG_YAN_QIANG_JIN 		= 0x4000    -- 龙岩,抢金
RoomConfig.LONG_YAN_GAI_JIN_QIANG 	= 0x8000  	-- 龙岩,盖金枪
RoomConfig.LONG_YAN_SAN_JIN_DAO 	= 0x10000   -- 龙岩,三金倒
RoomConfig.LONG_YAN_SI_JIN_DAO 		= 0x20000   -- 龙岩,四金倒
RoomConfig.LONG_YAN_WU_JIN_DAO 		= 0x40000   -- 龙岩,五金倒
RoomConfig.LONG_YAN_LIU_JIN_DAO 	= 0x80000   -- 龙岩,六金倒


RoomConfig.GAME_OPERATION_APPLY_CLOSE_VIP_ROOM = 1034 --房主申请解散VIP房间

RoomConfig.MAHJONG_OPERTAION_NONE =0x0--无操作
RoomConfig.MAHJONG_OPERTAION_CHI =0x01--吃
RoomConfig.MAHJONG_OPERTAION_PENG =0x02--碰
RoomConfig.MAHJONG_OPERTAION_AN_GANG =0x04--暗杠
RoomConfig.MAHJONG_OPERTAION_MING_GANG =0x08--明杠
RoomConfig.MAHJONG_OPERTAION_CHU =0x10--出牌
RoomConfig.MAHJONG_OPERTAION_HU =0x20--胡牌
RoomConfig.MAHJONG_OPERTAION_TING =0x40--听牌
RoomConfig.MAHJONG_OPERTAION_CANCEL =0x80--给玩家提示操作，玩家点取消

RoomConfig.MAHJONG_BU_HUA       			= 0x100 -- 补花
RoomConfig.MAHJONG_QIANG_JIN                = 0x200 -- 抢金
RoomConfig.MAHJONG_SAN_JIN_DAO              = 0x400 -- 三金倒
RoomConfig.MAHJONG_SI_JIN_DAO               = 0x800 -- 四金倒
RoomConfig.MAHJONG_WU_JIN_DAO               = 0x1000 -- 五金倒
RoomConfig.MAHJONG_LIU_JIN_DAO              = 0x2000 -- 六金倒
RoomConfig.MAHJONG_DAN_YOU                  = 0x4000 -- 单游
RoomConfig.MAHJONG_SHUANG_YOU               = 0x8000 -- 双游
RoomConfig.MAHJONG_SAN_YOU                  = 0x10000 -- 三游
RoomConfig.MAHJONG_HU_CODE_QIXIAODUI        = 0x400000 --七小对

RoomConfig.MAHJONG_CHA_PAI                  = 0x20000 -- 查牌
RoomConfig.MAHJONG_CHA_HUA                  = 0x40000 -- 查花
RoomConfig.MAHJONG_JIN_PAI                  = 0x80000 -- 通知金牌
RoomConfig.MAHJONG_OPERTAION_TIP_CARD_YJ	= 0x100000 --提示可游金之出牌
RoomConfig.Gang 							= 0x2000000

RoomConfig.MAHJONG_OPERTAION_OFFLINE 					=0x4000000--断线
RoomConfig.MAHJONG_OPERTAION_ONLINE 					=0x8000000--断线后又上线
RoomConfig.MAHJONG_OPERTAION_AUTO_CHU 					=0xC000000--听牌后自动出牌
RoomConfig.MAHJONG_OPERTAION_GAME_OVER 					=0x10000000--牌局结束

RoomConfig.MAHJONG_OPERTAION_GAME_OVER_CHANGE_TABLE 	=0x14000000--牌局结束，玩家选择换桌
RoomConfig.MAHJONG_OPERTAION_GAME_OVER_CONTINUE 		=0x18000000--牌局结束，玩家选择继续开始游戏

RoomConfig.MAHJONG_OPERTAION_SEARCH_VIP_ROOM 			=0x1C000000 --客户端通知服务器查找vip房间 **/
RoomConfig.MAHJONG_OPERTAION_ADD_CHU_CARD 				=0x20000000 --玩家打出的牌，没有被人吃碰胡，在打这个牌的玩家面前摆一张牌 **/
RoomConfig.MAHJONG_OPERTAION_SHOW_TABLE_TIPS 			=0x24000000 --[[显示提示在桌面--]]
RoomConfig.MAHJONG_OPERTAION_TIP 						=0x28000000--[[提示当前谁在操作--]]

RoomConfig.MAHJONG_OPERTAION_PLAYER_HU_CONFIRMED 		=0x2C000000--玩家点胡，此局结束显示结果
RoomConfig.MAHJONG_OPERTAION_OVERTIME_AUTO_CHU 			=0x30000000--超时自动出牌
RoomConfig.MAHJONG_OPERTAION_EXTEND_CARD_REMIND 		=0x34000000--提醒房主续卡
RoomConfig.MAHJONG_OPERTAION_EXTEND_CARD_SUCCESSFULLY   =0x38000000--提醒房主续卡成功
RoomConfig.MAHJONG_OPERTAION_WAITING_OR_CLOSE_VIP   	=0x3C000000--VIP房间有人逃跑，是否继续等待
																	-- 向服务端请求解散VIP房间状态全量消息操作

RoomConfig.MAHJONG_OPERTAION_NO_START_CLOSE_VIP  		=0x40000000--VIP房间超时未开始游戏，房间结束
RoomConfig.MAHJONG_OPERTAION_EXTEND_CARD_FAILED 		=0x44000000--提醒房主续卡失败

RoomConfig.MAHJONG_OPERTAION_HU_CARD_LIST_UPDATE 		=0x48000000--提醒玩家可以胡的牌
RoomConfig.BuGang 	= 0x4C000000
RoomConfig.MAHJONG_OPERTAION_BU_GANG 					=0x4C000000 --补杠，自己摸起来，3个已经碰了，再补杠
RoomConfig.MAHJONG_REMOE_CHU_CARD						=0x50000000 --玩家打出的牌，被吃碰杠走了
RoomConfig.MAHJONG_OPERATION_GET_CLOSE_VIP_ROOM_MSG 	=0x54000000 --查询关闭房间全量
RoomConfig.NOTIFY_CHA 									=0x58000000 --通知谁查牌了

RoomConfig.MAHJONG_OPERTAION_POP_LAST 					=0x70000000 --提示抓尾，云南麻将系列的字段 与 血流的有冲突




RoomConfig.Ai_Debug = false --是否开启ai数据