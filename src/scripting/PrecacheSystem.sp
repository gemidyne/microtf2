/**
 * MicroTF2 - PrecacheSystem.inc
 * 
 * Precache System aims to lessen the lag of models loading on the server. Thanks, Valve.
 */

stock void InitialisePrecacheSystem()
{
	#if defined LOGGING_STARTUP
	LogMessage("Initializing Precache System...");
	#endif
	
	AddToForward(GlobalForward_OnMapStart, INVALID_HANDLE, PrecacheSystem_OnMapStart);
}

public void PrecacheSystem_OnMapStart()
{
	PrecacheAllModelsInManifest();
	PrecacheViewModels();
}

stock void PrecacheAllModelsInManifest()
{
	char manifestPath[128];
	BuildPath(Path_SM, manifestPath, sizeof(manifestPath), "data/microtf2/PrecacheList.txt");

	LogMessage("Precaching all models specified in precache list...");
	Handle file = OpenFile(manifestPath, "r"); // Only need r for read

	if (file == INVALID_HANDLE)
	{
		LogError("Failed to open precachelist.txt in data/microtf2! Lagspikes may occur during the game.");
		return;
	}

	char line[512];

	while (ReadFileLine(file, line, sizeof(line)))
	{
		TrimString(line);

		if (strlen(line) == 0)
		{
			continue;
		}

		PrecacheModel(line, true);
	}

	CloseHandle(file);

	// We need to download any updates afterwards sadly. Downloading the manifest on another thread doesn't block OnMapStart,
	// so this can only really be done afterwards. But next time the gamemode runs, it'll precache up-to-date models!
	WebAPI_DownloadPrecacheManifest();
}

stock void PrecacheViewModels()
{
	PrecacheModel("models/weapons/c_models/c_demo_arms.mdl", true);
	PrecacheModel("models/weapons/c_models/c_engineer_arms.mdl", true);
	PrecacheModel("models/weapons/c_models/c_heavy_arms.mdl", true);
	PrecacheModel("models/weapons/c_models/c_medic_arms.mdl", true);
	PrecacheModel("models/weapons/c_models/c_pyro_arms.mdl", true);
	PrecacheModel("models/weapons/c_models/c_scout_arms.mdl", true);
	PrecacheModel("models/weapons/c_models/c_sniper_arms.mdl", true);
	PrecacheModel("models/weapons/c_models/c_spy_arms.mdl", true);
}