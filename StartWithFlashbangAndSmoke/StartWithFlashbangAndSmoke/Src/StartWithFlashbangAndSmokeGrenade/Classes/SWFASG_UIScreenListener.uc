// This is an Unreal Script

class SWFASG_UIScreenListener extends UIScreenListener dependson(X2Item_DefaultGrenades) dependson(X2StrategyElement_DefaultTechs);

//var bool didUpdateTemplates;

event OnInit(UIScreen Screen)
{

	if (ISStrategyState())
	{
		// Update the templates in use.
		//if (!didUpdateTemplates)
		//{
			UpdateTemplates();
			//didUpdateTemplates = true;
		//}
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
	local X2ItemTemplate gFlashbang, gSmoke, gSmoke2;
	local ArtifactCost Resources;
	local XComGameStateHistory History;
	local XComGameState_HeadquartersXCom OldXComHQState, NewXComHQState;
	local XComGameState_Item gFlashbangState, gSmokeState, gSmoke2State, ItemState;
	local XComGameState NewGameState;
	local bool fbB, sgB, sg2B;

	// Get the XCom HQ so we can manipulate its items.
	History = `XCOMHISTORY;
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Adding Infinite Medikits");
	OldXComHQState = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
	NewXComHQState = XComGameState_HeadquartersXCom(NewGameState.CreateStateObject(class'XComGameState_HeadquartersXCom', OldXComHQState.ObjectID));

	// Determine if new copies of the items need to be added or if the items already exist in the base
	foreach History.IterateByClassType(class'XComGameState_Item', ItemState)
	{
		if (ItemState.GetMyTemplateName() == 'FlashbangGrenade' && ItemState.InventorySlot == eInvSlot_Unknown)
		{
			fbB = true; // It doesn't need to be manually added.
		}
		if (ItemState.GetMyTemplateName() == 'SmokeGrenade' && ItemState.InventorySlot == eInvSlot_Unknown)
		{
			sgB = true; // It doesn't need to be manually added.
		}
		if (ItemState.GetMyTemplateName() == 'SmokeGrenadeMk2' && ItemState.InventorySlot == eInvSlot_Unknown)
		{
			sg2B = true; // It doesn't need to be manually added.
		}
	}

	// Delete all three grenades from the HQ completely.
	/*RemoveItemCompletely(NewGameState, NewXComHQState, 'FlashbangGrenade');
	RemoveItemCompletely(NewGameState, NewXComHQState, 'SmokeGrenade');
	RemoveItemCompletely(NewGameState, NewXComHQState, 'SmokeGrenadeMk2');*/

	// Get the item templates.
	itemMan = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	gFlashbang = itemMan.FindItemTemplate('FlashbangGrenade');
	gSmoke = itemMan.FindItemTemplate('SmokeGrenade');
	gSmoke2 = itemMan.FindItemTemplate('SmokeGrenadeMk2');

	// Make the modifications to the item templates.
	gFlashbang.StartingItem = true;
	gFlashbang.CanBeBuilt = false;
	gFlashbang.TradingPostValue = 0;

	gSmoke.StartingItem = true;
	gSmoke.CanBeBuilt = false;
	gSmoke.TradingPostValue = 0;

	gSmoke2.CanBeBuilt = false;
	gSmoke2.Requirements.RequiredTechs.RemoveItem('AdvancedGrenades');
	gSmoke2.TradingPostValue = 0;
	gSmoke2.bInfiniteItem = true;
	gSmoke2.Tier = 2;
	gSmoke2.CreatorTemplateName = 'AdvancedGrenades'; // New upgrade path for items
	gSmoke2.BaseItem = 'SmokeGrenade'; // New upgrade path for items
	Resources.ItemTemplateName = 'Supplies';
	Resources.Quantity = 50;
	gSmoke2.Cost.ResourceCosts.RemoveItem(Resources);

	// Save the modifications.
	itemMan.AddItemTemplate(gFlashbang, true);
	itemMan.AddItemTemplate(gSmoke, true);
	itemMan.AddItemTemplate(gSmoke2, true);

	// Add our new versions of the grenades back to the game.
	gFlashbangState = gFlashbang.CreateInstanceFromTemplate(NewGameState);
	gSmokeState = gSmoke.CreateInstanceFromTemplate(NewGameState);
	gSmoke2State = gSmoke2.CreateInstanceFromTemplate(NewGameState);
	gFlashbangState.OnCreation(gFlashbang);
	gSmokeState.OnCreation(gSmoke);
	gSmoke2State.OnCreation(gSmoke2);
	NewGameState.AddStateObject(gFlashbangState);
	NewGameState.AddStateObject(gSmokeState);
	NewGameState.AddStateObject(gSmoke2State);

	// Add items to the HQ if they are needed
	if (!fbB)
	{
		NewXComHQState.AddItemToHQInventory(gFlashbangState);
	}
	if (NewXComHQState.IsTechResearched('AdvancedGrenades') && !sg2B)
	{
		NewXComHQState.AddItemToHQInventory(gSmoke2State);
	}
	else if (!sgB)
	{
		NewXComHQState.AddItemToHQInventory(gSmokeState);
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