local initialized = false;
local MINIMAP_ICON = "Interface\\Icons\\ability_warrior_charge"
local dbDefaults = {
    profile = {
        profileversion = 3,
        minimap = {
            hide = false,
            minimapPos = 180,
        }
    }
}
-- /dump C_ChallengeMode.GetMapTable()
local dungeons = {
	-- SL
	[375] = "Necrotic Wake",
	[376] = "Plaguefall",
	[377] = "Mists of Tirna Scithe",
	[378] = "Halls of Atonement",
	[379] = "Spires of Ascension",
	[380] = "Theater of Pain",
	[381] = "De Other Side",
	[382] = "Sanguine Depths"
 };
local LibQTip = LibStub('LibQTip-1.0');
local addon = LibStub("AceAddon-3.0"):NewAddon("MyMythics", "AceConsole-3.0");
local icon = LibStub("LibDBIcon-1.0");

-- Setup the Title Font. 14
local ssTitleFont = CreateFont("ssTitleFont")
ssTitleFont:SetTextColor(1,0.823529,0)

-- Setup the Header Font. 12
local ssHeaderFont = CreateFont("ssHeaderFont")
ssHeaderFont:SetTextColor(1,0.823529,0)

-- Setup the Regular Font. 12
local ssRegFont = CreateFont("ssRegFont")
ssRegFont:SetTextColor(1,0.823529,0)

local tooltip;
local LDB_ANCHOR;
local MyDO = LibStub("LibDataBroker-1.1"):NewDataObject("MyMythics", {
	type = "data source", 
	text = "Nothing to track!", 
	icon = MINIMAP_ICON,
}); --added ;

function addon:SlashHandler(msg)
	if msg == "help" then
		print("|cffe5cc80MyMythics Help Menu|n|rUse |cff00ff00/pf|r or |cff00ff00/MyMythics|r followed by a command, for example|n|cff00ff00toggle|r - toggles the minimap icon on and off");
	elseif msg == "toggle" or msg == "Toggle" then
			
		MyMythics.Update();	
				
	elseif msg == "minimap"  or msg == "Minimap" then
		self.db.profile.minimap.hide = not self.db.profile.minimap.hide
		if self.db.profile.minimap.hide then
			print("|cffe5cc80MyMythics minimap icon is now disabled|r");
			icon:Hide("MyMythics")
		else						
			print("|cffe5cc80MyMythics minimap icon is now enabled|r");
			icon:Show("MyMythics")
		end
	else
		print("|n");
		print("|T" .. MyDO.icon .. ":0|t |cffe5cc80MyMythics - Mythics Progression Tracker|n|rUse |cff00ff00/pf help|r to view all available options");
		if MyMythics.Status and initialized then
			MyMythics.ProcessPrint(MyMythics.Status);
			print("|n" .. RED_FONT_COLOR_CODE .. "Achievements once completed on any character count for account wide progress. Blizzards earned by is not always accurate!");
		else 
			print("Error - Nothing to Output?");
		end
		print("|n");
	end
end

function addon:OnInitialize()
	
	self.db = LibStub("AceDB-3.0"):New("MyMythics", dbDefaults, true)

	icon:Register("MyMythics", MyDO, self.db.profile.minimap)
	ShowAccountAchievements(1)
	MyMythics.Update = function()					
		local output = "";		
		MyDO.text = output;
	end		
	initialized = true;
	return true;
	
end

function MyDO:Hide()
      if tooltip then
	tooltip:Clear();
        tooltip:Release()
        tooltip = nil
      end
end

function GameTooltip_SetBackdropStyle(self, style)
	self:SetBackdrop(style);
end

function MyDO:OnEnter()		
	MyDO:BuildToolTip(self);		
end

TOOLTIP_STYLE_TRANS = {
	bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
	edgeFile = "Interface/Tooltips/UI-Tooltip-Border-Azerite",
	tile = false,
	tileEdge = false,
	tileSize = 16,
	edgeSize = 19,
	insets = { left = 4, right = 4, top = 4, bottom = 4 },
	backdropBorderColor = TOOLTIP_DEFAULT_COLOR,
	backdropColor = TOOLTIP_AZERITE_BACKGROUND_COLOR,
	overlayAtlasTop = "AzeriteTooltip-Topper";
	overlayAtlasTopScale = .75,
	overlayAtlasBottom = "AzeriteTooltip-Bottom";
};

TOOLTIP_STYLE_SOLID = {
	bgFile = "Interface\\Collections\\CollectionsBackgroundTile",
	edgeFile = "Interface/Tooltips/UI-Tooltip-Border-Azerite",
	tile = false,
	tileEdge = false,
	tileSize = 16,
	edgeSize = 19,
	insets = { left = 4, right = 4, top = 4, bottom = 4 },
	backdropBorderColor = TOOLTIP_DEFAULT_COLOR,
	backdropColor = TOOLTIP_AZERITE_BACKGROUND_COLOR,
	overlayAtlasTop = "AzeriteTooltip-Topper";
	overlayAtlasTopScale = .75,
	overlayAtlasBottom = "AzeriteTooltip-Bottom";
};

