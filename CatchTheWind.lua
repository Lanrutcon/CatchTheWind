local Addon = CreateFrame("FRAME");

--Main UI Frame
local letterBox;
--Variable Quest Text Speed
local factorTextSpeed = 1;

--TODO
--CatchTheWind
--
-- Cinematic Quests AddOn
--x * GetTitleText + GetProgressText + GetObjectiveText + GetRewardText
-- * Set a close-plan to player when deciding "ACCEPT/DECLINE" and choosing rewards. (check for libCameras)
--x * Mouse-Click shows all the message (if it's still animating). Another click passes to the next line.
-- * SpaceBar shows all the message. This may bring problems because we have to enable keyboard.
--
-- * Start to think in moving GUI (frames and buttons) to a XML file
-- * It's about time to add documentation
--
-- QUEST PROGRESS > QUEST COMPLETE > QUEST FINISHED (it means you stop interacting with a NPC about a quest) > QUEST LOG UPDATED

-- BUGS:
-- * Some players have problems in "Accept/Decline" buttons, i.e. they can't click on them. (Guess: Addons are in-front -> set a higher frame level)
--x * WoD: When the NPC Questgiver only has 1 quest, it automatically goes to "QUEST_DETAIL"/"QUEST_PROGRESS". It doesn't pass through "GOSSIP" events.

--x = Done/Fixed

--------------------
--UTILS
--------------------


-------------------------------------
--
-- Prints the given string at yellow.
-- If it contains "CatchTheWind" then it colors it in a gray gradient.
-- Used in SlashCommands.
-- @param #string msg : the message that will be printed
--
-------------------------------------
local function printMessage(msg)
	if(string.find(msg, "CatchTheWind")) then
		local msg = string.sub(msg, string.find(msg, "CatchTheWind")+12, -1);
		print("|cff777777Ca|cffaaaaaatc|cffcccccchTh|cffccccccW|cffaaaaaain|cff777777d|cffffff66"..msg);
	else
		print("|cffffff66"..msg);
	end
end


--Timer Frame
local timer = CreateFrame("FRAME");
-------------------------------------
--
-- Creates a timer. After the specified time, it will execute the given function.
-- @param #number after : the message that will be printed
-- @param #function func : the message that will be printed
--
-------------------------------------
local function createTimer(after, func)
	local total = 0;
	timer:SetScript("OnUpdate", function(self, elapsed)
		total = total + elapsed;
		if(total > after) then
			self:SetScript("OnUpdate", nil);
			func();
		end
	end);
end


-------------------------------------
--
-- Cancels the timer.
--
-------------------------------------
local function cancelTimer()
	timer:SetScript("OnUpdate", nil);
end


-------------------------------------
--
-- Splits the given text (string with \n (aka "Enter")).
-- It returns a table, in each entry is paragraph from the text.
-- @param #string text : the string that will be splitted
-- @return #table tableLines: the table with the lines from the text
--
-------------------------------------
local function splitText(text)
	local tableLines, nextLine = {};
	while string.find(text,"\n") do
		nextLine = string.sub(text,0, string.find(text, "\n"));
		if not (strtrim(nextLine) == "") then
			table.insert(tableLines, nextLine);
		end
		text = string.sub(text, string.find(text, "\n")+1, -1);	
	end
	if not (strtrim(text) == "") then
		table.insert(tableLines, string.sub(text, 0, string.find(text, "\n")));
	end
	return tableLines;
end


-------------------------------------
--
-- Creates a button with the given values.
-- This button is a "FRAME" with a "FontString".
-- Used to create the "Accept"/"Decline" buttons.
-- @param #string name : the button's name
-- @param #frame parent : the frame that will be attached
-- @param #string point : the anchor's point
-- @param #number xOfs : the variation in the X axis from the anchor
-- @param #number yOfs : the variation in the Y axis from the anchor
-- @param #function onClickFunc : the function that will be executed whenever this button is pressed
-- @return #frame buttonFrame: the button itself
--
-------------------------------------
local function createButton(name, parent, text, point, xOfs, yOfs, onClickFunc)
	local buttonFrame = CreateFrame("FRAME", name, parent);
	buttonFrame:SetSize(200,50);
	buttonFrame:SetPoint(point, xOfs, yOfs);
	
	buttonFrame.fontString = buttonFrame:CreateFontString();
	buttonFrame.fontString:SetFont("Fonts\\FRIZQT__.TTF", 18, "OUTLINE");
	buttonFrame.fontString:SetText(text);
	buttonFrame.fontString:SetTextColor(0.3, 0.3, 0.3, 1);
	buttonFrame.fontString:SetPoint("CENTER");
	
	buttonFrame:EnableMouse(true);
	buttonFrame:SetScript("OnMouseUp", onClickFunc);
	buttonFrame:SetScript("OnEnter", function(self)
		self.fontString:SetTextColor(1, 1, 1, 1);
	end);
	buttonFrame:SetScript("OnLeave", function(self)
		self.fontString:SetTextColor(0.45, 0.45, 0.45, 1);
	end);
	
	buttonFrame:SetScript("OnShow", function(self)
		UIFrameFadeIn(self, 0.5, 0, 1);
	end);
	
	buttonFrame:Hide();
	
	return buttonFrame;
end


--Frame, Boolean
local animationFrame, isAnimating = CreateFrame("FRAME");
-------------------------------------
--
-- Animates the given fontString.
-- Uses "SetAlphaGradient" in order to fade in the text.
-- @param #fontString fontString : the fontString that will be animated
--
-------------------------------------
local function animateText(fontString)
	local total, numChars = 0, 0;
	fontString:SetAlphaGradient(0,20);
	isAnimating = true;
	animationFrame:SetScript("OnUpdate", function(self, elapsed)
		numChars = numChars + 0.25*factorTextSpeed;
		fontString:SetAlphaGradient(numChars,20);
		if(numChars >= string.len(fontString:GetText() or "")) then
			isAnimating = false;
			self:SetScript("OnUpdate", nil);
		end
	end);
end


-------------------------------------
--
-- Checks if the text is being animated.
-- If the text is "full-shown" then it will return false.
-- @return #boolean isAnimating : true, if the animation is ON
--
-------------------------------------
local function isTextAnimating()
	return isAnimating;
end


--Storing SetView function (Blizzard's function)
local blizz_SetView = SetView;
--Current view
local currentView = -1;
-------------------------------------
--
-- Sets a view.
-- It checks first, if the view that will be set is the current one.
-- This prevents instant changes (i.e. no smooth movement).
-- @param #number view: the desired view [1-5]
--
-------------------------------------
local function SetView(view)
	if not (view == currentView) then
		currentView = view;
		blizz_SetView(view);
	end
end


-------------------------------
--/UTILS
-------------------------------



--Frame Fader
local frameFader = CreateFrame("FRAME");

-------------------------------------
--
-- Hides the letterbox and its containers.
-- It fades out the frame and its containers.
-- Also, it fades in the UIParent.
--
-------------------------------------
local function hideLetterBox()
	--UIFrameFadeIn(UIParent, 0.25, 0, 1);	It's not advised to use UIFrameFade on "UIParent" because it taints the code
	local alpha = UIParent:GetAlpha();
	MinimapCluster:Show();
	frameFader:SetScript("OnUpdate", function(self, elapsed)
		if(alpha < 1) then
			alpha = alpha + 0.05;
			UIParent:SetAlpha(alpha);
		else
			frameFader:SetScript("OnUpdate", nil);
		end
	
	end);
	
	UIFrameFadeOut(letterBox, 0.25, 1, 0);
	local total = 0;
	letterBox:SetScript("OnUpdate", function(self, elapsed)
		total = total + elapsed;
		if(total > 0.25) then
			letterBox:SetScript("OnUpdate", nil);
			letterBox:Hide();
		end
	end);
end


-------------------------------------
--
-- Shows the letterbox and its containers.
-- It also sets the UIParent's alpha to 0.
--
-------------------------------------
local function showLetterBox()
	UIParent:SetAlpha(0);
	MinimapCluster:Hide(); --Minimap icons aren't affected with "SetAlpha"
	UIFrameFadeIn(letterBox, 0.25, 0, 1);
end


-------------------------------------
--
-- Inits the interaction with the NPC after choosing a quest.
-- Used when QuestEvents triggers.
--
-------------------------------------
local function startInteraction()
	letterBox.acceptButton:Hide();
	letterBox.declineButton:Hide();
	
	letterBox.rewardPanel:Hide();
	
	letterBox.text = splitText(letterBox.text);
	letterBox.textIndex = 1;
	letterBox.questText:SetText(letterBox.text[letterBox.textIndex]);
	animateText(letterBox.questText);
end


--In the next update, this will be moved to XML
-------------------------------------
--
-- Creates Quest Reward Panel and all its containers.
-- Used in "setUpLetterBox" function.
--
-------------------------------------
local function createQuestRewardPanel()

	--quest reward panel
	letterBox.rewardPanel = CreateFrame("FRAME", "CTWrewardPanel", letterBox);
	local rewardPanel = letterBox.rewardPanel;	--referencing to smaller name
	rewardPanel:SetSize(600,100);
	rewardPanel:SetPoint("TOP", letterBox.bottomPanel, 0, 100);
	
	--creating background textures (some a gradient that fades in and out)
	rewardPanel.textureCenter = rewardPanel:CreateTexture(nil, "BACKGROUND");
	rewardPanel.textureCenter:SetSize(200,100);
	rewardPanel.textureCenter:SetColorTexture(0,0,0);
	rewardPanel.textureCenter:SetAlpha(0.9);
	rewardPanel.textureCenter:SetPoint("CENTER");
	
	rewardPanel.textureLeft = rewardPanel:CreateTexture(nil, "BACKGROUND");
	rewardPanel.textureLeft:SetSize(200,100);
	rewardPanel.textureLeft:SetColorTexture(0,0,0);
	rewardPanel.textureLeft:SetGradientAlpha("HORIZONTAL", 0, 0, 0, 0, 0, 0, 0, 0.9);
	rewardPanel.textureLeft:SetPoint("LEFT");
	
	rewardPanel.textureRight = rewardPanel:CreateTexture(nil, "BACKGROUND");
	rewardPanel.textureRight:SetSize(200,100);
	rewardPanel.textureRight:SetColorTexture(0,0,0);
	rewardPanel.textureRight:SetGradientAlpha("HORIZONTAL", 0, 0, 0, 0.9, 0, 0, 0, 0);
	rewardPanel.textureRight:SetPoint("RIGHT");
	
	
	--quest reward panel title
	letterBox.rewardPanel.title = letterBox.rewardPanel:CreateFontString();
	letterBox.rewardPanel.title:SetFont("Fonts\\FRIZQT__.TTF", 18, "OUTLINE");
	letterBox.rewardPanel.title:SetTextColor(1, 1, 1, 1);
	letterBox.rewardPanel.title:SetText("Choose your reward");
	letterBox.rewardPanel.title:SetPoint("TOP", 0, -12);
	
	--quest reward items buttons(blizz has 10 buttons)
	--refactor > extract code
	
	for i=1, 10 do
		local btn = CreateFrame("BUTTON", "CTWrewardPanelItem"..i, letterBox.rewardPanel, "LargeItemButtonTemplate, QuestInfoRewardItemCodeTemplate");
		btn:SetSize(48,48);
		
		btn.type = "choice";
		btn.objectType = "item";
		
		_G[btn:GetName().."NameFrame"]:Hide();
		_G[btn:GetName().."Name"]:Hide();
		
		_G[btn:GetName().."IconTexture"]:SetTexCoord(0.075,0.925,0.075,0.925);
		_G[btn:GetName().."IconTexture"]:SetSize(38,38)
		_G[btn:GetName().."IconTexture"]:ClearAllPoints();
		_G[btn:GetName().."IconTexture"]:SetPoint("CENTER", btn, 0, 0);
		
		btn:SetBackdrop(
			{--bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
			edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
			tile = true, tileSize = 22, edgeSize = 22,
			insets = { left = 6, right = 6, top = 6, bottom = 6 }}
		);
		
		btn:SetPoint("CENTER", (-i)*56, -12);
		
		btn:SetScript("OnEnter", function(self)
			GameTooltip:SetParent(WorldFrame);
			GameTooltip:SetFrameStrata("TOOLTIP");
			for i=1,3 do
				_G["ShoppingTooltip"..i]:SetParent(WorldFrame);
				_G["ShoppingTooltip"..i]:SetFrameStrata("TOOLTIP");
			end
			
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
			GameTooltip:SetQuestItem(self.type, self:GetID());
			GameTooltip_ShowCompareItem(GameTooltip);
		end);
		
		btn:SetScript("OnLeave", function()
			GameTooltip:SetParent(UIParent);
			GameTooltip:Hide();
			ShoppingTooltip1:SetParent(UIParent);
			ShoppingTooltip2:SetParent(UIParent);
			ShoppingTooltip3:SetParent(UIParent);
			ResetCursor();
		end);
		
		btn:SetScript("OnClick", function(self, button)
			for i=1, GetNumQuestChoices() do
				_G["CTWrewardPanelItem"..i.."IconTexture"]:SetVertexColor(0.5,0.5,0.5,1);
			end
			_G[self:GetName().."IconTexture"]:SetVertexColor(1,1,1,1);
			QuestInfoItem_OnClick(self);
		end);
		
		btn:Hide();
	end
	
	letterBox.rewardPanel:Hide();
end


-------------------------------------
--
-- Sets up all the frames for letterbox.
--
-------------------------------------
local function setUpLetterBox()
	local screenWidth = GetScreenWidth()*UIParent:GetEffectiveScale();
	local screenHeight = GetScreenHeight()*UIParent:GetEffectiveScale();
	
	letterBox = CreateFrame("FRAME", "CatchTheWind", WorldFrame);
	letterBox:SetAllPoints();
	
	letterBox:SetFrameStrata("HIGH");
	letterBox:SetFrameLevel(10);
	
	letterBox.bottomPanel = letterBox:CreateTexture();
	letterBox.bottomPanel:SetColorTexture(0,0,0);
	letterBox.bottomPanel:SetSize(screenWidth, screenHeight/7);
	letterBox.bottomPanel:SetPoint("BOTTOM");
	
	letterBox.topPanel = letterBox:CreateTexture();
	letterBox.topPanel:SetColorTexture(0,0,0);
	letterBox.topPanel:SetSize(screenWidth, screenHeight/7);
	letterBox.topPanel:SetPoint("TOP");
	
	
	letterBox.questText = letterBox:CreateFontString(nil, "OVERLAY");
	letterBox.questText:SetSize(screenWidth*0.75, screenHeight/7)
	letterBox.questText:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE"); --WoW Font
	letterBox.questText:SetTextColor(0.9, 0.9, 0.9, 1);
	letterBox.questText:SetPoint("BOTTOM", 0, 0);
	
	
	createQuestRewardPanel();
	
	
	letterBox.acceptButton = createButton("CTWacceptButton", letterBox, "Accept", "BOTTOMRIGHT", 0, screenHeight/28, function(self, button)
		QuestDetailAcceptButton_OnClick();
		hideLetterBox();
	end);

	letterBox.declineButton = createButton("CTWdeclineButton", letterBox, "Decline", "BOTTOMLEFT", 0, screenHeight/28, function(self, button)
		QuestDetailDeclineButton_OnClick();
		hideLetterBox();
	end);
	
	
	letterBox:Hide();
	
	letterBox:SetScript("OnMouseUp", function(self, button)
		if(not isTextAnimating() and self.textIndex == #self.text) then
			if(self.acceptButton.fontString:GetText() == "Continue") then
				if(IsQuestCompletable()) then
					self.acceptButton:Show();
				else
					self.acceptButton:Hide();
				end
			else
				self.acceptButton:Show();
			end
			if(self.acceptButton.fontString:GetText() == "Thank you" and 
			self.textIndex == #self.text and GetNumQuestChoices() > 0 and
			not self.rewardPanel:IsShown()) then
				UIFrameFadeIn(self.rewardPanel, 0.5, 0, 1);
			end
			
			self.declineButton:Show();
			return;
		end
		--checks if the text is fading in, if yes, shows the rest.
		if(isTextAnimating()) then
			self.questText:SetAlphaGradient(string.len(self.questText:GetText()),1);
			isAnimating = false;
			animationFrame:SetScript("OnUpdate", nil);
		else
			self.textIndex = self.textIndex + 1;
			self.questText:SetText(self.text[self.textIndex]);
			animateText(self.questText);
		end
		
	end);
	
	
	QuestFrame:HookScript("OnHide", function()
		hideLetterBox();
	end);
	
end


-------------------------------------
--
-- Load SavedVariables.
-- If there is no SVs, then it creates them.
--
-------------------------------------
local function loadSavedVariables()
	if(not CatchTheWindSV) then
		CatchTheWindSV = {};
		CatchTheWindSV[UnitName("player")] = {};
		CatchTheWindSV[UnitName("player")]["FactorTextSpeed"] = 1;
	elseif(CatchTheWindSV[UnitName("player")]) then
		factorTextSpeed = CatchTheWindSV[UnitName("player")]["FactorTextSpeed"];
	else
		CatchTheWindSV[UnitName("player")] = {};
		CatchTheWindSV[UnitName("player")]["FactorTextSpeed"] = 1;
	end
end



------------
--ADDON SCRIPTS
--
--Some funcitons that will be used later for events.

local function onPlayerLogin()
	SaveView(5);
	setUpLetterBox();
	loadSavedVariables();
end

local function onGossipShow()
	cancelTimer();
	SetView(2);
end


local function onQuestDetail()
	cancelTimer();
	SetView(2);
	letterBox.text = GetQuestText();
	
	letterBox.acceptButton.fontString:SetText("Accept");
	letterBox.acceptButton:SetScript("OnMouseUp", function(self, button)
		QuestDetailAcceptButton_OnClick();
		hideLetterBox();
	end);
	letterBox.declineButton.fontString:SetText("Decline");
	
	showLetterBox();
	
	startInteraction();
end


local function onQuestProgress()
	cancelTimer();
	SetView(2);
	letterBox.text = GetProgressText();
	
	letterBox.acceptButton.fontString:SetText("Continue");
	letterBox.acceptButton:SetScript("OnMouseUp", QuestProgressCompleteButton_OnClick);
	
	letterBox.declineButton.fontString:SetText("Goodbye");
	
	showLetterBox();
	
	startInteraction();
end


local function onQuestComplete()
	cancelTimer();
	if(not letterBox:IsShown()) then
		showLetterBox();
	end
	
	letterBox.text = GetRewardText();
	
	startInteraction();
	
	letterBox.acceptButton.fontString:SetText("Thank you");
	letterBox.acceptButton:SetScript("OnMouseUp", function(self, button)
		if(QuestInfoFrame.itemChoice == 0 and GetNumQuestChoices() > 0 ) then
			UIFrameFlash(letterBox.rewardPanel, 0.5, 0.5, 1.5, true, 0, 0);
		else
			QuestRewardCompleteButton_OnClick();
			hideLetterBox();
		end
	end);
	
	letterBox.declineButton:Hide();
	
	--if there is quest rewards to choose > show quest rewards
	if(GetNumQuestChoices() > 0) then
		local btn;
		
		--show icons of quests rewards
		for i=1, GetNumQuestChoices() do
			btn = _G["CTWrewardPanelItem"..i];
			
			local name, texture, numItems, quality, isUsable = GetQuestItemInfo(btn.type, i);
			SetItemButtonTexture(btn, texture);
			_G[btn:GetName().."IconTexture"]:SetVertexColor(0.5,0.5,0.5,1);

			btn:SetPoint("CENTER", (i-1)*64-(GetNumQuestChoices()/2*64)+32, -12)
			btn:SetID(i);
			btn:Show();
		end
		
		--hide remain unused frames
		for i=GetNumQuestChoices()+1, 10 do
			_G["CTWrewardPanelItem"..i]:Hide();
		end
		
		--letterBox.rewardPanel:Show();
	else
		letterBox.rewardPanel:Hide();
	end
end


--Table with the scripts
Addon.scripts = {
	["PLAYER_LOGIN"] = onPlayerLogin,
	["GOSSIP_SHOW"] = onGossipShow,
	["QUEST_DETAIL"] = onQuestDetail,
	["QUEST_PROGRESS"] = onQuestProgress,
	["QUEST_COMPLETE"] = onQuestComplete,
};


--/ADDON SCRIPTS
------------


--Slash Commands available to players
SLASH_CatchTheWind1, SLASH_CatchTheWind2 = "/catchthewind", "/ctw";

-------------------------------------
--
-- SlashCommand function.
-- Commands implemented:
-- 						- textSpeed
-- @param #string cmd : the command that the player inputs
--
-------------------------------------
local function SlashCmd(cmd)
    if (cmd:match"textSpeed") then
        local factor = tonumber(strtrim(cmd:sub(cmd:find("textSpeed")+9, -1)));
		factorTextSpeed = factor;
		CatchTheWindSV[UnitName("player")]["FactorTextSpeed"] = factor;
		printMessage("CatchTheWind: The text speed is now "..factor.."x faster than the default speed.");
    else
    	printMessage("CatchTheWind Commands:");
    	printMessage("      /ctw textSpeed x -> where x is the factor.");
    end
end

SlashCmdList["CatchTheWind"] = SlashCmd;


--Boolean (checks if the camera is moving)
local moving = false;
-------------------------------------
--
-- Addon SetScript OnEvent
-- Starts up the addOn.
-- Handled events can be checked right after this function.
--
-------------------------------------
Addon:SetScript("OnEvent", function(self, event)
	if(Addon.scripts[event]) then
		Addon.scripts[event]();
	elseif((event == "GOSSIP_CLOSED" or event == "MERCHANT_CLOSED" or event == "TRAINER_CLOSED" or event == "QUEST_FINISHED" or event == "TAXIMAP_CLOSED") and not moving) then
		--a timer is needed because when interacting with merchants/trainers or choosing quests, "GOSSIP_CLOSED" will be
		--triggered and right after a "MERCHANT_SHOW" will pop up and cancel this timer.
		letterBox.rewardPanel:Hide();
		createTimer(0.05, function()
			SetView(5);
			moving = true;
			createTimer(0.5, function() moving = false end);
		end);
	elseif(event == "MERCHANT_SHOW" or event == "TRAINER_SHOW" or event == "TAXIMAP_OPENED") then
		SetView(2);
		cancelTimer();
	end
end);


Addon:RegisterEvent("GOSSIP_SHOW");
Addon:RegisterEvent("MERCHANT_SHOW");
Addon:RegisterEvent("TRAINER_SHOW");
Addon:RegisterEvent("TAXIMAP_OPENED");

Addon:RegisterEvent("GOSSIP_CLOSED");
Addon:RegisterEvent("MERCHANT_CLOSED");
Addon:RegisterEvent("TRAINER_CLOSED");
Addon:RegisterEvent("TAXIMAP_CLOSED");

Addon:RegisterEvent("QUEST_DETAIL");
Addon:RegisterEvent("QUEST_PROGRESS");
Addon:RegisterEvent("QUEST_COMPLETE");
Addon:RegisterEvent("QUEST_FINISHED");

Addon:RegisterEvent("PLAYER_LOGIN");