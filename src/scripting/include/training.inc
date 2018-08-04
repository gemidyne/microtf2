#include <sdktools>
#include <sendproxy>

new Handle:TimerHUD;

/* Creates Annontation on specific location */
stock CreateTag(id, Float:x, Float:y, Float:z, Float:lifetime, String:message[])
{
	new Handle:event = CreateEvent("show_annotation");
	if(event == INVALID_HANDLE) return;
	SetEventInt(event, "worldPosX", x);
	SetEventInt(event, "worldPosY", y);
	SetEventInt(event, "worldPosZ", z);
	SetEventInt(event, "id", id);
	SetEventFloat(event, "lifetime", lifetime);
	SetEventString(event, "text", message);
	FireEvent(event);
}

/* Creates Annontation on entity */
stock CreateTagOnEntity(entity, Float:lifetime, String:message[], bool:filter)
{
	new Handle:event = CreateEvent("show_annotation");
	if(event == INVALID_HANDLE) return;
	SetEventInt(event, "follow_entindex", entity);
	SetEventInt(event, "id", entity);
	SetEventFloat(event, "lifetime", lifetime);
	SetEventString(event, "text", message);
	if (filter)
	{
		SetEventInt(event, "visibilityBitfield", DoFilter(entity));
	}
	FireEvent(event);
}

/* Sends Training Mode Hud Message */
stock TrainingMessage(String:objective[], String:message[], Float:duration=0.0)
{
	new entity = FindEntityByClassname(-1, "tf_gamerules");
	if (IsValidHandle(TimerHUD))
		KillTimer(TimerHUD);
	
	SendProxy_Unhook(entity, "m_bIsInTraining", SendProxy_CallbackTrue);
	SendProxy_Unhook(entity, "m_bIsTrainingHUDVisible", SendProxy_CallbackTrue);
	SetEntProp(entity, Prop_Send, "m_bIsInTraining", 0);
	SetEntProp(entity, Prop_Send, "m_bIsTrainingHUDVisible", 0);
	
	SendProxy_Hook(entity, "m_bIsInTraining", Prop_Int, SendProxy_CallbackTrue);
	SendProxy_Hook(entity, "m_bIsTrainingHUDVisible", Prop_Int, SendProxy_CallbackTrue);
	
	new Handle:MessageObj = StartMessageAll("TrainingObjective");
	if (MessageObj != INVALID_HANDLE)
	{
		BfWriteString(MessageObj, objective); //Message
		EndMessage();
	}
	
	new Handle:Message = StartMessageAll("TrainingMsg");
	if (Message != INVALID_HANDLE)
	{
		BfWriteString(Message, message); //Message
		EndMessage();
	}
	
	if (duration > 0.0)
	{
		TimerHUD = CreateTimer(duration, ClearHud, entity);
	}
}

stock TrainingMessageToClient(client, String:objective[], String:message[], Float:duration=0.0)
{
	new entity = FindEntityByClassname(-1, "tf_gamerules");
	if (IsValidHandle(TimerHUD))
		KillTimer(TimerHUD);
	
	SendProxy_Unhook(entity, "m_bIsInTraining", SendProxy_CallbackTrue);
	SendProxy_Unhook(entity, "m_bIsTrainingHUDVisible", SendProxy_CallbackTrue);
	SetEntProp(entity, Prop_Send, "m_bIsInTraining", 0);
	SetEntProp(entity, Prop_Send, "m_bIsTrainingHUDVisible", 0);
	
	SendProxy_Hook(entity, "m_bIsInTraining", Prop_Int, SendProxy_CallbackTrue);
	SendProxy_Hook(entity, "m_bIsTrainingHUDVisible", Prop_Int, SendProxy_CallbackTrue);
	
	new Handle:MessageObj = StartMessageOne("TrainingObjective", client);
	if (MessageObj != INVALID_HANDLE)
	{
		BfWriteString(MessageObj, objective); //Message
		EndMessage();
	}
	
	new Handle:Message = StartMessageOne("TrainingMsg", client);
	if (Message != INVALID_HANDLE)
	{
		BfWriteString(Message, message); //Message
		EndMessage();
	}
	
	if (duration > 0.0)
	{
		TimerHUD = CreateTimer(duration, ClearHud, entity);
	}
}

/* Annontation Filters */

stock DoFilter(entity)
{
	new bits;
	for(new viewer = 1; viewer <= MaxClients; viewer++)
	{
		if(entity == viewer) continue;
		if(IsClientInGame(viewer) && IsPlayerAlive(viewer) && IsWithinRange(entity, viewer))
		{
			bits |= (1 << viewer);
		}
	}
	return bits;
}

stock bool:IsWithinRange(entity, viewer)
{
	decl Float:entitypos[3], Float:viewerpos[3];
	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", entitypos);
	GetClientAbsOrigin(viewer, viewerpos);
	return GetVectorDistance(entitypos, viewerpos) <= 500.0;
}  

/* Timers */

public Action:ClearHud(Handle:timer, any:entity)
{
	SendProxy_Unhook(entity, "m_bIsInTraining", SendProxy_CallbackTrue);
	SendProxy_Unhook(entity, "m_bIsTrainingHUDVisible", SendProxy_CallbackTrue);
	
	SetEntProp(entity, Prop_Send, "m_bIsInTraining", 0);
	SetEntProp(entity, Prop_Send, "m_bIsTrainingHUDVisible", 0);
}

/* SendProxy Callbacks */

public Action:SendProxy_CallbackTrue(entity, const String:propName[], &iValue, element)
{
	iValue = 1;
	return Plugin_Changed;
}