local function GetRunQualityBasedOnLevel(level)
	if (level >= 20) then
		return "ffe6cc80"; 
	elseif (level >= 15) then
		return "ffff8000";
	elseif (level < 15 and level >= 10) then
		return "ffa335ee";
	elseif (level < 10 and level >= 7) then
		return "ff0070dd";
	elseif (level < 7 and level >= 4) then
		return "ff1eff00";
	elseif (level < 4 and level >= 2) then
		return "ffffffff";
	else
		return "ff9d9d9d";
	end
end 
local function Getcompletstatuscolour(c)
	if (c) then
		return "FF00FF00";
	else
		return "FFFF0000";
	end
end

local function Getcompletstatusname(c)
	if (c) then
		return "True";
	else
		return "False";
	end
end

function MyDO:BuildToolTip(self)
	MyMythics.Update(); --Update data for tooltip		
	tooltip = LibQTip:Acquire("MyMythics", 2, "LEFT", "RIGHT");
	tooltip:Clear();	
				
	GameTooltip_SetBackdropStyle(tooltip, TOOLTIP_STYLE_TRANS);
	-- /run local description, _,_,_,_,_,_,_,_,id = GetAchievementCriteriaInfo(14532, 1) print(description..":", id)			
	ssHeaderFont:SetFont(GameTooltipHeaderText:GetFont());
	ssRegFont:SetFont(GameTooltipText:GetFont());
	ssTitleFont:SetFont(GameTooltipText:GetFont());		
	tooltip:SetHeaderFont(ssHeaderFont);
	tooltip:SetFont(ssRegFont);		
	tooltip:SmartAnchorTo(self);
	tooltip:SetAutoHideDelay(0.25, self)										
	tooltip:AddHeader("|cffe5cc80MyMythics - Mythics Progression Tracker|r|n");	
	tooltip:AddLine("");	
	tooltip:AddLine("|cff00ccffAchievment Status|r|n");
	local _,a,_,c = GetAchievementInfo(14532); 
	colour = Getcompletstatuscolour(c);
	status = Getcompletstatusname(c);
	tooltip:AddLine(a, "\124c" ..colour .."" ..status .."\124r");
	tooltip:AddLine("");
	local _,a,_,c = GetAchievementInfo(14531); 
	colour = Getcompletstatuscolour(c);
	status = Getcompletstatusname(c);
	tooltip:AddLine(a, "\124c" ..colour .."" ..status .."\124r");
	tooltip:AddLine("");
	tooltip:AddLine("");
	tooltip:AddLine("|cff00ccffSeason Best Results|r|n");
	self.maps = C_ChallengeMode.GetMapTable();

    for i = 1, #self.maps do
		local inTimeInfo, overtimeInfo = C_MythicPlus.GetSeasonBestForMap(self.maps[i]);
		local level, quality; 
        if (not inTimeInfo) then
			if(overtimeInfo) then 
				level = overtimeInfo.level; 
			else
				level = 0; 
			end
			tooltip:AddLine(dungeons[self.maps[i]], "\124cff4a4a4a" ..level .."\124r");
        else
			level = inTimeInfo.level; 
			quality = GetRunQualityBasedOnLevel(level);
			tooltip:AddLine(dungeons[self.maps[i]], "\124c" ..quality .."" ..level .."\124r");
		end

    end
	
	local a1,_,_,_,_,c1 = GetAchievementCriteriaInfo(14532, 1);
	tooltip:AddLine(c1);
	tooltip:UpdateScrolling();
	tooltip:Show();			
end

local function EventHandler(self, event, ...)	
	if ( event == "VARIABLES_LOADED" and initialized == true ) then
		print("|cffe5cc80MyMythics v" .. GetAddOnMetadata("MyMythics", "Version") .. " Loaded!|r");	
	elseif ( event == "PLAYER_ENTERING_WORLD" and initialized == true ) then		
		MyMythics.Update();
	elseif (event == "UPDATE_FACTION" and initialized == true) then
		--print("UPDATE_FACTION");
		MyMythics.Update();
	elseif (event == "ACHIEVEMENT_EARNED" and initialized == true) then
		--print("ACHIEVEMENT_EARNED");
		MyMythics.Update();
	elseif (event == "CRITERIA_EARNED" and initialized == true) then
		--print("CRITERIA_EARNED");
		MyMythics.Update();
	end
end

local EventListener = CreateFrame("frame", "MyMythics");
EventListener:RegisterEvent("VARIABLES_LOADED");
EventListener:RegisterEvent("CRITERIA_EARNED");
EventListener:RegisterEvent("ACHIEVEMENT_EARNED");
EventListener:RegisterEvent("PLAYER_ENTERING_WORLD");
EventListener:RegisterEvent("UPDATE_FACTION");
EventListener:SetScript("OnEvent", EventHandler);
