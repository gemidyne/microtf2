stock WebAPI_AddPointsForPlayer(client, points)
{
	decl String:path[128];
	decl String:steamID[32];

	GetClientAuthId(client, AuthId_Steam2, steamID, sizeof(steamID));
	Format(path, sizeof(path), "%s/MTF2/AddPoints.aspx?steamid=%s&points=%d", IWA_URL, steamID, points);

	new HTTPRequestHandle:hRequest = Steam_CreateHTTPRequest(HTTPMethod_GET, path);
	Steam_SetHTTPRequestHeaderValue(hRequest, "Pragma", "no-cache");
	Steam_SetHTTPRequestHeaderValue(hRequest, "Cache-Control", "no-cache");
	Steam_SetHTTPRequestNetworkActivityTimeout(hRequest, 60); // IWA might be updating / recompiling. Allow 60 seconds leanway - otherwise the IWA is very quick.
	Steam_SendHTTPRequest(hRequest, PlayerScores_OnHttpRequestComplete);

	CPrintToChat(client, "%sYou have been awarded %d$ for playing.", IWA_MSGPREFIX, points);
}

public PlayerScores_OnHttpRequestComplete(HTTPRequestHandle:HTTPRequest, bool:requestSuccessful, HTTPStatusCode:statusCode)
{
	if (requestSuccessful && statusCode == HTTPStatusCode_OK)
	{
		// This is really fire and forget. If HTTP 200, all went well.
	}
	else
	{
		decl String:sError[256];
		FormatEx(sError, sizeof(sError), "SteamTools error (status code %i) on adding points. Request successful: %s", _:statusCode, requestSuccessful ? "True" : "False");
		LogError(sError);
	}

	Steam_ReleaseHTTPRequest(HTTPRequest);
}