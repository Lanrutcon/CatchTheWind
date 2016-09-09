function CatchTheWindConfigMenuButton_OnClick(self, button)
	for num, button in pairs(self:GetParent().menuButtonsTable) do
		button:Enable();
	end
	PlaySound("igMainMenuOptionCheckBoxOn");
	self:Disable();
	
	self.func();
end


function CatchTheWindConfigCheckButton_OnClick(self, button)
	if(self:GetChecked()) then
		self.text:SetTextColor(0.4, 1, 0.4);
	else
		self.text:SetTextColor(1, 0.4, 0.4);
	end
	PlaySound("igMainMenuOptionCheckBoxOn");
	self.func(self:GetChecked());
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
		
		--if the camera is not enable, disable "Save View" button
		menu.saveView:Disable();
		return;
	end
	
	menu.saveView:SetChecked(CatchTheWindSV[UnitName("player")]["SaveView"]);
	if(CatchTheWindSV[UnitName("player")]["SaveView"]) then
		menu.saveView.text:SetTextColor(0.4, 1, 0.4);
	else
		menu.saveView.text:SetTextColor(1, 0.4, 0.4);
	end
end



local creditsText =
[[|cffff9966CatchTheWind|r created by |cff6699ffLanrutcon|r

|cffff9966Quest Reward Panel|r suggested by |cff6699ffKrainz|r
|cffff9966Previous Quest Text|r suggested by |cff6699ffMattOzone|r
|cffff9966Modifier NPC Interaction|r suggested by |cff6699ffihithim|r
|cffff9966Quest Sound|r suggested by |cff6699ffbenoitheylens|r]];
 

function CatchTheWindConfigCreditsMenu_OnLoad(self)
	self.creditsText:SetText(creditsText);
end








