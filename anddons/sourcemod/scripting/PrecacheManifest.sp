#define PRECACHEMANFIEST_URL "https://raw.githubusercontent.com/gemidyne/microtf2-precache/master/PrecacheList.txt"

stock void WebAPI_DownloadPrecacheManifest()
{
	HTTPRequestHandle hRequest = Steam_CreateHTTPRequest(HTTPMethod_GET, PRECACHEMANFIEST_URL);
	Steam_SetHTTPRequestHeaderValue(hRequest, "Pragma", "no-cache");
	Steam_SetHTTPRequestHeaderValue(hRequest, "Cache-Control", "no-cache");
	Steam_SetHTTPRequestNetworkActivityTimeout(hRequest, 60); // IWA might be updating / recompiling. Allow 60 seconds leanway - otherwise the IWA is very quick.
	Steam_SendHTTPRequest(hRequest, PrecacheManifest_OnHttpRequestComplete);
}

public int PrecacheManifest_OnHttpRequestComplete(HTTPRequestHandle HTTPRequest, bool requestSuccessful, HTTPStatusCode statusCode, int contextData)
{
	if (requestSuccessful && statusCode == HTTPStatusCode_OK)
	{
		char manifestPath[128];
		BuildPath(Path_SM, manifestPath, sizeof(manifestPath), "data/microtf2/PrecacheList.txt");
		Steam_WriteHTTPResponseBody(HTTPRequest, manifestPath);

		LogMessage("Successfully downloaded new gamedata \"data/microtf2/PrecacheList.txt\".");
	}
	else
	{
		char sError[256];
		FormatEx(sError, sizeof(sError), "Failed to download new gamedata from update server. (status code %i, url: %s)", view_as<int>(statusCode), PRECACHEMANFIEST_URL);
		LogError(sError);
	}

	Steam_ReleaseHTTPRequest(HTTPRequest);
}