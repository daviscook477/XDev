// This is an Unreal Script

class IPGGAA_ResearchReportListener extends UIScreenListener;

// This event is triggered after a screen is initialized
event OnInit(UIScreen Screen)
{
	local X2CardManager cardMan;
	local XComGameStateHistory History;
	local XComGameState_Tech TechState;
	local array<string> CardLabels;
	local XComGameState NewGameState;

	// Check to see if the reward deck has been emptied -> if so, remove the project from the available list.
	cardMan = class'X2CardManager'.static.GetCardManager();

	History = `XCOMHISTORY;
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Removing the Proving Ground Project When Exhausted");
	foreach History.IterateByClassType(class'XComGameState_Tech', TechState)
	{
		if (TechState.GetMyTemplateName() == 'ExperimentalGrenade')
		{
			cardMan.GetAllCardsInDeck('ExperimentalGrenadeRewards', CardLabels);

			// If there aren't any cards left
			if (CardLabels.Length < 1)
			{
				// Remove the proving grounds project from being available.
				NewGameState.RemoveStateObject(TechState.GetReference().ObjectID);
			}
		}
		if (TechState.GetMyTemplateName() == 'ExperimentalAmmo')
		{
			cardMan.GetAllCardsInDeck('ExperimentalAmmoRewards', CardLabels);

			// If there aren't any cards left
			if (CardLabels.Length < 1)
			{
				// Remove the proving grounds project from being available.
				NewGameState.RemoveStateObject(TechState.GetReference().ObjectID);
			}
		}
	}

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
	ScreenClass = UIAlert;
}