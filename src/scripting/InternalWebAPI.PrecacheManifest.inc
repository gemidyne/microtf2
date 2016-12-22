stock WebAPI_DownloadPrecacheManifest()
{
	decl String:path[128];
	Format(path, sizeof(path), "%s/MTF2/PrecacheList.txt", IWA_URL);

	new HTTPRequestHandle:hRequest = Steam_CreateHTTPRequest(HTTPMethod_GET, path);
	Steam_SetHTTPRequestHeaderValue(hRequest, "Pragma", "no-cache");
	Steam_SetHTTPRequestHeaderValue(hRequest, "Cache-Control", "no-cache");
	Steam_SetHTTPRequestNetworkActivityTimeout(hRequest, 60); // IWA might be updating / recompiling. Allow 60 seconds leanway - otherwise the IWA is very quick.
	Steam_SendHTTPRequest(hRequest, PrecacheManifest_OnHttpRequestComplete);
}

public PrecacheManifest_OnHttpRequestComplete(HTTPRequestHandle:HTTPRequest, bool:requestSuccessful, HTTPStatusCode:statusCode)
{
	if (requestSuccessful && statusCode == HTTPStatusCode_OK)
	{
		decl String:manifestPath[128];
		BuildPath(Path_SM, manifestPath, sizeof(manifestPath), "data/microtf2/PrecacheList.txt");
		Steam_WriteHTTPResponseBody(HTTPRequest, manifestPath);

		LogMessage("Successfully downloaded new gamedata \"data/microtf2/PrecacheList.txt\".");
	}
	else
	{
		decl String:sError[256];
		FormatEx(sError, sizeof(sError), "Failed to download new gamedata from update server. (status code %i) Request successful: %s", _:statusCode, requestSuccessful ? "True" : "False");
		LogError(sError);
	}

	Steam_ReleaseHTTPRequest(HTTPRequest);
}