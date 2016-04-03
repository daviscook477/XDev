// This is an Unreal Script

class MG_UIScreenListener extends UIScreenListener;

var bool didUpdateTemplates;
 
// This event is triggered after a screen is initialized
event OnInit(UIScreen Screen)
{
    if(!didUpdateTemplates)
    {
        UpdateTemplates();
        didUpdateTemplates = true;
    }   
}

function UpdateTemplates()
{
	local X2ItemTemplateManager itemMan;
	local MGGrenade_Medikit mg;
	//local X2StrategyElementTemplateManager stratMan; // bad
	//local X2TechTemplate gAdvGren; // bad
	local X2CardManager cardMan;

	mg = new class'MGGrenade_Medikit';

	itemMan = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	itemMan.AddItemTemplate(mg.CreateGrenadeMK1());
	itemMan.AddItemTemplate(mg.CreateGrenadeMK2());
	
	// This disables the cost of experimental grenades for testing purposes.
	//stratMan = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager(); // bad
	//gAdvGren = X2TechTemplate(stratMan.FindStrategyElementTemplate('ExperimentalGrenade')); // bad
	//gAdvGren.Cost.ArtifactCosts.Remove(0, 1); // bad
	//stratMan.AddStrategyElementTemplate(gAdvGren, true); // bad


	cardMan = class'X2CardManager'.static.GetCardManager();
	cardMan.AddCardToDeck('ExperimentalGrenadeRewards', "MGGrenade_Medikit");
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