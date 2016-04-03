// This is an Unreal Script

// Start with infinite medikits (SWIM)

class SWIM extends UIScreenListener dependson(X2StrategyElement_DefaultTechs);

event OnInit(UIScreen Screen)
{

	if (ISStrategyState())
	{
		// Update the templates in use.
		UpdateTemplates();
	}
}

function bool IsStrategyState()
{
    return `HQGAME  != none && `HQPC != None && `HQPRES != none;
}

// Removes an item entirely from the XComHQ.
function RemoveItemCompletely(XComGameState NewGameState, XComGameState_HeadquartersXCom NewXComHQState, name ItemName)
{
	local XComGameState_Item InventoryItemState, ItemState;
	local array<XComGameState_Item> InventoryItems;
	local array<XComGameState_Unit> Soldiers;
	local int iSoldier;

	ItemState = NewXComHQState.GetItemByName(ItemName);
	if (ItemState != none)
	{
		NewXComHQState.RemoveItemFromInventory(NewGameState, ItemState.GetReference(), ItemState.Quantity);
		NewGameState.RemoveStateObject(ItemState.GetReference().ObjectID);

		Soldiers = NewXComHQState.GetSoldiers();
		for (iSoldier = 0; iSoldier < Soldiers.Length; iSoldier++)
		{
			InventoryItems = Soldiers[iSoldier].GetAllInventoryItems(NewGameState, false);

			foreach InventoryItems(InventoryItemState)
			{
				if (InventoryItemState.GetMyTemplateName() == ItemName)
				{
					// Remove the old item and delete it from the game
					Soldiers[iSoldier].RemoveItemFromInventory(InventoryItemState, NewGameState);
					NewGameState.RemoveStateObject(InventoryItemState.GetReference().ObjectID);
				}
			}
		}
	}
}

function UpdateTemplates()
{
	local X2ItemTemplateManager itemMan;

	local X2ItemTemplate gMedikit, gNanomedikit;

	local ArtifactCost Resources, Artifacts;
	local XComGameStateHistory History;
	local XComGameState_HeadquartersXCom OldXComHQState, NewXComHQState;

	local XComGameState_Item gMedikitState, gNanomedikitState, ItemState;

	local XComGameState NewGameState;

	local bool mB, nmB;

	// Get the XCom HQ so we can manipulate its items.
	History = `XCOMHISTORY;
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Adding Infinite Flashbang and Smoke Grenades");
	OldXComHQState = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
	NewXComHQState = XComGameState_HeadquartersXCom(NewGameState.CreateStateObject(class'XComGameState_HeadquartersXCom', OldXComHQState.ObjectID));

	// Determine if new copies of the items need to be added or if the items already exist in the base
	foreach History.IterateByClassType(class'XComGameState_Item', ItemState)
	{
		if (ItemState.GetMyTemplateName() == 'Medikit' && ItemState.InventorySlot == eInvSlot_Unknown)
		{
			mB = true; // It doesn't need to be manually added.
		}
		if (ItemState.GetMyTemplateName() == 'NanoMedikit' && ItemState.InventorySlot == eInvSlot_Unknown)
		{
			nmB = true; // It doesn't need to be manually added.
		}
	}

	// Delete the previous medikits from the HQ entirely.
	//RemoveItemCompletely(NewGameState, NewXComHQState, 'Medikit');
	//RemoveItemCompletely(NewGameState, NewXComHQState, 'NanoMedikit');

	// Get the item templates.
	itemMan = class'X2ItemTemplateManager'.static.GetItemTemplateManager();

	gMedikit = itemMan.FindItemTemplate('Medikit');
	gNanomedikit = itemMan.FindItemTemplate('NanoMedikit');

	gMedikit.StartingItem = true;
	gMedikit.CanBeBuilt = false;
	gMedikit.TradingPostValue = 0;

	gNanoMedikit.CanBeBuilt = false;
	gNanoMedikit.Requirements.RequiredTechs.RemoveItem('BattlefieldMedicine');
	gNanoMedikit.TradingPostValue = 0;
	gNanoMedikit.bInfiniteItem = true;
	gNanoMedikit.CreatorTemplateName = 'BattlefieldMedicine';
	gNanoMedikit.BaseItem = 'Medikit';
	Resources.ItemTemplateName = 'Supplies';
	Resources.Quantity = 50;
	gNanoMedikit.Cost.ResourceCosts.RemoveItem(Resources);
	Artifacts.ItemTemplateName = 'CorpseViper';
	Artifacts.Quantity = 1;
	gNanoMedikit.Cost.ArtifactCosts.RemoveItem(Artifacts);

	// Save the modifications.
	itemMan.AddItemTemplate(gMedikit, true);
	itemMan.AddItemTemplate(gNanoMedikit, true);

	// Add our new versions of the grenades back to the game.
	gMedikitState = gMedikit.CreateInstanceFromTemplate(NewGameState);
	gNanoMedikitState = gNanoMedikit.CreateInstanceFromTemplate(NewGameState);
	gMedikitState.OnCreation(gMedikit);
	gNanoMedikitState.OnCreation(gNanoMedikit);
	
	NewGameState.AddStateObject(gMedikitState);
	NewGameState.AddStateObject(gNanoMedikitState);

	if (NewXComHQState.IsTechResearched('BattlefieldMedicine') && !nmB)
	{
		NewXComHQState.AddItemToHQInventory(gNanoMedikitState);
	}
	else if (!mB)
	{
		NewXComHQState.AddItemToHQInventory(gMedikitState);
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