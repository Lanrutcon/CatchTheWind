local addonName, addonTable = ...;

--Localization Table
local L;

--Saves locale (e.g. enUS, frFR, etc...) in a variable.
local locale = GetLocale();


------------------------------------------
-- frFR (Français)
------------------------------------------
if(locale == "frFR") then
	L = {
		--QuestFrame
		ACCEPT = "Accepter",
		DECLINE = "Refuser",
		CHOOSE_YOUR_REWARD = "Choisissez votre récompense",
		CONTINUE = "Continuer",
		GOODBYE = "Au revoir",
		THANK_YOU = "Merci",
		GIVE = "Donner",


		--OptionsMenu
		CAMERA = "Caméra",
		QUEST = "Quête",
		CREDITS = "Crédits",


		--CameraOptions
		ENABLE_CAMERA_ZOOM = "Activer la vue rapprochée",
		SAVE_YOUR_VIEW = "Sauvegarder la position de votre caméra",
		CUSTOM_VIEW = "Position de caméra personnalisée",
		ENABLE_ACTION_CAM = "Enable ActionCam",			--TODO

		--CameraTooltips
		ENABLE_CAMERA_ZOOM_TOOLTIP = "La caméra zoome en avant lorsqu'un PNJ vous présente une quête, puis zoome arrière.",
		SAVE_YOUR_VIEW_TOOLTIP = "Après avoir interagi avec un PNJ, reviens à votre position caméra.\n\nWarning: Ceci désactive la capacité de la caméra à suivre votre personnage.\nAprès avoir désactivé cette fonctionnalité, tapez: /ctw fixCam.",
		CUSTOM_VIEW_TOOLTIP = "Définissez une position personnalisée de caméra pour l'interaction avec les PNJ.\nD'abord, positionnez la caméra et ensuite activez cette fonctionnalité.",
		ENABLE_ACTION_CAM_TOOLTIP = "Uses Blizzard's 'ActionCam' feature to give a better view.\n\nWarning: Don't use it if you are already playing with it.",		--TODO


		--QuestOptions
		SHOW_PREVIOUS_TEXT = "Afficher le dialogue précédent",
		CHANGE_TEXT_SPEED = "Changer la vitesse de défilement du texte",
		ENABLE_QUEST_SOUND = "Activer le son de plume lors de la narration",

		--QuestTooltips
		SHOW_PREVIOUS_TEXT_TOOLTIP = "Après avoir lu un dialogue et cliqué sur le bouton Continuer, le dialogue lu s'affichera au-dessus de l'écran.",
		CHANGE_TEXT_SPEED_TOOLTIP = "Change la vitesse de défilement du texte lors d'une interaction avec un PNJ de quête.",
		CHANGE_TEXT_SPEED_TOOLTIP2 = "Modificateur actuel de défilement textuel : %g",
		ENABLE_QUEST_SOUND_TOOLTIP = "Lorque le texte défile, un son de plume écrivant sur un parchemin est joué, ravivant de vieux souvenirs.",
	};

------------------------------------------
-- ptPT (Português-Portugal) & ptBR (Português-Brasil)
------------------------------------------
elseif(locale == "ptPT" or locale == "ptBR") then
	L = {
		--QuestFrame
		ACCEPT = "Aceitar",
		DECLINE = "Rejeitar",
		CHOOSE_YOUR_REWARD = "Escolhe a tua recompensa",
		CONTINUE = "Continuar",
		GOODBYE = "Adeus",
		THANK_YOU = "Obrigado",
		GIVE = "Dar",


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
		GIVE = "Give",


		--OptionsMenu
		CAMERA = "Camera",
		QUEST = "Quest",
		CREDITS = "Credits",


		--CameraOptions
		ENABLE_CAMERA_ZOOM = "Enable camera zoom",
		SAVE_YOUR_VIEW = "Save your view",
		CUSTOM_VIEW = "Custom view",
		ENABLE_ACTION_CAM = "Enable ActionCam",

		--CameraTooltips
		ENABLE_CAMERA_ZOOM_TOOLTIP = "Camera zooms in/out when a NPC has quests to talk about.",
		SAVE_YOUR_VIEW_TOOLTIP = "After interacting with a NPC, it zooms out to your view.\n\nWarning: This disables camera's ability to follow.\nAfter disable this, type: /ctw fixCam.",
		CUSTOM_VIEW_TOOLTIP = "Set a custom view for the interaction.\nFirst, position the camera and then enable this feature.",
		ENABLE_ACTION_CAM_TOOLTIP = "Uses Blizzard's 'ActionCam' feature to give a better view.\n\nWarning: Don't use it if you are already playing with it.",


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
