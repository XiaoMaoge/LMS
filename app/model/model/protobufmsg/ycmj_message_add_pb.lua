-- Generated By protoc-gen-lua Do not Edit
local protobuf = require "protobuf"
cc.exports.ycmj_message_add_pb = {}

module('ycmj_message_add_pb')


local UPDATEPLAYERPROPERTYMSG = protobuf.Descriptor();
local UPDATEPLAYERPROPERTYMSG_GOLD_FIELD = protobuf.FieldDescriptor();
local UPDATEPLAYERPROPERTYMSG_DIAMOND_FIELD = protobuf.FieldDescriptor();
local UPDATEPLAYERPROPERTYMSG_SCORE_FIELD = protobuf.FieldDescriptor();
local UPDATEPLAYERPROPERTYMSG_WONS_FIELD = protobuf.FieldDescriptor();
local UPDATEPLAYERPROPERTYMSG_LOSES_FIELD = protobuf.FieldDescriptor();
local UPDATEPLAYERPROPERTYMSG_PLAYERTYPE_FIELD = protobuf.FieldDescriptor();
local UPDATEPLAYERPROPERTYMSG_PARENTINDEX_FIELD = protobuf.FieldDescriptor();
local UPDATEPLAYERPROPERTYMSG_SERVERCD_FIELD = protobuf.FieldDescriptor();
local UPDATEPLAYERPROPERTYMSG_PAYBACK_FIELD = protobuf.FieldDescriptor();

UPDATEPLAYERPROPERTYMSG_GOLD_FIELD.name = "gold"
UPDATEPLAYERPROPERTYMSG_GOLD_FIELD.full_name = ".ycmj.message.add_protobuf.UpdatePlayerPropertyMsg.gold"
UPDATEPLAYERPROPERTYMSG_GOLD_FIELD.number = 1
UPDATEPLAYERPROPERTYMSG_GOLD_FIELD.index = 0
UPDATEPLAYERPROPERTYMSG_GOLD_FIELD.label = 1
UPDATEPLAYERPROPERTYMSG_GOLD_FIELD.has_default_value = false
UPDATEPLAYERPROPERTYMSG_GOLD_FIELD.default_value = 0
UPDATEPLAYERPROPERTYMSG_GOLD_FIELD.type = 13
UPDATEPLAYERPROPERTYMSG_GOLD_FIELD.cpp_type = 3

UPDATEPLAYERPROPERTYMSG_DIAMOND_FIELD.name = "diamond"
UPDATEPLAYERPROPERTYMSG_DIAMOND_FIELD.full_name = ".ycmj.message.add_protobuf.UpdatePlayerPropertyMsg.diamond"
UPDATEPLAYERPROPERTYMSG_DIAMOND_FIELD.number = 2
UPDATEPLAYERPROPERTYMSG_DIAMOND_FIELD.index = 1
UPDATEPLAYERPROPERTYMSG_DIAMOND_FIELD.label = 1
UPDATEPLAYERPROPERTYMSG_DIAMOND_FIELD.has_default_value = false
UPDATEPLAYERPROPERTYMSG_DIAMOND_FIELD.default_value = 0
UPDATEPLAYERPROPERTYMSG_DIAMOND_FIELD.type = 13
UPDATEPLAYERPROPERTYMSG_DIAMOND_FIELD.cpp_type = 3

UPDATEPLAYERPROPERTYMSG_SCORE_FIELD.name = "score"
UPDATEPLAYERPROPERTYMSG_SCORE_FIELD.full_name = ".ycmj.message.add_protobuf.UpdatePlayerPropertyMsg.score"
UPDATEPLAYERPROPERTYMSG_SCORE_FIELD.number = 3
UPDATEPLAYERPROPERTYMSG_SCORE_FIELD.index = 2
UPDATEPLAYERPROPERTYMSG_SCORE_FIELD.label = 1
UPDATEPLAYERPROPERTYMSG_SCORE_FIELD.has_default_value = false
UPDATEPLAYERPROPERTYMSG_SCORE_FIELD.default_value = 0
UPDATEPLAYERPROPERTYMSG_SCORE_FIELD.type = 5
UPDATEPLAYERPROPERTYMSG_SCORE_FIELD.cpp_type = 1

UPDATEPLAYERPROPERTYMSG_WONS_FIELD.name = "wons"
UPDATEPLAYERPROPERTYMSG_WONS_FIELD.full_name = ".ycmj.message.add_protobuf.UpdatePlayerPropertyMsg.wons"
UPDATEPLAYERPROPERTYMSG_WONS_FIELD.number = 4
UPDATEPLAYERPROPERTYMSG_WONS_FIELD.index = 3
UPDATEPLAYERPROPERTYMSG_WONS_FIELD.label = 1
UPDATEPLAYERPROPERTYMSG_WONS_FIELD.has_default_value = false
UPDATEPLAYERPROPERTYMSG_WONS_FIELD.default_value = 0
UPDATEPLAYERPROPERTYMSG_WONS_FIELD.type = 5
UPDATEPLAYERPROPERTYMSG_WONS_FIELD.cpp_type = 1

UPDATEPLAYERPROPERTYMSG_LOSES_FIELD.name = "loses"
UPDATEPLAYERPROPERTYMSG_LOSES_FIELD.full_name = ".ycmj.message.add_protobuf.UpdatePlayerPropertyMsg.loses"
UPDATEPLAYERPROPERTYMSG_LOSES_FIELD.number = 5
UPDATEPLAYERPROPERTYMSG_LOSES_FIELD.index = 4
UPDATEPLAYERPROPERTYMSG_LOSES_FIELD.label = 1
UPDATEPLAYERPROPERTYMSG_LOSES_FIELD.has_default_value = false
UPDATEPLAYERPROPERTYMSG_LOSES_FIELD.default_value = 0
UPDATEPLAYERPROPERTYMSG_LOSES_FIELD.type = 5
UPDATEPLAYERPROPERTYMSG_LOSES_FIELD.cpp_type = 1

