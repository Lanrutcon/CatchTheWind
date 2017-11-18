local addonName, addonTable = ...;
local L = addonTable["Locale"];

function CatchTheWindConfigMenuButton_OnClick(self, button)
	for num, button in pairs(self:GetParent().menuButtonsTable) do
		button:Enable();
	end
	PlaySound(856);
	self:Disable();
	
	self.func();
end


function CatchTheWindConfigCheckButton_OnClick(self, button)
	if(self:GetChecked()) then
		self.text:SetTextColor(0.4, 1, 0.4);
	else
		self.text:SetTextColor(1, 0.4, 0.4);
	end
	PlaySound(856);
	self.func(self:GetChecked());
end


function CatchTheWindConfig_OnLoad(self)
	self.cameraMenuButton.text:SetText(L.CAMERA);
	self.questMenuButton.text:SetText(L.QUEST);
	self.creditsMenuButton.text:SetText(L.CREDITS);
	
	self.menuButtonsTable = {
		self.cameraMenuButton,
		self.questMenuButton,
		self.creditsMenuButton,
	};
end

function CatchTheWindConfig_OnShow()
	--shows the first tab
	CatchTheWindConfigMenuButton_OnClick(CatchTheWindConfigCameraMenuButton);
	
	--load savedVariables and update buttons
	local menu = CatchTheWindConfigCameraMenu;
	menu.toggleCamera:SetChecked(CatchTheWindSV[UnitName("player")]["CameraEnabled"]);
	if(CatchTheWindSV[UnitName("player")]["CameraEnabled"]) then
		menu.toggleCamera.text:SetTextColor(0.4, 1, 0.4);
	else
		menu.toggleCamera.text:SetTextColor(1, 0.4, 0.4);
		
		--if the camera is not enable, disable "Save View", "Custom View" and "Enable ActionCam" button
		menu.saveView:Disable();
		menu.customView:Disable();
		menu.toggleActionCam:Disable();
		return;
	end
	
	menu.saveView:SetChecked(CatchTheWindSV[UnitName("player")]["SaveView"]);
	if(CatchTheWindSV[UnitName("player")]["SaveView"]) then
		menu.saveView.text:SetTextColor(0.4, 1, 0.4);
	else
		menu.saveView.text:SetTextColor(1, 0.4, 0.4);
	end
	
	menu.customView:SetChecked(CatchTheWindSV[UnitName("player")]["CustomView"]);
	if(CatchTheWindSV[UnitName("player")]["CustomView"]) then
		menu.customView.text:SetTextColor(0.4, 1, 0.4);
	else
		menu.customView.text:SetTextColor(1, 0.4, 0.4);
	end
	
	menu.toggleActionCam:SetChecked(CatchTheWindSV[UnitName("player")]["ActionCamEnabled"]);
	if(CatchTheWindSV[UnitName("player")]["ActionCamEnabled"]) then
		menu.toggleActionCam.text:SetTextColor(0.4, 1, 0.4);
	else
		menu.toggleActionCam.text:SetTextColor(1, 0.4, 0.4);
	end
end


function CatchTheWindConfigCameraMenuToggleCamera_OnLoad(self)
	self.text:SetText(L.ENABLE_CAMERA_ZOOM);
	self.tooltipText = L.ENABLE_CAMERA_ZOOM_TOOLTIP;

	self.func = function(newValue)
		CatchTheWindSV[UnitName("player")]["CameraEnabled"] = newValue;
		print(newValue)
		if(newValue == false) then
			self:GetParent().saveView:Disable();
			CatchTheWindSV[UnitName("player")]["SaveView"] = nil;
			
			self:GetParent().customView:Disable();
			CatchTheWindSV[UnitName("player")]["CustomView"] = nil;
			
			self:GetParent().customView.func();
			
			self:GetParent().toggleActionCam:Disable();
			CatchTheWindSV[UnitName("player")]["ActionCamEnabled"] = nil;
		else
			self:GetParent().saveView:Enable();
			self:GetParent().customView:Enable();
			self:GetParent().toggleActionCam:Enable();
		end
	end
end

function CatchTheWindConfigCameraMenuSaveView_OnLoad(self)
	self.text:SetText(L.SAVE_YOUR_VIEW);
	self.tooltipText = L.SAVE_YOUR_VIEW_TOOLTIP;
	
	self.func = function(newValue)
		CatchTheWindSV[UnitName("player")]["SaveView"] = newValue;
	end
end

function CatchTheWindConfigCameraMenuCustomView_OnLoad(self)
	self.text:SetText(L.CUSTOM_VIEW);
	self.tooltipText = L.CUSTOM_VIEW_TOOLTIP;
	
	self.func = function(newValue)
		if(newValue) then
			SaveView(2);
		else
			SetView(2);
			ResetView(2);
			ResetView(2);
			SaveView(2);
		end
		CatchTheWindSV[UnitName("player")]["CustomView"] = newValue;
	end
end

function CatchTheWindConfigCameraMenuToggleActionCam_OnLoad(self)
	self.text:SetText(L.ENABLE_ACTION_CAM);
	self.tooltipText = L.ENABLE_ACTION_CAM_TOOLTIP;

	self.func = function(newValue)
		CatchTheWindSV[UnitName("player")]["ActionCamEnabled"] = newValue;
	end
end


function CatchTheWindConfigQuestMenuPreviousText_OnLoad(self)
	self.text:SetText(L.SHOW_PREVIOUS_TEXT);
	self.tooltipText = L.SHOW_PREVIOUS_TEXT_TOOLTIP;

	self.func = function(newValue)
		CatchTheWindSV[UnitName("player")]["ShowPreviousText"] = newValue;
	end
end


function CatchTheWindConfigQuestMenuTextSpeed_OnLoad(self)
	self.text:SetText(L.CHANGE_TEXT_SPEED);
	self.tooltipText = L.CHANGE_TEXT_SPEED_TOOLTIP;
	self.tooltipRequirement = L.CHANGE_TEXT_SPEED_TOOLTIP2;
	
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
end


function CatchTheWindConfigQuestMenuQuestSound_OnLoad(self)
	self.text:SetText(L.ENABLE_QUEST_SOUND);
	self.tooltipText = L.ENABLE_QUEST_SOUND_TOOLTIP;

	self.func = function(newValue)
		CatchTheWindSV[UnitName("player")]["QuestSoundEnabled"] = newValue;
	end
end


local creditsText =
[[|cffff9966CatchTheWind|r created by |cff6699ffLanrutcon|r

|cffff9966Quest Reward Panel|r suggested by |cff6699ffKrainz|r
|cffff9966Previous Quest Text|r suggested by |cff6699ffMattOzone|r
|cffff9966Modifier NPC Interaction|r suggested by |cff6699ffihithim|r
|cffff9966Quest Sound|r suggested by |cff6699ffRaffiq|r

|cffff9966French translation|r made by |cff6699ffRaffiq|r
|cffff9966Russian translation|r made by |cff6699ffAdan714|r


|cff99ff66Special Thanks|r to:
|cffffff44JV|r
|cffffff44GR|r]];


function CatchTheWindConfigCreditsMenu_OnLoad(self)
	self.creditsText:SetText(creditsText);
end