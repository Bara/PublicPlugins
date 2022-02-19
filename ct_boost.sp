#pragma semicolon 1
#pragma newdecls optional

#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <autoexecconfig>

enum struct ConVars
{
    ConVar EnableCTBoost;
    ConVar EnableHealth;
    ConVar EnableHealthMulti;
    ConVar EnableArmor;
    ConVar ArmorTeams;
    ConVar ArmorValue;
    ConVar EnableHelm;
    ConVar HelmTeams;
}
ConVars Core;

public Plugin myinfo =
{
    name = "CT Boost", 
    author = "Bara", 
    description = "", 
    version = "1.0", 
    url = "github.com/Bara"
};

public void OnPluginStart()
{
    AutoExecConfig_SetCreateDirectory(true);
    AutoExecConfig_SetCreateFile(true);
    AutoExecConfig_SetFile("ct_boost");
    Core.EnableCTBoost = AutoExecConfig_CreateConVar("ct_boost_enable", "1", "Enable CT Boost?", _, true, 0.0, true, 1.0);
    Core.EnableHealth = AutoExecConfig_CreateConVar("ct_boost_enable_health", "1", "Enable Health CT Boost?", _, true, 0.0, true, 1.0);
    Core.EnableHealthMulti = AutoExecConfig_CreateConVar("ct_boost_health_multi", "10.2842", "Multiplicator for CT Boost Health");
    Core.EnableArmor = AutoExecConfig_CreateConVar("ct_boost_enable_armor", "1", "Enable Armor CT Boost?", _, true, 0.0, true, 1.0);
    Core.ArmorTeams = AutoExecConfig_CreateConVar("ct_boost_armor_teams", "0", "Enable armor for CT at a specific team balance (T/CT). 0 - Disabled, ct_boost_enable_armor doesn't need to be enabled", _, true, 0.0);
    Core.ArmorValue = AutoExecConfig_CreateConVar("ct_boost_armor_value", "110", "How much armor should be added(!)?");
    Core.EnableHelm = AutoExecConfig_CreateConVar("ct_boost_enable_helm", "1", "Enable Helm CT Boost?", _, true, 0.0, true, 1.0);
    Core.HelmTeams = AutoExecConfig_CreateConVar("ct_boost_enable_armor", "0", "Enable helm for CT at a specific team balance (T/CT). 0 - Disabled, ct_boost_enable_helm doesn't need to be enabled", _, true, 0.0);
    AutoExecConfig_ExecuteFile();
    AutoExecConfig_CleanFile();

    HookEvent("player_spawn", Event_PlayerSpawn);
}

public Action Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    
    if (!client)
    {
        return;
    }
    
    if (!Core.EnableCTBoost.BoolValue)
    {
        return;
    }

    if (IsPlayerAlive(client) && GetClientTeam(client) == CS_TEAM_CT)
    {
        int iT = GetTeamClientCount(CS_TEAM_T);
        int iCT = GetTeamClientCount(CS_TEAM_CT);
        
        // Health
        if (Core.EnableHealth.BoolValue)
        {
            int iHP = RoundToCeil(iT / iCT * Core.EnableHealthMulti.FloatValue);
            int iNewHP = GetClientHealth(client) + iHP;
            SetEntityHealth(client, iNewHP);
            SetEntProp(client, Prop_Data, "m_iMaxHealth", iNewHP);
        }
        
        
        // Armor
        if (Core.EnableArmor.BoolValue || (iT / iCT > Core.ArmorTeams.FloatValue))
        {
            SetEntProp(client, Prop_Send, "m_ArmorValue", GetEntProp(client, Prop_Send, "m_ArmorValue") + Core.ArmorValue.IntValue);
        }

        // Helm
        if (Core.EnableHelm.BoolValue || (iT / iCT > Core.HelmTeams.FloatValue))
        {
            SetEntProp(client, Prop_Send, "m_bHasHelmet", 1);
        }
    }
}
