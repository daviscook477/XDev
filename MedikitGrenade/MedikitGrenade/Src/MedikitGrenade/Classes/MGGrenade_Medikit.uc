// This is an Unreal Script

class MGGrenade_Medikit extends X2Item config(MG);

var config int MEDIKIT_GRENADE_ISOUNDRANGE;
var config int MEDIKIt_GRENADE_IENVIRONMENTDAMAGE;
var config int MEDIKIT_GRENADE_IPOINTS;
var config int MEDIKIT_GRENADE_ICLIPSIZE;
var config int MEDIKIT_GRENADE_RANGE;
var config int MEDIKIT_GRENADE_RADIUS;
var config int MEDIKIT_PERUSEHP;
var config int NANOMEDIKIT_PERUSEHP;


function X2Effect_ApplyMedikitHeal CreateMedikitHealEffect(int HealPerUse)
{
	local X2Effect_ApplyMedikitHeal HealingEffect;
	HealingEffect = new class'X2Effect_ApplyMedikitHeal';
	HealingEffect.PerUseHP = HealPerUse;
	return HealingEffect;
}

function X2ItemTemplate CreateGrenadeMK1()
{
	local X2GrenadeTemplate Template;
	local X2Effect_ApplyMedikitHeal HealingEffect;

	`CREATE_X2TEMPLATE(class'X2GrenadeTemplate', Template, 'MGGrenade_Medikit');

	Template.strImage = "img:///UILibrary_StrategyImages.X2InventoryIcons.Inv_Medkit";
	Template.EquipSound = "StrategyUI_Grenade_Equip";
	Template.AddAbilityIconOverride('ThrowGrenade', "img:///UILibrary_PerkIcons.UIPerk_grenade_flash");
	Template.AddAbilityIconOverride('LaunchGrenade', "img:///UILibrary_PerkIcons.UIPerk_grenade_flash");

	Template.iRange = MEDIKIT_GRENADE_RANGE;
	Template.iRadius = MEDIKIT_GRENADE_RADIUS;

	// Supposed to friendly fire + no warning.
	Template.bFriendlyFire = true;
	Template.bFriendlyFireWarning = false;

	Template.Abilities.AddItem('ThrowGrenade');

	HealingEffect = CreateMedikitHealEffect(MEDIKIT_PERUSEHP);
	Template.ThrownGrenadeEffects.AddItem(HealingEffect);
	Template.LaunchedGrenadeEffects = Template.ThrownGrenadeEffects;
	
	Template.GameArchetype = "WP_Grenade_Flashbang.WP_Grenade_Flashbang";

	Template.CanBeBuilt = false;
	Template.RewardDecks.AddItem('ExperimentalGrenadeRewards');
	Template.UpgradeItem = 'MGGrenade_MedikitMK2';
	Template.HideIfResearched = 'AdvancedGrenades';

	Template.iSoundRange = MEDIKIT_GRENADE_ISOUNDRANGE;
	Template.iEnvironmentDamage = MEDIKIT_GRENADE_IENVIRONMENTDAMAGE;
	Template.TradingPostValue = 10;
	Template.PointsToComplete = MEDIKIT_GRENADE_IPOINTS;
	Template.iClipSize = MEDIKIT_GRENADE_ICLIPSIZE;
	Template.Tier = 1;


	// Soldier Bark
	Template.OnThrowBarkSoundCue = 'ThrowGrenade';

	Template.SetUIStatMarkup(class'XLocalizedData'.default.RangeLabel, , MEDIKIT_GRENADE_RANGE);
	Template.SetUIStatMarkup(class'XLocalizedData'.default.RadiusLabel, , MEDIKIT_GRENADE_RADIUS);

	return Template;
}

function X2ItemTemplate CreateGrenadeMK2()
{
	local X2GrenadeTemplate Template;
	local X2Effect_ApplyMedikitHeal HealingEffect;

	`CREATE_X2TEMPLATE(class'X2GrenadeTemplate', Template, 'MGGrenade_MedikitMK2');

	Template.strImage = "img:///UILibrary_StrategyImages.X2InventoryIcons.Inv_MedkitMK2";
	Template.EquipSound = "StrategyUI_Grenade_Equip";
	Template.AddAbilityIconOverride('ThrowGrenade', "img:///UILibrary_PerkIcons.UIPerk_grenade_flash");
	Template.AddAbilityIconOverride('LaunchGrenade', "img:///UILibrary_PerkIcons.UIPerk_grenade_flash");

	Template.iRange = MEDIKIT_GRENADE_RANGE;
	Template.iRadius = MEDIKIT_GRENADE_RADIUS;

	// Supposed to friendly fire + no warning.
	Template.bFriendlyFire = true;
	Template.bFriendlyFireWarning = false;

	Template.Abilities.AddItem('ThrowGrenade');

	HealingEffect = CreateMedikitHealEffect(NANOMEDIKIT_PERUSEHP);
	Template.ThrownGrenadeEffects.AddItem(HealingEffect);
	Template.LaunchedGrenadeEffects = Template.ThrownGrenadeEffects;
	
	Template.GameArchetype = "WP_Grenade_Flashbang.WP_Grenade_Flashbang";

	Template.CanBeBuilt = false;

	Template.iSoundRange = MEDIKIT_GRENADE_ISOUNDRANGE;
	Template.iEnvironmentDamage = MEDIKIT_GRENADE_IENVIRONMENTDAMAGE;
	Template.TradingPostValue = 10;
	Template.PointsToComplete = MEDIKIT_GRENADE_IPOINTS;
	Template.iClipSize = MEDIKIT_GRENADE_ICLIPSIZE;
	Template.Tier = 2;

	// Upgrade from mk1
	Template.CreatorTemplateName = 'AdvancedGrenades';
	Template.BaseItem = 'MGGrenade_Medikit';

	// Soldier Bark
	Template.OnThrowBarkSoundCue = 'ThrowGrenade';

	Template.SetUIStatMarkup(class'XLocalizedData'.default.RangeLabel, , MEDIKIT_GRENADE_RANGE);
	Template.SetUIStatMarkup(class'XLocalizedData'.default.RadiusLabel, , MEDIKIT_GRENADE_RADIUS);

	return Template;
}