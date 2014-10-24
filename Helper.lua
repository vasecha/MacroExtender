local L = ME_GetLocale()
_, ME_Title = GetAddOnInfo("MacroExtender")

CreateFrame("GameTooltip","ME_SpellTooltip",UIParent,'GameTooltipTemplate')
ME_SpellTooltip:Hide()

CreateFrame("GameTooltip","ME_BuffTooltip",UIParent,'GameTooltipTemplate')
ME_BuffTooltip:SetFrameStrata("TOOLTIP")
ME_BuffTooltip:Hide()

CreateFrame("GameTooltip","ME_InvTooltip",UIParent,'GameTooltipTemplate')
ME_InvTooltip:SetFrameStrata("TOOLTIP")
ME_InvTooltip:Hide()

function ME_Print( ... )
        if DEFAULT_CHAT_FRAME then
                DEFAULT_CHAT_FRAME:AddMessage(ME_Title ..': '.. string.format(unpack(arg)))
        end
end

--Similar to DevTool_Dump but very lightweight
function PXED_PrintArgs( tbl )
        local str = ""
        for k,v in pairs(tbl) do
                local s = v
                
                if s == nil then
                        s = "nil"
                elseif type(s) ~= "string" then
                        s = tostring(s)
                end
                
                str = str .. k..'='..s ..', '
        end
        
        ME_Print("%s",str)
end

function IsString( param )
        return string.find(param,"%a+")
end

function IsNumber( param )
        if string.find(param,"^%d+$") then
                return tonumber(param)
        end
end

function Select(a,...)
        if type(a) == "string" and a == "#" then
                return arg.n
        else
                return arg[a]
        end
end

function WipeTable( tab )
        for k,v in pairs(tab) do
                tab[k] = nil
        end
end

function strtrim(s)
        return string.gsub(string.gsub(s, "^%s+", ""), "%s+$", "")
end

-- strsplit now fully functional from WoWiki Api
-- http://www.wowwiki.com/API_strsplit
function strsplit (sep, list, pieces)
        pieces  = pieces or 0
        local rest
        local start, pos = 1, string.find(list, sep)
        if pos then
                local s = {}
                local pc = 1
                while pos do
                        local ss = strtrim(string.sub(list,start, pos - 1))
                        
                        if pieces > 0 and pc >= pieces  then
                                ss = strtrim(string.sub(list,start))
                                table.insert(s, ss)
                                break
                        end
                        
                        table.insert(s, ss)
                        
                        pc = pc + 1
                        start = pos + 1
                        pos = string.find(list, sep, start)
                end
                table.insert(s, string.sub(list,start, -1))
                return unpack(s)
        else
                return list
        end
end

function splitNext(sep, body)
        if (body) then
                local pre, post = strsplit(sep, body, 2);
                if (post) then
                        return post, pre;
                end
                return false, body;
        end
end
function commaIterator(str) return splitNext, ",", str; end



function GetItemInfoType(link)
        local id = link
        if type(link) == "string" then
                id = ME_GetLinkInfo(link)
        end
        
        local _, _, _, _, itemType, itemSubType, _, _, _ = GetItemInfo(id)
        return itemType, itemSubType
end

function GetInventoryFreeSlots( bag )
        local freeCount = 0
        if GetBagName(bag) ~= nil then
                for j = 1, GetContainerNumSlots(bag) do
                        if GetInventoryItemLink(bag, j) == nil then freeCount = freeCount + 1 end
                end
        end
        return freeCount
end

function HasDebuff(texture, unit)
        unit = unit or "player"
        texture = string.lower(texture or "")
        local idx = 1
        if texture or texture ~= "" then
                while (UnitDebuff(unit, idx)) do
                        local textureDebuff, stacks = UnitDebuff(unit, idx)
                        if (string.find(string.lower(textureDebuff), texture)) then
                                return true, stacks
                        end
                        idx = idx + 1
                end
        end
        return false, 0
end

function GetDebuffCount(texture, unit)
        unit = unit or "player"
        local idx = 1
        local count = 0
        texture = string.lower(texture or "")
        if texture or texture ~= "" then
                while (UnitDebuff(unit, idx)) do
                        local textureDebuff, stacks = UnitDebuff(unit, idx)
                        if (string.find(tring.lower(textureBuff), texture)) then
                                count = count + 1
                        end
                        idx = idx + 1
                end
        end
        return count
end

function HasBuff(texture, unit)
        unit = unit or "player"
        texture = string.lower(texture or "")
        local idx = 1
        if texture or texture ~= "" then
                while (UnitBuff(unit, idx)) do
                        local textureBuff, stacks = UnitBuff(unit, idx)
                        if (string.find(string.lower(textureBuff), texture)) then
                                return true, stacks
                        end
                        idx = idx + 1
                end
        end
        return false, 0
end

function PlayerCancelBuffs( tbl )
        if not tbl then return false end
        
        local i = 0
        local canceled = 0
        while GetPlayerBuff(i) >= 0 do
                local buffIndex, untilCancelled = GetPlayerBuff(i)
                if buffIndex < 0 then
                        break
                else
                        for k,v in pairs(tbl) do
                                if string.find(GetPlayerBuffTexture(buffIndex), v) then
                                        CancelPlayerBuff(buffIndex)
                                        UIErrorsFrame:Clear()
                                        canceled = canceled + 1
                                end
                        end
                end
                i = i + 1
        end
        
        return canceled > 0
end

