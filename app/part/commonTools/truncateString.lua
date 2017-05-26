--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local truncateString = class("truncateString")

-- 字符串分割
-- 将每个字符串分离出来，放到table中，一个单元内一个字符
function truncateString:stringToTable(str)
    local tb = { }
    --[[
        UTF8的编码规则：  
        1. 字符的第一个字节范围： 0x00—0x7F(0-127),或者 0xC2—0xF4(194-244); UTF8 是兼容 ascii 的，所以 0~127 就和 ascii 完全一致  
        2. 0xC0, 0xC1,0xF5—0xFF(192, 193 和 245-255)不会出现在UTF8编码中   
        3. 0x80—0xBF(128-191)只会出现在第二个及随后的编码中(针对多字节编码，如汉字) 
    ]]
    for utfChar in string.gmatch(str, "[%z\1-\127\194-\244][\128-\191]*") do
        table.insert(tb, utfChar)
    end
    
    return tb
end

-- 获取字符串长度，设一个中文长度为2，其他长度为1
function truncateString:getUTFLen(str)
    local tableStr = self:stringToTable(str)

    local iLen = 0
    local iCharLen = 0

    for i = 1, table.maxn(tableStr) do
        local iUtfCharLen = string.len(tableStr[i])
        if iUtfCharLen > 1 then -- 长度大于1就认为是中文
            iCharLen = 2
        else
            iCharLen = 1
        end
        
        iLen = iLen + iCharLen
    end

    return iLen
    
end

-- 获取指定字符个数的字符串的实际长度，设一个中文长度为2，其他长度为1，count:-1表示不限制
function truncateString:getUTFLenWithCount(str, iCount)
    local tableString = self:stringToTable(str)

    local iLen = 0
    local iCharLen = 0
    local bIsLimited = (iCount > 0)

    for i = 1, table.maxn(tableString) do
        local iUtfCharLen = string.len(tableString[i])
        if iUtfCharLen > 1 then     --  长度大于1就认为是中文
            iCharLen = 2
        else
            iCharLen = 1
        end

        iLen = iLen + iUtfCharLen

        if true == bIsLimited then
            iCount = iCount - iCharLen
            if iCount <= 0 then
                break
            end

        end

    end
    return iLen
end

-- 截取指定字符个数的字符串，超过指定个数的，截取，然后添加...
function truncateString:getMaxLenString(str, iMaxLen)
    local iLen = self:getUTFLen(str)
    local dstString = str

    if iLen > iMaxLen  then
        dstString = string.sub(str, 1, self:getUTFLenWithCount(str, iMaxLen))
        dstString = dstString .. "..."
    end

    return dstString
end

return truncateString
--endregion
