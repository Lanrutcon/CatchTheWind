local addonName, addonTable = ...;

--Localization Table
local L;

--Saves locale (e.g. enUS, frFR, etc...) in a variable.
local locale = GetLocale();


------------------------------------------
-- ptPT (Português-Portugal) & ptBR (Português-Brasil)
------------------------------------------
if(locale == "ptPT" or locale == "ptBR") then
	L = {
		--QuestFrame
		ACCEPT = "Aceitar",
		DECLINE = "Rejeitar",
		CHOOSE_YOUR_REWARD = "Escolhe a tua recompensa",
		CONTINUE = "Continuar",
		GOODBYE = "Adeus",
		THANK_YOU = "Obrigado",


		--OptionsMenu
		CAMERA = "Câmara",
		QUEST = "Missão",
		CREDITS = "Creditos",


		--CameraOptions
		ENABLE_CAMERA_ZOOM = "Activar zoom da câmara",
		SAVE_YOUR_VIEW = "Guardar a tua vista",
		CUSTOM_VIEW = "Vista personalizada",
		
		--CameraTooltips
		ENABLE_CAMERA_ZOOM_TOOLTIP = "Câmara faz zoom quando o NPC tem missões",
		SAVE_YOUR_VIEW_TOOLTIP = "Depois de interagir com um NPC, a câmara a ser reposta vai ser a tua.\n\nAtenção: Isto desactiva a habilidade da câmara de seguir a tua personagem.\nDepois de desactivar, escreva: /ctw fixCam.",
		CUSTOM_VIEW_TOOLTIP = "Coloca uma vista diferente para a interação.\nPrimeiro, posiciona a câmara e depois activa esta funcionalidade.",
		
		
		--QuestOptions
		SHOW_PREVIOUS_TEXT = "Mostrar texto anterior",
		CHANGE_TEXT_SPEED = "Alterar velocidade do texto",
		ENABLE_QUEST_SOUND = "Activar som da missão",
		
		--QuestTooltips
		SHOW_PREVIOUS_TEXT_TOOLTIP = "Depois de passar para o próximo parágrafo, o texto anterior é mostrado na parte de cima.",
		CHANGE_TEXT_SPEED_TOOLTIP = "Modifica a velocidade do texto quando se interage com um NPC sobre uma missão.",
		CHANGE_TEXT_SPEED_TOOLTIP2 = "Actual factor da velocidade do texto: %g",
		ENABLE_QUEST_SOUND_TOOLTIP = "Enquanto o texto está a ser animado, um som de 'escrita' está ser reproduzido.",
	};


------------------------------------------
-- Default Language (English)
------------------------------------------
else
	L = {
		--QuestFrame
		ACCEPT = "Accept",
		DECLINE = "Decline",
		CHOOSE_YOUR_REWARD = "Choose your reward",
		CONTINUE = "Continue",
		GOODBYE = "Goodbye",
		THANK_YOU = "Thank you",


		--OptionsMenu
		CAMERA = "Camera",
		QUEST = "Quest",
		CREDITS = "Credits",


		--CameraOptions
		ENABLE_CAMERA_ZOOM = "Enable camera zoom",
		SAVE_YOUR_VIEW = "Save your view",
		CUSTOM_VIEW = "Custom view",
		
		--CameraTooltips
		ENABLE_CAMERA_ZOOM_TOOLTIP = "Camera zooms in/out when a NPC has quests to talk about",
		SAVE_YOUR_VIEW_TOOLTIP = "After interacting with a NPC, it zooms out to your view.\n\nWarning: This disables camera's ability to follow.\nAfter disable this, type: /ctw fixCam.",
		CUSTOM_VIEW_TOOLTIP = "Set a custom view for the interaction.\nFirst, position the camera and then enable this feature.",
		
		
		--QuestOptions
		SHOW_PREVIOUS_TEXT = "Show previous text",
		CHANGE_TEXT_SPEED = "Change text speed",
		ENABLE_QUEST_SOUND = "Enable quest sound",
		
		--QuestTooltips
		SHOW_PREVIOUS_TEXT_TOOLTIP = "After going to the next paragraph, the previous one will be shown at the top.",
		CHANGE_TEXT_SPEED_TOOLTIP = "Changes quest text speed when interacting with a NPC about a quest.",
		CHANGE_TEXT_SPEED_TOOLTIP2 = "Current factor of text speed: %g",
		ENABLE_QUEST_SOUND_TOOLTIP = "When animating the quest text, a writing sound is being played.",
	};
end



--setting table to addonNamespace
addonTable["Locale"] = L;