function PlayerCancelBuffNames( tbl )
        if not tbl then return false end
        
        ME_BuffTooltip:SetOwner(UIParent,"ANCHOR_NONE")
        
        local i = 0
        local canceled = 0
        while GetPlayerBuff(i) >= 0 do
                local buffIndex, untilCancelled = GetPlayerBuff(i)
                if buffIndex < 0 then
                        break
                else
                        ME_BuffTooltip:ClearLines()
                        ME_BuffTooltip:SetPlayerBuff(i)
                        if ME_BuffTooltipTextLeft1:IsShown() then
                                for k,v in pairs(tbl) do
                                        if string.find(ME_BuffTooltipTextLeft1:GetText(), v) then
                                                CancelPlayerBuff(buffIndex)
                                                UIErrorsFrame:Clear()
                                                canceled = canceled + 1
                                        end
                                end
                        end
                end
                i = i + 1
        end
        
        return canceled > 0
end

function PlayerBuffTimer(texture)
        local i = 0
        while GetPlayerBuff(i) >= 0 do
                local buffIndex,cancel = GetPlayerBuff(i,"HELPFUL|HARMFUL|PASSIVE")
                if buffIndex < 0 then
                        break
                else
                        if string.find(GetPlayerBuffTexture(buffIndex),texture) then
                                return GetPlayerBuffTimeLeft(buffIndex)
                        end
                end
                i = i + 1
        end
        return 0
end

function GetPlayerMountBuffInfo ()
        ME_BuffTooltip:SetOwner(UIParent,"ANCHOR_NONE")
        local text, buffIndex, untilCancelled, speed
        local i = 0
        while GetPlayerBuff(i) >= 0 do
                buffIndex, untilCancelled = GetPlayerBuff(i, "HELPFUL|PASSIVE")
                if buffIndex < 0 then
                        break
                elseif untilCancelled then
                        ME_BuffTooltip:ClearLines()
                        ME_BuffTooltip:SetPlayerBuff(buffIndex)
                        if (ME_BuffTooltipTextLeft2:IsShown()) then
                                text = ME_BuffTooltipTextLeft2:GetText()
                                if text then
                                        speed = Select(3,string.find(text, L["Increases speed by (%d+)%%."]))
                                        if speed then
                                                return tonumber(speed), buffIndex
                                        end
                                end
                        end
                end
                i = i + 1
        end
        return false
end

function IsUnitCaster( unit )
        local class = GetUnitClass(unit)
        if class and (class == "MAGE" or class == "PRIEST" or class == "WARLOCK" ) then
                return true
        end
        return false
end

function UnitHealthPct(unit)
        return (((UnitHealth(unit) / UnitHealthMax(unit)) * 100));
end

--Returns Mana Percent of Unit
function UnitManaPct(unit)
        return (((UnitMana(unit) / UnitManaMax(unit)) * 100));
end

function IsMounted()
        if GetPlayerMountBuffInfo() then
                return 1
        end
        return nil
end

function Dismount()
        local speed, id = GetPlayerMountBuffInfo()
        if speed then
                CancelPlayerBuff(id)
                return 1
        end
end

function IsIndoors( ... )
        -- body
end

function IsOutdoors( ... )
        -- body
end

function IsSwimming( ... )
        if ME_EventLog.Swimming then
                return 1
        end
        return 0
end

function CancelForm( ... )
        if not ME_CheckResultsFromTable(Select(2,UnitClass("player")),{"PRIEST","SHAMAN","DRUID"}) then
                return
        end
        
        if GetNumShapeshiftForms() > 0 and GetShapeshiftForm(true) > 0 then
                CastShapeshiftForm(GetShapeshiftForm(true))
        else
                local pcClass = Select(2,UnitClass("player"))
                if pcClass == "PRIEST" then
                        PlayerCancelBuffs({"Spell_Shadow_Shadowform"})
                elseif pcClass == "SHAMAN" then
                        PlayerCancelBuffs({"Spell_Nature_SpiritWolf"})
                end
        end
end

function IsShadowform( ... )
        if Select(2,UnitClass("player")) == "PRIEST" then
                if ME_GetTalentRankInfo("Shadowform") > 0 then
                        if HasBuff("Spell_Shadow_Shadowform") then
                                return 1
                        end
                end
        end
        return nil
end

function GetShapeshiftForm( ... )
        for i=1, GetNumShapeshiftForms() do
                if Select(3,GetShapeshiftFormInfo(i)) then
                        return i
                end
        end
        return 0
end

function IsModifierKeyDown( ... )
        return (IsShiftKeyDown() or IsControlKeyDown() or IsAltKeyDown())
end

function IsStealthed( ... )
        local pcClass = Select(2,UnitClass("player"))
        if pcClass == "ROGUE" or pcClass == "DRUID" then
                if pcClass == "ROGUE" then
                        if Select(3,GetShapeshiftFormInfo(1)) then
                                return 1
                        end
                else
                        if Select(3,GetShapeshiftFormInfo(3)) then
                                if HasBuff("Ability_Ambush") then
                                        return 1
                                end
                        end
                end
        end
        return nil
end

function ME_CheckResultsFromTable( res, tbl )
        for _,v in pairs(tbl) do
                if v == res then
                        return 1
                end
        end
        return nil
end

function ME_GenericFunction( macro, fn )
        if type(fn) ~= "function" then end
        if SecureCmdOptionParseConditions(macro) then
                fn()
        end
end

function ME_SortNumTable( Table, Desc )
        local temp = {}
        for key, _ in pairs(Table) do table.insert(temp, key) end
        if ( Desc ) then
                table.sort(temp, function(a, b) return a < b end)
        else
                table.sort(temp, function(a, b) return a > b end)
        end
        return temp
end