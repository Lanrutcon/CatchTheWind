local Addon = CreateFrame("FRAME");

local addonName, addonTable = ...;
local L = addonTable["Locale"];

--Main UI Frame
local letterBox;

--Most Used SavedVariables
--Quest Text Speed
local factorTextSpeed = 1;
--Quest Sound
local questSoundEnabled = false;
--Font to be used in QuestText
local blizzardFont;

--TODO
--CatchTheWind
--
-- Cinematic Quests AddOn
--x * GetTitleText + GetProgressText + GetObjectiveText + GetRewardText
-- * Set a close-plan to player when deciding "ACCEPT/DECLINE" and choosing rewards. (check for libCameras)
-- * Try display all the rewards even if there isn't any to choose from (i.e. when there is only 1 reward) - Checkout QuestInfo.lua
--
-- * Start to think in moving GUI (frames and buttons) to a XML file
--
--
-- Legion: QUEST PROGRESS > QUEST COMPLETE > QUEST TURNED IN

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
-- @param #function onClickFunc : the function that will be executed whenever this button is pressed
-- @return #frame buttonFrame: the button itself
--
-------------------------------------
local function createButton(name, parent, text, onClickFunc)
	local buttonFrame = CreateFrame("FRAME", name, parent);
	buttonFrame:SetSize(200,50);
	
	buttonFrame.fontString = buttonFrame:CreateFontString();
	buttonFrame.fontString:SetFont(blizzardFont, 18, "OUTLINE");
	buttonFrame.fontString:SetText(text);
	buttonFrame.fontString:SetTextColor(0.45, 0.45, 0.45, 1);
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
	local total, numChars, totalSfx = 0, 0, 0;
	fontString:SetAlphaGradient(0,20);
	isAnimating = true;
	if(questSoundEnabled) then
		PlaySoundKitID(3093);
	end
	animationFrame:SetScript("OnUpdate", function(self, elapsed)
		total = total + elapsed;
		totalSfx = totalSfx + elapsed;
		--setting alphaGradient here because when changing Parent's alpha, it also disables alphaGradient effect.
		fontString:SetAlphaGradient(numChars,20);
		if(total > 0.02) then
			total = 0;
			numChars = numChars + factorTextSpeed;
			--fontString:SetAlphaGradient(numChars,20);
			if(numChars >= string.len(fontString:GetText() or "")) then
				isAnimating = false;
				self:SetScript("OnUpdate", nil);
			end
		end
		if(questSoundEnabled and totalSfx > 1.4) then
			totalSfx = 0;
			PlaySoundKitID(3093);
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
	if (not CatchTheWindSV[UnitName("player")]["CameraEnabled"]) then
		return;
	end
	if not (view == currentView) then
		currentView = view;
		blizz_SetView(view);
		if(CatchTheWindSV[UnitName("player")]["ActionCamEnabled"]) then
			if(view == 5) then
				ConsoleExec("ActionCam off");
			else
				ConsoleExec("ActionCam full");
			end
		end
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
	if(not letterBox:IsShown()) then
		return;
	end
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
	
	--hides dressModel
	CTWDressUpModel:Hide();
	CTWHelpFrame:Hide();
	local alpha = letterBox:GetAlpha();
	letterBox:SetScript("OnUpdate", function(self, elapsed)
		letterBox:SetAlpha(alpha);
		alpha = alpha - 0.05;
		if(alpha < 0) then
			letterBox:SetScript("OnUpdate", nil);
			letterBox:Hide();
		end
	end);

	letterBox:EnableKeyboard(false);
end


-------------------------------------
--
-- Shows the letterbox and its containers.
-- It also sets the UIParent's alpha to 0.
--
-------------------------------------
local function showLetterBox()
	if(IsModifierKeyDown() or not QuestFrame:IsShown()) then
		return;
	end
	
	--clearing frameFader
	frameFader:SetScript("OnUpdate", nil);
	
	UIParent:SetAlpha(0);
	MinimapCluster:Hide(); --Minimap icons aren't affected by "SetAlpha"
	--UIFrameFadeIn(letterBox, 0.25, 0, 1);
	--I can't use UIFrameFadeIn because it uses "Frame:SetAlpha()" which makes all childs to be shown - Problems: QuestText is displayed instantly for a second.
	--frameFade(letterBox, 0.25, 0, 1);
	--TODO: Weird stuff is happening here. UIFrameFadeIn and frameFade (from Utils.lua) are not doing the job. QuestText is being showed fully because of SetAlpha() from its parent. It's removing SetAlphaGradient from FontString...
	local alpha = letterBox:GetAlpha();
	letterBox:Show();
	letterBox:SetScript("OnUpdate", function(self, elapsed)
		letterBox:SetAlpha(alpha);
		alpha = alpha + 0.05;
		if(alpha > 1) then
			self:SetScript("OnUpdate", nil);
		end
	end);
	letterBox.selectedButton = nil;
	letterBox:EnableKeyboard(true);
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
	
	letterBox.choicePanel:Hide();
	letterBox.rewardPanel:Hide();
	
	letterBox.text = splitText(letterBox.text);
	letterBox.textIndex = 1;
	
	letterBox.prevQuestText:SetText("");
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
local function setUpQuestChoicePanel()
	CTWChoicePanel.textureLeft:SetGradientAlpha("HORIZONTAL", 0, 0, 0, 0, 0, 0, 0, 0.9);
	CTWChoicePanel.textureRight:SetGradientAlpha("HORIZONTAL", 0, 0, 0, 0.9, 0, 0, 0, 0);
	CTWChoicePanel.title:SetFont(blizzardFont, 18, "OUTLINE");
	CTWChoicePanel.title:SetText(L.CHOOSE_YOUR_REWARD);
	
	for i=1, 10 do
		CreateFrame("BUTTON", "CTWChoicePanelItem"..i, CTWChoicePanel, "CTWItemButtonTemplate");
	end
	
end


local function setUpQuestRewardPanel()
	--creating 5 buttons for rewards (Blizzard uses 10 for choices+rewards) - already made 10 in QuestChoicePanel
	CTWRewardPanel.title:SetFont(blizzardFont, 18, "OUTLINE");
	CTWRewardPanel.title:SetText(REWARD_ITEMS_ONLY);

	for i=1, 5 do
		local btn = CreateFrame("BUTTON", "CTWRewardPanelItem"..i, CTWRewardPanel, "CTWItemButtonTemplate");
		btn.type = "reward";
	end
end

-------------------------------------
--
-- Script function that will be used when the player clicks or presses SPACE when CTW is visible.
-- @param #frame self : the frame that will be using this script
--
-------------------------------------
local function onClickKey(self)

	--checks if it's the first paragraph, if yes, fades questTitle.
	if(not isTextAnimating() and CTWQuestTitleFrame:IsShown() and not CTWQuestTitleFrame.hideAnim:IsPlaying()) then
		CTWQuestTitleFrame.hideAnim:Play();
	end
	
	if(not isTextAnimating() and (self.textIndex == #self.text or #self.text == 0)) then
	
		if(self.acceptButton.fontString:GetText() == L.CONTINUE) then
			if(IsQuestCompletable()) then
				self.acceptButton:Show();
			else
				self.acceptButton:Hide();
			end
		else
			self.acceptButton:Show();
		end

		if(self.acceptButton.fontString:GetText() == L.THANK_YOU and (self.textIndex == #self.text or #self.text == 0)) then
			if(GetNumQuestChoices() > 1 and	not self.choicePanel:IsShown()) then
				UIFrameFadeIn(self.choicePanel, 0.5, 0, 1);
			end
			if((GetNumQuestRewards() > 0 or GetNumQuestChoices() == 1) and not self.rewardPanel:IsShown()) then
				UIFrameFadeIn(self.rewardPanel, 0.5, 0, 1);
			end
		end
		
		self.declineButton:Show();
		
		--checks if the questText is not empty, then hides the text and makes
		if(self.questText:GetText()) then
			--hides questText
			self.questText:SetText("");
			--show oldText
			self.prevQuestText:SetText(self.text[self.textIndex]);
			frameFade(self.prevQuestText, 0.5, 0, 1);
		end
		
		--rearrange buttons
		local screenHeight = GetScreenHeight()*UIParent:GetEffectiveScale();
		if(self.acceptButton:IsShown()) then
			self.acceptButton:SetPoint("BOTTOM", 100, screenHeight/28);
			self.declineButton:SetPoint("BOTTOM", -100, screenHeight/28);
		else
			self.declineButton:SetPoint("BOTTOM", 0, screenHeight/28);
		end
		
		
		return;
	end
	--checks if the text is fading in, if yes, shows the rest.
	if(isTextAnimating()) then
		self.questText:SetAlphaGradient(string.len(self.questText:GetText()),1);
		isAnimating = false;
		animationFrame:SetScript("OnUpdate", nil);
	else
		self.prevQuestText:SetText(self.text[self.textIndex]);
		frameFade(self.prevQuestText, 0.5, 0, 1);
		self.textIndex = self.textIndex + 1;
		self.questText:SetText(self.text[self.textIndex]);
		animateText(self.questText);
	end
end


-------------------------------------
--
-- Sets up all the frames for letterbox.
--
-------------------------------------
local function setUpLetterBox()
	local screenWidth = GetScreenWidth()*UIParent:GetEffectiveScale();
	local screenHeight = GetScreenHeight()*UIParent:GetEffectiveScale();

	letterBox = CatchTheWind; --CreateFrame("FRAME", "CatchTheWind", nil);
	letterBox:SetAllPoints();

	--BlackBars
	letterBox.bottomPanel:SetSize(screenWidth, screenHeight/7);
	letterBox.topPanel:SetSize(screenWidth, screenHeight/7);

	--QuestText
	letterBox.questText:SetSize(screenWidth*0.75, screenHeight/7);
	letterBox.questText:SetFont(blizzardFont, 16, "OUTLINE");

	--fontString that shows the previous quest text, the previous line that the player read
	letterBox.prevQuestText:SetSize(screenWidth*0.75, screenHeight/7);
	letterBox.prevQuestText:SetFont(blizzardFont, 16, "OUTLINE");

	setUpQuestChoicePanel();
	setUpQuestRewardPanel();
	
	letterBox.acceptButton = createButton("CTWacceptButton", letterBox, "Accept", function(self, button)
		QuestDetailAcceptButton_OnClick();
	end);

	letterBox.declineButton = createButton("CTWdeclineButton", letterBox, "Decline", function(self, button)
		QuestDetailDeclineButton_OnClick();
	end);
	
	
	letterBox:EnableMouse(true);
	--set up script for mouse clicks
	letterBox:SetScript("OnMouseUp", function(self, button)
		onClickKey(self);
	end);
	
	letterBox:SetScript("OnKeyUp", function(self, key)
		--SPACE, ESCAPE, A, D, F10, F12
		if(key == "SPACE") then
			if(self.selectedButton and (self.acceptButton:IsShown() or self.declineButton:IsShown())) then
				self.selectedButton:GetScript("OnMouseUp")();
			else
				onClickKey(self);
			end
		elseif(key == "ESCAPE") then
			securecall("CloseAllWindows");
			animationFrame:SetScript("OnUpdate", nil);
		elseif(key == "D" and self.acceptButton:IsShown()) then
			self.selectedButton = self.acceptButton;
			self.acceptButton.fontString:SetTextColor(1, 1, 1, 1);
			self.declineButton.fontString:SetTextColor(0.45, 0.45, 0.45, 1);
		elseif(key == "A" and self.declineButton:IsShown()) then
			self.selectedButton = self.declineButton;
			self.declineButton.fontString:SetTextColor(1, 1, 1, 1);
			self.acceptButton.fontString:SetTextColor(0.45, 0.45, 0.45, 1);
		elseif(key == "F1") then
			if(CTWHelpFrame:IsShown()) then
				CTWHelpFrame:Hide();
			else
				CTWHelpFrame:Show();
			end
		elseif(key == "F10") then
			hideLetterBox();
		elseif(key == "F12") then
			Screenshot();
		end

	end);
	
	letterBox:SetScript("OnHide", function(self)
		CTWQuestTitleFrame:Hide();
	end);
	
	letterBox:Hide();
	
	
	--DECRECATED (events will now handle visibility) - Still gonna keep this if future bugs arise.
	--[[
	QuestFrame:HookScript("OnHide", function()
		--hideLetterBox();
	end);
	]]--
	
end


-------------------------------------
--
-- Load SavedVariables.
-- If there are no SVs, then it creates them.
--
-------------------------------------
local function loadSavedVariables()
	if(not CatchTheWindSV) then
		CatchTheWindSV = {};
		CatchTheWindSV[UnitName("player")] = {};
		CatchTheWindSV[UnitName("player")]["FactorTextSpeed"] = 1;
	elseif(CatchTheWindSV[UnitName("player")]) then
		factorTextSpeed = CatchTheWindSV[UnitName("player")]["FactorTextSpeed"];
		questSoundEnabled = CatchTheWindSV[UnitName("player")]["QuestSoundEnabled"];
	else
		CatchTheWindSV[UnitName("player")] = {};
		CatchTheWindSV[UnitName("player")]["FactorTextSpeed"] = 1;
	end
end



------------
--ADDON SCRIPTS
--
--Some funcitons that will be used later for events.

--Locale fonts - Used to set the correct quest text font
local localeFonts = {
	["zhCN"] = "Fonts\\ARKai_T.TTF",
	["ruRU"] = "Fonts\\FRIZQT___CYR.TTF",
	["zhTW"] = "Fonts\\bLEI00D.TTF",
	["koKR"] = "Fonts\\2002.TTF",
}


local function onPlayerLogin()
	--setting the correct font (Chinese, Russian, etc)
	blizzardFont = localeFonts[GetLocale()] or STANDARD_TEXT_FONT;

	setUpLetterBox();
	loadSavedVariables();
	
	if(CatchTheWindSV[UnitName("player")]["SaveView"]) then
		SaveView(5);
	end
	if(not CatchTheWindSV[UnitName("player")]["ShowPreviousText"]) then
		letterBox.prevQuestText:SetTextColor(0,0,0,0); --TODO: this is a quick fix to hide the text - clean this after
	end
	
	if(IsAddOnLoaded("ElvUI")) then
		MMHolder:SetParent(ElvUIParent);
	end
	
	Addon:RegisterEvent("GOSSIP_SHOW");
	Addon:RegisterEvent("MERCHANT_SHOW");
	Addon:RegisterEvent("TRAINER_SHOW");
	Addon:RegisterEvent("TAXIMAP_OPENED");

	Addon:RegisterEvent("GOSSIP_CLOSED");
	Addon:RegisterEvent("MERCHANT_CLOSED");
	Addon:RegisterEvent("TRAINER_CLOSED");
	Addon:RegisterEvent("TAXIMAP_CLOSED");

	Addon:RegisterEvent("QUEST_GREETING");
	Addon:RegisterEvent("QUEST_DETAIL");
	Addon:RegisterEvent("QUEST_PROGRESS");
	Addon:RegisterEvent("QUEST_COMPLETE");
	Addon:RegisterEvent("QUEST_FINISHED");
	
	UIParent:UnregisterEvent("EXPERIMENTAL_CVAR_CONFIRMATION_NEEDED");
end


local function onGossipShow()
	cancelTimer();
	if(GetNumGossipAvailableQuests() + GetNumGossipActiveQuests() > 0) then
		SetView(2);
	end
end

local function onQuestGreetings()
	cancelTimer();
	if(GetNumAvailableQuests() + GetNumActiveQuests() > 0) then
		SetView(2);
	end
end


local function onQuestDetail(questStartItemID)
	if (questStartItemID and questStartItemID ~= 0) or
		(QuestGetAutoAccept() and QuestIsFromAreaTrigger()) or
		(QuestIsFromAdventureMap()) then
		return;
	end
	
	cancelTimer();
	SetView(2);
	
	letterBox.text = GetQuestText();
	
	letterBox.acceptButton.fontString:SetText(L.ACCEPT);
	letterBox.acceptButton:SetScript("OnMouseUp", function() QuestDetailAcceptButton_OnClick(); hideLetterBox(); end);
	
	letterBox.declineButton.fontString:SetText(L.DECLINE);
	letterBox.declineButton:SetScript("OnMouseUp", QuestDetailDeclineButton_OnClick);
	
	CTWQuestTitleFrame.levelFrame.questText:SetText(GetTitleText());
	CTWQuestTitleFrame:Show();
	showLetterBox();
	
	startInteraction();
end


local function onQuestProgress()
	cancelTimer();
	SetView(2);
	
	letterBox.text = GetProgressText();
	
	letterBox.acceptButton.fontString:SetText(L.CONTINUE);
	letterBox.acceptButton:SetScript("OnMouseUp", QuestProgressCompleteButton_OnClick);
	
	letterBox.declineButton.fontString:SetText(L.GOODBYE);
	
	CTWQuestTitleFrame.levelFrame.questText:SetText(GetTitleText());
	CTWQuestTitleFrame:Show();
	
	showLetterBox();
	
	startInteraction();
end


local function onQuestComplete()
	cancelTimer();
	SetView(2);
	if(not letterBox:IsShown()) then
		CTWQuestTitleFrame.levelFrame.questText:SetText(GetTitleText());
		CTWQuestTitleFrame:Show();
	
		showLetterBox();
	end
	
	letterBox.text = GetRewardText();
	
	startInteraction();
	
	--if its a "greedy" quest
	local money = GetQuestMoneyToGet();
	if ( money and money > 0 ) then
		letterBox.acceptButton.fontString:SetText(L.GIVE .. GetCoinTextureString(money));
	else
		letterBox.acceptButton.fontString:SetText(L.THANK_YOU);
	end
	letterBox.acceptButton:SetScript("OnMouseUp", function(self, button)
		if(QuestInfoFrame.itemChoice == 0 and GetNumQuestChoices() > 1 ) then
			UIFrameFlash(letterBox.choicePanel, 0.5, 0.5, 1.5, true, 0, 0);
		else
			if(money and money > 0) then
				GetQuestReward(QuestInfoFrame.itemChoice);
			else
				QuestRewardCompleteButton_OnClick();
			end
		end
	end);
	
	letterBox.declineButton:Hide();
	
	--if there is quest rewards to choose > show quest rewards
	--In Legion, there are quests where GetNumQuestChoices() return 1, those quests are not necessary to click.
	if(GetNumQuestChoices() > 1) then
		--show icons of quests rewards
		for i=1, GetNumQuestChoices() do
			local btn = _G["CTWChoicePanelItem"..i];


			local name, texture, numItems, quality, isUsable = GetQuestItemInfo(btn.type, i);

			SetItemButtonTexture(btn, texture);
			_G[btn:GetName().."IconTexture"]:SetVertexColor(0.35,0.35,0.35,1);

			btn:SetPoint("CENTER", (i-1)*64-(GetNumQuestChoices()/2*64)+32, -12);

			btn:SetID(i);
			btn:Show();
		end

		--hide remain unused buttons
		for i=GetNumQuestChoices()+1, 10 do
			_G["CTWChoicePanelItem"..i]:Hide();
		end
		--letterBox.choicePanel:Show();
	else
		letterBox.choicePanel:Hide();
	end

	--if there are quest rewards > show quest rewards panel
	-- * Show "real" rewards (i.e. rewards that you receive without a choice) :: /run print(GetQuestItemInfo("reward",1)) -- GetNumQuestRewards()
	if(GetNumQuestRewards() > 0 or GetNumQuestChoices() == 1) then
		if(GetNumQuestChoices() == 1) then
			local btn = _G["CTWRewardPanelItem1"];
			btn.type = "choice";

			local name, texture, numItems, quality, isUsable = GetQuestItemInfo(btn.type, 1);

			SetItemButtonTexture(btn, texture);

			btn:SetPoint("CENTER", -20, -(GetNumQuestRewards()/2*64));

			btn:SetID(1);
			btn:Show();
			
			for i=1, GetNumQuestRewards() do
				local btn = _G["CTWRewardPanelItem"..i+1];
				btn.type = "reward";

				local name, texture, numItems, quality, isUsable = GetQuestItemInfo(btn.type, i);

				SetItemButtonTexture(btn, texture);

				btn:SetPoint("CENTER", -20, (i+1-1)*64-(GetNumQuestRewards()/2*64));

				btn:SetID(i);
				btn:Show();				
			end
		else
			for i=1, GetNumQuestRewards() do
				local btn = _G["CTWRewardPanelItem"..i];
				btn.type = "reward";

				local name, texture, numItems, quality, isUsable = GetQuestItemInfo(btn.type, i);

				SetItemButtonTexture(btn, texture);

				btn:SetPoint("CENTER", -20, (i-1)*64-(GetNumQuestRewards()/2*64));

				btn:SetID(i);
				btn:Show();
			end
		end
		

		--getting number of used buttons from RewardPanel
		local i = GetNumQuestRewards();
		if(GetNumQuestChoices() == 1) then
			i = i + 1;
		end
		
		--setting reward panel size
		letterBox.rewardPanel:SetHeight(32*i + 128);
		
		--hide remain unused frames
		while(i < 5) do
			i = i + 1;
			_G["CTWRewardPanelItem"..i]:Hide();
		end
	else
		letterBox.rewardPanel:Hide();
	end
end


--Table with the scripts
Addon.scripts = {
	["PLAYER_LOGIN"] = onPlayerLogin,
	["GOSSIP_SHOW"] = onGossipShow,
	["QUEST_GREETING"] = onQuestGreetings,
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
-- 						- fixCam
-- @param #string cmd : the command that the player inputs
--
-------------------------------------
local function SlashCmd(cmd)
    if(cmd:match("textSpeed")) then
        local factor = tonumber(strtrim(cmd:sub(cmd:find("textSpeed")+9, -1)));
		factorTextSpeed = factor;
		CatchTheWindSV[UnitName("player")]["FactorTextSpeed"] = factor;
		printMessage("CatchTheWind: The text speed is now "..factor.."x faster than the default speed.");
    elseif(cmd == "" or cmd:match("config")) then
    	if(not CatchTheWindConfig:IsShown()) then
    		frameFade(CatchTheWindConfig, 0.25, 0, 1);
    	else
    		frameFade(CatchTheWindConfig, 0.25, 1, 0, true);
    	end
    elseif(cmd:match("fixCam")) then
    	local total, state, i = 0, 0, 1;
    	print("Please wait...");
		timer:SetScript("OnUpdate", function(self, elapsed)
			total = total + elapsed;
			if(total > 1 and state == 0) then
				total = 0;
				print("Setting view #"..i);
				blizz_SetView(i);
				state = 1;
			elseif(total > 1 and state == 1) then
				total = 0;
				print("Reseting view #"..i);
				ResetView(i);
				state = 2;
			elseif(total > 1 and state == 2) then
				total = 0;
				state = 0;
				print("Saving view #"..i);
				SaveView(i);
				i = i + 1;
				if(i > 5) then
					self:SetScript("OnUpdate", nil);
					print("Work complete");
				end
			end
		end);
    else
    	printMessage("CatchTheWind Commands:");
    	printMessage("      /ctw textSpeed x : Where x is the factor.");
    	printMessage("      /ctw fixCam : If you are having problems with the camera (i.e. not following your back).");
    end
end

SlashCmdList["CatchTheWind"] = SlashCmd;


-------------------------------------
--
-- Addon SetScript OnEvent
-- Starts up the addOn.
-- Handled events can be checked right after this function.
--
-------------------------------------
Addon:SetScript("OnEvent", function(self, event, ...)
	if(Addon.scripts[event]) then
		Addon.scripts[event](...);
	elseif(event == "GOSSIP_CLOSED" or event == "MERCHANT_CLOSED" or event == "TRAINER_CLOSED" or event == "QUEST_FINISHED" or event == "TAXIMAP_CLOSED") then
		--a timer is needed because when interacting with merchants/trainers or choosing quests, "GOSSIP_CLOSED" will be
		--triggered and right after a "MERCHANT_SHOW" will pop up and cancel this timer.
		letterBox.rewardPanel:Hide();
		
		createTimer(0.05, function()
			hideLetterBox();
			SetView(5);
		end);
	elseif(event == "MERCHANT_SHOW" or event == "TRAINER_SHOW" or event == "TAXIMAP_OPENED") then
		--SetView(2);
		cancelTimer();
	end
end);


Addon:RegisterEvent("PLAYER_LOGIN");