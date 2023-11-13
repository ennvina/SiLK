local AddonName = ...

SILK_NAME = AddonName
SILK_CHATMESSAGE = NORMAL_FONT_COLOR_CODE .. SILK_NAME .. ": " .. LIGHTYELLOW_FONT_COLOR_CODE .. "%s";
SILK_CHATWARNING = NORMAL_FONT_COLOR_CODE .. SILK_NAME .. ": " .. RED_FONT_COLOR_CODE .. "%s";
SILK_SLASHCMD1 = "/silk"
SILK_SLASHCMD2 = "/slk"

if GetLocale() == "frFR" then

  --
  -- French
  --

  SILK_COMMANDHELP1 = "\"" .. SILK_SLASHCMD1 .. " enable\" ou \"" .. SILK_SLASHCMD1 .. " disable\" pour activer/désactiver l'addon"
  SILK_COMMANDHELP2 = "\"" .. SILK_SLASHCMD1 .. " show\" pour afficher la fenêtre des Val'kyrs du roi-liche"
  SILK_COMMANDHELP3 = "\"" .. SILK_SLASHCMD1 .. " resetwin\" pour remettre à zéro les fenêtres des l'addon"
  SILK_COMMANDHELP4 = "\"" .. SILK_SLASHCMD1 .. " reset\" pour réinitialiser les combats passés"
  SILK_COMMANDHELP5 = "\"" .. SILK_SLASHCMD1 .. " stun showraid\" pour afficher/désafficher sur le canal raid lorsqu'une Val'kyr est stun"
  SILK_COMMANDHELP7 = "\"" .. SILK_SLASHCMD1 .. " timeout <durée>\" pour définir la durée (en secondes) à partir de laquelle l'addon suppose que la Val'kyr devient sans intérêt si personne ne l'a ciblée"
  SILK_COMMANDHELP8 = "\"" .. SILK_SLASHCMD1 .. " channel <canal>\" pour choisir un canal pour les annonces de stun (par défaut : default)"
  SILK_COMMANDHELP9 = "\"" .. SILK_SLASHCMD1 .. " test\" pour afficher des données de test dans la fenêtre des Val'kyrs"
  SILK_COMMANDHELP0 = "\"" .. SILK_SLASHCMD1 .. " help\" pour lister toutes les commandes"
  SILK_WELCOME = SILK_NAME .. " chargé. Entrez " .. SILK_COMMANDHELP0 .. ".";
  SILK_PROMOTENEEDED = "Vous devez être chef de raid ou assistant pour marquer les cibles."
  SILK_RESIZE_TOOLTIP = "|cffffff00Clic|r pour redimensionner".."\n".."|cffffff00Maj + Clic|r pour étirer"
  SILK_CANT_TEST = "Vous devez d'abord afficher la fenêtre des Val'kyrs. Entrez /silk show"
  SILK_STUN_SHOWRAID_ENABLED = "Les stun de Val'kyr seront affichés sur le canal raid."
  SILK_STUN_SHOWRAID_DISABLED = "Les stun de Val'kyr ne seront plus affichés sur le canal raid."
  SILK_STUN_RAID_MESSAGE = "%s est stun par %s pendant %s."
  SILK_TIMEOUT_SET_MESSAGE = "Temps de libération réglé sur %d."
  SILK_TOO_MANY_UNITS_WARNING = "Trop d'unités sont candidates en même temps."
  SILK_CHANNEL_MESSAGE = "Canal de stun défini sur %s."
  SILK_VALKYR_X_ON_Y = "Val'kyr : %d / %d"
  SILK_INCREASE_MATCH = "augment"
  SILK_DECREASE_MATCH = "réduit"

else

  --
  -- English
  --

  SILK_COMMANDHELP1 = "\"" .. SILK_SLASHCMD1 .. " enable\" or \"" .. SILK_SLASHCMD1 .. " disable\" to enable/disable the addon"
  SILK_COMMANDHELP2 = "\"" .. SILK_SLASHCMD1 .. " show\" to display the Val'kyr window for the Lich King encounter"
  SILK_COMMANDHELP3 = "\"" .. SILK_SLASHCMD1 .. " resetwin\" to reset the addon windows"
  SILK_COMMANDHELP4 = "\"" .. SILK_SLASHCMD1 .. " reset\" to reset past encounters"
  SILK_COMMANDHELP5 = "\"" .. SILK_SLASHCMD1 .. " stun showraid\" to show/hide on the raid channel when a Val'kyr is under a stun effect"
  SILK_COMMANDHELP7 = "\"" .. SILK_SLASHCMD1 .. " timeout <duration>\" to set the duration (in seconds) from which a Val'kyr is supposed unimportant if no one targetted it"
  SILK_COMMANDHELP8 = "\"" .. SILK_SLASHCMD1 .. " channel <channel>\" to select a channel to announce stuns to (by default: default)"
  SILK_COMMANDHELP9 = "\"" .. SILK_SLASHCMD1 .. " test\" to display test data into the Val'kyr window"
  SILK_COMMANDHELP0 = "\"" .. SILK_SLASHCMD1 .. " help\" to display the full command list"
  SILK_WELCOME = SILK_NAME .. " loaded. Please enter " .. SILK_COMMANDHELP0 .. ".";
  SILK_PROMOTENEEDED = "You must be raid leader or assistant in order to mark targets."
  SILK_RESIZE_TOOLTIP = "|cffffff00Click|r to resize".."\n".."|cffffff00Shift + Click|r to scale"
  SILK_CANT_TEST = "You must display the Val'kyr window first. Please type /silk show"
  SILK_STUN_SHOWRAID_ENABLED = "Val'kyr stuns will be displayed on the raid channel."
  SILK_STUN_SHOWRAID_DISABLED = "Val'kyr stuns will not be displayed on the raid channel."
  SILK_STUN_RAID_MESSAGE = "%s est stun par %s pendant %s."
  SILK_TIMEOUT_SET_MESSAGE = "Timeout set to %d second(s)."
  SILK_TOO_MANY_UNITS_WARNING = "Too many units registered simultaneously."
  SILK_CHANNEL_MESSAGE = "Stun channel set to %s."
  SILK_VALKYR_X_ON_Y = "Val'kyr: %d / %d"
  SILK_INCREASE_MATCH = "increase"
  SILK_DECREASE_MATCH = "reduce"

end