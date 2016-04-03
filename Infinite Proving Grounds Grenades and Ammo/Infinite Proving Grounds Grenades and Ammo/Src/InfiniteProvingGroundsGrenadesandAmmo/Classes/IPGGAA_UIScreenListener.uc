class IPGGAA_UIScreenListener extends UIScreenListener dependson(X2Item_DefaultGrenades) dependson(X2StrategyElement_DefaultTechs);

var bool didUpdateTemplates;

// This here, every time the thing starts, does the thingy.

event OnInit(UIScreen Screen)
{
	if (IsStrategyState())
	{
		UpdateTemplates();
	}
}

function bool IsStrategyState()
{
    return `HQGAME  != none && `HQPC != None && `HQPRES != none;
}

function GiveDeckedItemRewardNoRepeat(XComGameState NewGameState, XComGameState_Tech TechState)
{
	local X2ItemTemplateManager ItemTemplateManager;
	local X2ItemTemplate ItemTemplate;	
	local X2CardManager CardManager;
	local string RewardName;

	CardManager = class'X2CardManager'.static.GetCardManager();
	CardManager.SelectNextCardFromDeck(TechState.GetMyTemplate().RewardDeck, RewardName);

	// Safety check in case the deck doesn't exist on old saves
	if (RewardName == "")
	{
		TechState.SetUpTechRewardDeck(TechState.GetMyTemplate());
		CardManager.SelectNextCardFromDeck(TechState.GetMyTemplate().RewardDeck, RewardName);
	}
	
	ItemTemplateManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	ItemTemplate = ItemTemplateManager.FindItemTemplate(name(RewardName));

	// New line of code that ensures no repeats.
	CardManager.RemoveCardFromDeck(TechState.GetMyTemplate().RewardDeck, RewardName);

	GiveItemReward(NewGameState, TechState, ItemTemplate);
}

function GiveItemReward(XComGameState NewGameState, XComGameState_Tech TechState, X2ItemTemplate ItemTemplate)
{	
	class'XComGameState_HeadquartersXCom'.static.GiveItem(NewGameState, ItemTemplate);

	TechState.ItemReward = ItemTemplate; // Needed for UI Alert display info
	TechState.bSeenResearchCompleteScreen = false; // Reset the research report for techs that are repeatable
}

function UpdateTemplates()
{
	local X2ItemTemplateManager itemMan;
	local X2StrategyElementTemplateManager stratMan;
	local XComGameStateHistory History;
	local XComGameState_HeadquartersXCom OldXComHQState, NewXComHQState;
	local XComGameState NewGameState;
	local XComGameState_Item ItemState;
	local bool fbA, ggA, agA, fb2A, gg2A, ag2A;
	local bool fbB, ggB, agB, fb2B, gg2B, ag2B;
	local X2ItemTemplate gFB, gGG, gAG;
	local X2ItemTemplate gFB2, gGG2, gAG2;
	local XComGameState_Item gFBS, gGGS, gAGS;
	local XComGameState_Item gFB2S, gGG2S, gAG2S;
	local XComGameState_Tech TechState;
	local X2TechTemplate tExpGren, tExpAmmo;
	local XComGameState_Tech tExpGrenState, tExpAmmoState;
	local X2CardManager cardMan;
	local bool ap, tr, ir, ta, vr;
	local bool ap2, tr2, ir2, ta2, vr2;
	local X2ItemTemplate aAP, aTR, aIR, aTA, aVR;
	local XComGameState_Item aAPS, ATRS, aIRS, aTAS, aVRS;

	// Get the XCom HQ so we can manipulate its items.
	History = `XCOMHISTORY;
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Making Proving Ground's Grenades and Ammo Infinite");
	OldXComHQState = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
	NewXComHQState = XComGameState_HeadquartersXCom(NewGameState.CreateStateObject(class'XComGameState_HeadquartersXCom', OldXComHQState.ObjectID));
	
	// Pre-set all experimental grenades to not be had by the player.
	fbA = false; ggA = false; agA = false;
	fb2A = false; gg2A = false; ag2A = false;
	fbB = false; ggB = false; agB = false;
	fb2B = false; gg2B = false; ag2B = false;
	// Pre-set all experimental ammos to not be had by the player.
	ap = false; tr = false; ir = false; ta = false; vr = false;
	// Determine which experimental greandes and ammo are had by the player.
	foreach History.IterateByClassType(class'XComGameState_Item', ItemState)
	{
		// Experimental Grenade Checking
		if (ItemState.GetMyTemplateName() == 'Firebomb')
		{
			if (ItemState.Quantity >= 1)
			{
				fbA = true;
			}
			if (ItemState.InventorySlot == eInvSlot_Unknown)
			{
				fbB = true; // It doesn't need to be manually added.
			}
		}
		if (ItemState.GetMyTemplateName() == 'GasGrenade')
		{
			if (ItemState.Quantity >= 1)
			{
				ggA = true;
			}
			if (ItemState.InventorySlot == eInvSlot_Unknown)
			{
				ggB = true; // It doesn't need to be manually added.
			}
		}
		if (ItemState.GetMyTemplateName() == 'AcidGrenade')
		{
			if (ItemState.Quantity >= 1)
			{
				agA = true;
			}
			if (ItemState.InventorySlot == eInvSlot_Unknown)
			{
				agB = true; // It doesn't need to be manually added.
			}
		}
		if (ItemState.GetMyTemplateName() == 'FirebombMK2')
		{
			if (ItemState.Quantity >= 1)
			{
				fb2A = true; // It needs to be added to the inventory.
			}
			if (ItemState.InventorySlot == eInvSlot_Unknown)
			{
				fb2B = true; // It doesn't need to be manually added.
			}
		}
		if (ItemState.GetMyTemplateName() == 'GasGrenadeMk2')
		{
			if (ItemState.Quantity >= 1)
			{
				gg2A = true;
			}
			if (ItemState.InventorySlot == eInvSlot_Unknown)
			{
				gg2B = true; // It doesn't need to be manually added.
			}
		}
		if (ItemState.GetMyTemplateName() == 'AcidGrenadeMk2')
		{
			if (ItemState.Quantity >= 1)
			{
				ag2A = true;
			}
			if (ItemState.InventorySlot == eInvSlot_Unknown)
			{
				ag2B = true; // It doesn't need to be manually added.
			}
		}
		// Experimental Ammo Checking
		if (ItemState.GetMyTemplateName() == 'APRounds')
		{
			if (ItemState.Quantity >= 1)
			{
				ap = true;
			}
			if (ItemState.InventorySlot == eInvSlot_Unknown)
			{
				ap2 = true; // It doesn't need to be manually added.
			}
		}
		if (ItemState.GetMyTemplateName() == 'TracerRounds')
		{
			if (ItemState.Quantity >= 1)
			{
				tr = true;
			}
			if (ItemState.InventorySlot == eInvSlot_Unknown)
			{
				tr2 = true; // It doesn't need to be manually added.
			}
		}
		if (ItemState.GetMyTemplateName() == 'IncendiaryRounds')
		{
			if (ItemState.Quantity >= 1)
			{
				ir = true;
			}
			if (ItemState.InventorySlot == eInvSlot_Unknown)
			{
				ir2 = true; // It doesn't need to be manually added.
			}
		}
		if (ItemState.GetMyTemplateName() == 'TalonRounds')
		{
			if (ItemState.Quantity >= 1)
			{
				ta = true;
			}
			if (ItemState.InventorySlot == eInvSlot_Unknown)
			{
				ta2 = true; // It doesn't need to be manually added.
			}
		}
		if (ItemState.GetMyTemplateName() == 'VenomRounds')
		{
			if (ItemState.Quantity >= 1)
			{
				vr = true;
			}
			if (ItemState.InventorySlot == eInvSlot_Unknown)
			{
				vr2 = true; // It doesn't need to be manually added.
			}
		}
	}
	
	// Get the item templates.
	itemMan = class'X2ItemTemplateManager'.static.GetItemTemplateManager();

	// Grenade templates.
	gFB = itemMan.FindItemTemplate('Firebomb');
	gGG = itemMan.FindItemTemplate('GasGrenade');
	gAG = itemMan.FindItemTemplate('AcidGrenade');
	gFB2 = itemMan.FindItemTemplate('FirebombMK2'); // <- wierdo has different caps
	gGG2 = itemMan.FindItemTemplate('GasGrenadeMk2');
	gAG2 = itemMan.FindItemTemplate('AcidGrenadeMk2');

	// Ammo templates.
	aAP = itemMan.FindItemTemplate('APRounds');
	aTR = itemMan.FindItemTemplate('TracerRounds');
	aIR = itemMan.FindItemTemplate('IncendiaryRounds');
	aTA = itemMan.FindItemTemplate('TalonRounds');
	aVR = itemMan.FindItemTemplate('VenomRounds');

	// Make the modifactions to the item templates.

	// Modify grenades.
	gFB.CanBeBuilt = false;
	gFB.bInfiniteItem = true;
	gFB.TradingPostValue = 0;
	gGG.CanBeBuilt = false;
	gGG.bInfiniteItem = true;
	gGG.TradingPostValue = 0;
	gAG.CanBeBuilt = false;
	gAG.bInfiniteItem = true;
	gAG.TradingPostValue = 0;
	gFB2.CanBeBuilt = false;
	gFB2.bInfiniteItem = true;
	gFB2.TradingPostValue = 0;
	gGG2.CanBeBuilt = false;
	gGG2.bInfiniteItem = true;
	gGG2.TradingPostValue = 0;
	gAG2.CanBeBuilt = false;
	gAG2.bInfiniteItem = true;
	gAG2.TradingPostValue = 0;

	// Modify ammo.
	aAP.CanBeBuilt = false;
	aAP.bInfiniteItem = true;
	aAP.TradingPostValue = 0;
	aTR.CanBeBuilt = false;
	aTR.bInfiniteItem = true;
	aTR.TradingPostValue = 0;
	aIR.CanBeBuilt = false;
	aIR.bInfiniteItem = true;
	aIR.TradingPostValue = 0;
	aTA.CanBeBuilt = false;
	aTA.bInfiniteItem = true;
	aTA.TradingPostValue = 0;
	aVR.CanBeBuilt = false;
	aVR.bInfiniteItem = true;
	aVR.TradingPostValue = 0;

	// Hiding
	gFB.HideIfResearched = 'AdvancedGrenades';
	gGG.HideIfResearched = 'AdvancedGrenades';
	gAG.HideIfResearched = 'AdvancedGrenades';
	
	// Save the modifications.
	// Grenades.
	itemMan.AddItemTemplate(gFB, true);
	itemMan.AddItemTemplate(gGG, true);
	itemMan.AddItemTemplate(gAG, true);
	itemMan.AddItemTemplate(gFB2, true);
	itemMan.AddItemTemplate(gGG2, true);
	itemMan.AddItemTemplate(gAG2, true);
	// Ammo.
	itemMan.AddItemTemplate(aAP, true);
	itemMan.AddItemTemplate(aTR, true);
	itemMan.AddItemTemplate(aIR, true);
	itemMan.AddItemTemplate(aTA, true);
	itemMan.AddItemTemplate(aVR, true);

	// Add to the HQ Inventory only the items that we saw it had before we made the modifications.
	// Grenades.
	if (fbA)
	{
		gFBS = gFB.CreateInstanceFromTemplate(NewGameState);
		gFBS.OnCreation(gFB);
		NewGameState.AddStateObject(gFBS);
		if (!fbB)
		{
			NewXComHQState.AddItemToHQInventory(gFBS);
		}
	}
	if (ggA)
	{
		gGGS = gGG.CreateInstanceFromTemplate(NewGameState);
		gGGS.OnCreation(gGG);
		NewGameState.AddStateObject(gGGS);
		if (!ggB)
		{
			NewXComHQState.AddItemToHQInventory(gGGS);
		}
	}
	if (agA)
	{
		gAGS = gAG.CreateInstanceFromTemplate(NewGameState);
		gAGS.OnCreation(gAG);
		NewGameState.AddStateObject(gAGS);
		if (!agB)
		{
			NewXComHQState.AddItemToHQInventory(gAGS);
		}
	}
	if (fb2A)
	{
		gFB2S = gFB2.CreateInstanceFromTemplate(NewGameState);
		gFB2S.OnCreation(gFB2);
		NewGameState.AddStateObject(gFB2S);
		if (!fb2B)
		{
			NewXComHQState.AddItemToHQInventory(gFB2S);
		}
	}
	if (gg2A)
	{
		gGG2S = gGG2.CreateInstanceFromTemplate(NewGameState);
		gGG2S.OnCreation(gGG2);
		NewGameState.AddStateObject(gGG2S);
		if (!gg2B)
		{
			NewXComHQState.AddItemToHQInventory(gGG2S);
		}
	}
	if (ag2A)
	{
		gAG2S = gAG.CreateInstanceFromTemplate(NewGameState);
		gAG2S.OnCreation(gAG2);
		NewGameState.AddStateObject(gAG2S);
		if (!ag2B)
		{
			NewXComHQState.AddItemToHQInventory(gAG2S);
		}
	}
	// Ammo.
	if (ap)
	{
		aAPS = aAP.CreateInstanceFromTemplate(NewGameState);
		aAPS.OnCreation(aAP);
		NewGameState.AddStateObject(aAPS);
		if (!ap2)
		{
			NewXComHQState.AddItemToHQInventory(aAPS);
		}
	}
	if (tr)
	{
		aTRS = aTR.CreateInstanceFromTemplate(NewGameState);
		aTRS.OnCreation(aTR);
		NewGameState.AddStateObject(aTRS);
		if (!tr2)
		{
			NewXComHQState.AddItemToHQInventory(aTRS);
		}
	}
	if (ir)
	{
		aIRS = aIR.CreateInstanceFromTemplate(NewGameState);
		aIRS.OnCreation(aIR);
		NewGameState.AddStateObject(aIRS);
		if (!ir2)
		{
			NewXComHQState.AddItemToHQInventory(aIRS);
		}
	}
	if (ta)
	{
		aTAS = aTA.CreateInstanceFromTemplate(NewGameState);
		aTAS.OnCreation(aTA);
		NewGameState.AddStateObject(aTAS);
		if (!ta2)
		{
			NewXComHQState.AddItemToHQInventory(aTAS);
		}
	}
	if (vr)
	{
		aVRS = aVR.CreateInstanceFromTemplate(NewGameState);
		aVRS.OnCreation(aVR);
		NewGameState.AddStateObject(aVRS);
		if (!vr2)
		{
			NewXComHQState.AddItemToHQInventory(aVRS);
		}
	}
	
	//===================== new tech mods ======================

	// Remove the previous version of the tech from the game state
	foreach History.IterateByClassType(class'XComGameState_Tech', TechState)
	{
		if (TechState.GetMyTemplateName() == 'ExperimentalGrenade')
		{
			NewGameState.RemoveStateObject(TechState.GetReference().ObjectID);
		}
		if (TechState.GetMyTemplateName() == 'ExperimentalAmmo')
		{
			NewGameState.RemoveStateObject(TechState.GetReference().ObjectID);
		}
	}

	// Get the Tech Templates.
	stratMan = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	tExpGren = X2TechTemplate(stratMan.FindStrategyElementTemplate('ExperimentalGrenade'));
	tExpAmmo = X2TechTemplate(stratMan.FindStrategyElementTemplate('ExperimentalAmmo'));
	
	// Modify them.
	tExpGren.ResearchCompletedFn = GiveDeckedItemRewardNoRepeat;
	tExpAmmo.ResearchCompletedFn = GiveDeckedItemRewardNoRepeat;

	// Save the modifications.
	stratMan.AddStrategyElementTemplate(tExpGren, true);
	stratMan.AddStrategyElementTemplate(tExpAmmo, true);

	cardMan = class'X2CardManager'.static.GetCardManager();

	// Add the techs to the game state only if they haven't had their rewards exhausted.
	if (!((fbA||fb2A) && (ggA||gg2A) && (agA||ag2A)))
	{
		cardMan.AddCardToDeck(tExpGren.RewardDeck, "Firebomb");
		cardMan.AddCardToDeck(tExpGren.RewardDeck, "GasGrenade");
		cardMan.AddCardToDeck(tExpGren.RewardDeck, "AcidGrenade");
		// Remove from the reward deck all of the things that we already have.
		if (fbA||fb2A)
		{
			cardMan.RemoveCardFromDeck(tExpGren.RewardDeck, "Firebomb");
		}
		if (ggA||gg2A)
		{
			cardMan.RemoveCardFromDeck(tExpGren.RewardDeck, "GasGrenade");
		}
		if (agA||ag2A)
		{
			cardMan.RemoveCardFromDeck(tExpGren.RewardDeck, "AcidGrenade");
		}
		tExpGrenState = XComGameState_Tech(NewGameState.CreateStateObject(class'XComGameState_Tech'));
		tExpGrenState.OnCreation(tExpGren);
		NewGameState.AddStateObject(tExpGrenState);
	}

	if (!(ap && tr && ir && ta && vr))
	{
		cardMan.AddCardToDeck(tExpAmmo.RewardDeck, "APRounds");
		cardMan.AddCardToDeck(tExpAmmo.RewardDeck, "TracerRounds");
		cardMan.AddCardToDeck(tExpAmmo.RewardDeck, "IncendiaryRounds");
		cardMan.AddCardToDeck(tExpAmmo.RewardDeck, "TalonRounds");
		cardMan.AddCardToDeck(tExpAmmo.RewardDeck, "VenomRounds");
		if (ap)
		{
			cardMan.RemoveCardFromDeck(tExpAmmo.RewardDeck, "APRounds");
			cardMan.RemoveCardFromDeck(tExpAmmo.RewardDeck, "APRounds");
		}
		if (tr)
		{
			cardMan.RemoveCardFromDeck(tExpAmmo.RewardDeck, "TracerRounds");
			cardMan.RemoveCardFromDeck(tExpAmmo.RewardDeck, "TracerRounds");
		}
		if (ir)
		{
			cardMan.RemoveCardFromDeck(tExpAmmo.RewardDeck, "IncendiaryRounds");
			cardMan.RemoveCardFromDeck(tExpAmmo.RewardDeck, "IncendiaryRounds");
		}
		if (ta)
		{
			cardMan.RemoveCardFromDeck(tExpAmmo.RewardDeck, "TalonRounds");
			cardMan.RemoveCardFromDeck(tExpAmmo.RewardDeck, "TalonRounds");
		}
		if (vr)
		{
			cardMan.RemoveCardFromDeck(tExpAmmo.RewardDeck, "VenomRounds");
			cardMan.RemoveCardFromDeck(tExpAmmo.RewardDeck, "VenomRounds");
		}
		tExpAmmoState = XComGameState_Tech(NewGameState.CreateStateObject(class'XComGameState_Tech'));
		tExpAmmoState.OnCreation(tExpAmmo);
		NewGameState.AddStateObject(tExpAmmoState);
	}

	// Add the changes to the game state, and then push it.
	NewGameState.AddStateObject(NewXComHQState);
	History.AddGameStateToHistory(NewGameState);
}

// This event is triggered after a screen receives focus
event OnReceiveFocus(UIScreen Screen);
 
// This event is triggered after a screen loses focus
event OnLoseFocus(UIScreen Screen);
 
// This event is triggered when a screen is removed
event OnRemoved(UIScreen Screen);
 
defaultproperties
{
    // Leaving this assigned to none will cause every screen to trigger its signals on this class
    ScreenClass = UIFacilityGrid;
}