UPDATEPLAYERPROPERTYMSG_PLAYERTYPE_FIELD.name = "playerType"
UPDATEPLAYERPROPERTYMSG_PLAYERTYPE_FIELD.full_name = ".ycmj.message.add_protobuf.UpdatePlayerPropertyMsg.playerType"
UPDATEPLAYERPROPERTYMSG_PLAYERTYPE_FIELD.number = 6
UPDATEPLAYERPROPERTYMSG_PLAYERTYPE_FIELD.index = 5
UPDATEPLAYERPROPERTYMSG_PLAYERTYPE_FIELD.label = 1
UPDATEPLAYERPROPERTYMSG_PLAYERTYPE_FIELD.has_default_value = false
UPDATEPLAYERPROPERTYMSG_PLAYERTYPE_FIELD.default_value = 0
UPDATEPLAYERPROPERTYMSG_PLAYERTYPE_FIELD.type = 5
UPDATEPLAYERPROPERTYMSG_PLAYERTYPE_FIELD.cpp_type = 1

UPDATEPLAYERPROPERTYMSG_PARENTINDEX_FIELD.name = "parentIndex"
UPDATEPLAYERPROPERTYMSG_PARENTINDEX_FIELD.full_name = ".ycmj.message.add_protobuf.UpdatePlayerPropertyMsg.parentIndex"
UPDATEPLAYERPROPERTYMSG_PARENTINDEX_FIELD.number = 7
UPDATEPLAYERPROPERTYMSG_PARENTINDEX_FIELD.index = 6
UPDATEPLAYERPROPERTYMSG_PARENTINDEX_FIELD.label = 1
UPDATEPLAYERPROPERTYMSG_PARENTINDEX_FIELD.has_default_value = false
UPDATEPLAYERPROPERTYMSG_PARENTINDEX_FIELD.default_value = 0
UPDATEPLAYERPROPERTYMSG_PARENTINDEX_FIELD.type = 5
UPDATEPLAYERPROPERTYMSG_PARENTINDEX_FIELD.cpp_type = 1

UPDATEPLAYERPROPERTYMSG_SERVERCD_FIELD.name = "serverCD"
UPDATEPLAYERPROPERTYMSG_SERVERCD_FIELD.full_name = ".ycmj.message.add_protobuf.UpdatePlayerPropertyMsg.serverCD"
UPDATEPLAYERPROPERTYMSG_SERVERCD_FIELD.number = 8
UPDATEPLAYERPROPERTYMSG_SERVERCD_FIELD.index = 7
UPDATEPLAYERPROPERTYMSG_SERVERCD_FIELD.label = 1
UPDATEPLAYERPROPERTYMSG_SERVERCD_FIELD.has_default_value = false
UPDATEPLAYERPROPERTYMSG_SERVERCD_FIELD.default_value = 0
UPDATEPLAYERPROPERTYMSG_SERVERCD_FIELD.type = 5
UPDATEPLAYERPROPERTYMSG_SERVERCD_FIELD.cpp_type = 1

UPDATEPLAYERPROPERTYMSG_PAYBACK_FIELD.name = "payBack"
UPDATEPLAYERPROPERTYMSG_PAYBACK_FIELD.full_name = ".ycmj.message.add_protobuf.UpdatePlayerPropertyMsg.payBack"
UPDATEPLAYERPROPERTYMSG_PAYBACK_FIELD.number = 9
UPDATEPLAYERPROPERTYMSG_PAYBACK_FIELD.index = 8
UPDATEPLAYERPROPERTYMSG_PAYBACK_FIELD.label = 1
UPDATEPLAYERPROPERTYMSG_PAYBACK_FIELD.has_default_value = false
UPDATEPLAYERPROPERTYMSG_PAYBACK_FIELD.default_value = 0.0
UPDATEPLAYERPROPERTYMSG_PAYBACK_FIELD.type = 2
UPDATEPLAYERPROPERTYMSG_PAYBACK_FIELD.cpp_type = 6

UPDATEPLAYERPROPERTYMSG.name = "UpdatePlayerPropertyMsg"
UPDATEPLAYERPROPERTYMSG.full_name = ".ycmj.message.add_protobuf.UpdatePlayerPropertyMsg"
UPDATEPLAYERPROPERTYMSG.nested_types = {}
UPDATEPLAYERPROPERTYMSG.enum_types = {}
UPDATEPLAYERPROPERTYMSG.fields = {UPDATEPLAYERPROPERTYMSG_GOLD_FIELD, UPDATEPLAYERPROPERTYMSG_DIAMOND_FIELD, UPDATEPLAYERPROPERTYMSG_SCORE_FIELD, UPDATEPLAYERPROPERTYMSG_WONS_FIELD, UPDATEPLAYERPROPERTYMSG_LOSES_FIELD, UPDATEPLAYERPROPERTYMSG_PLAYERTYPE_FIELD, UPDATEPLAYERPROPERTYMSG_PARENTINDEX_FIELD, UPDATEPLAYERPROPERTYMSG_SERVERCD_FIELD, UPDATEPLAYERPROPERTYMSG_PAYBACK_FIELD}
UPDATEPLAYERPROPERTYMSG.is_extendable = false
UPDATEPLAYERPROPERTYMSG.extensions = {}

UpdatePlayerPropertyMsg = protobuf.Message(UPDATEPLAYERPROPERTYMSG)

