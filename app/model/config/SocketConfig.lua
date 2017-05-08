cc.exports.SocketConfig = {}

SocketConfig.IS_SEQ 										= true	                    --双序号开关 true 开 false关
SocketConfig.GAME_ID 										= 0x70000 			

SocketConfig.MSG_GAME_SEND_SCROLL_MES			 			= 0xc30015		            --跑马灯协议

SocketConfig.MSG_GET_VIP_ROOM_RECORD 			 			= 0xc30063		            --查询玩家vip战绩
SocketConfig.MSG_GET_VIP_ROOM_RECORD_ACK 		 			= 0xc30064		            --vip战绩消息列表

SocketConfig.MSG_SYSTEM_NOTIFY_MSG		 		 			= 0xc30500		            --系统消息

SocketConfig.MSG_CLOSE_VIP_TABLE_ACK             			= 0xc30086                  --关闭房间ack
SocketConfig.MSG_NOTIFY_SEQ_TO_CLIENT_MSG        			= 0xc30087                  --收到刷新序号消息，向服务器获取解散房间状态

SocketConfig.MSG_REQUEST_BUY_DAOJU							= 0xc30071		            --流水查询
SocketConfig.MSG_GAME_GET_PLAYER_DIAMOND_LOG_ACK			= 0xC3025A		            --流水查询ack
SocketConfig.SEND_PLAYER_CMD_GET_MY_SEND_DIAMOND_LOG		= 0x17676	                --流水查询 支出
SocketConfig.SEND_PLAYER_CMD_GET_MY_ADD_DIAMOND_LOG		 	= 0x17677	                --流水查询 收入
SocketConfig.SEND_PLAYER_CMD_GET_MY_SUB_DIAMOND_LOG			= 0x17678	                --流水查询 总收入

SocketConfig.MSG_GET_IP_LIST_CONFIG_REQ						= 0X01000003 				--线路切换发送
SocketConfig.MSG_GET_IP_LIST_CONFIG_RSP 					= 0X01000004				--线路切换ack

SocketConfig.MSG_GET_GAME_CONFIG_REQ 						= 0x01000007				--申请代理
SocketConfig.MSG_GET_GAME_CONFIG_RSP 						= 0x01000008				--申请代理ack

SocketConfig.MSG_GET_PLAYERS_GPS_INFO 						= 0xc30503				    --发送GPS位置
SocketConfig.MSG_GET_PLAYERS_GPS_INFO_ACK 					= 0xc30504				    --GPS ack
