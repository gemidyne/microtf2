#pragma semicolon 1
#define REQUIRE_PLUGIN

#include <sourcemod>
#include <sdktools>
#include <warioware>
#include <mapchooser>

#pragma newdecls required

public Plugin myinfo = 
{
	name = "Microgames in Team Fortress 2: SourceMod Mapchooser Integration",
	author = "gemidyne",
	description = "SourceMod Mapchooser Plugin integration",
	version = "1.0",
	url = "https://www.gemidyne.com/"
}

public void WarioWare_Intermission_StartMapVote()
{
	InitiateMapChooserVote(MapChange_MapEnd);
}

public bool WarioWare_Intermission_HasMapVoteEnded()
{
	return !IsVoteInProgress();
}