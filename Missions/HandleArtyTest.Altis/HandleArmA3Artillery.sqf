/*
	Made by Rockhount - HandleArmA3Artillery Script v1.2 (SP/MP & HC compatible)
	Errors will be written into the rpt and starts with "HandleArmA3Artillery Error:"
	Call:
	[S1, [1,1,0], 100, "8Rnd_82mm_Mo_shells", 3, 10, 20, 1] execVM "HandleArmA3Artillery.sqf";
	S1 = Unit or vehicle, which will fire
	[1,1,0] = Position, where to shoot at
	100 = Radius of the impact-area
	"8Rnd_82mm_Mo_shells" = Type of ammo to use (use "auto" to let it be chosen automatically)
	3 = Count of rounds
	10 = Count of shots per round
	20 = Time between Rounds as seconds 
	1 = Time between Shots as seconds
	-------------------------------------------------------------------------------------------------------------------------
	Gemacht von Rockhount - HandleArmA3Artillery Skript v1.2 (SP/MP & HC Kompatibel)
	Fehler werden in die RPT geschrieben und starten mit "HandleArmA3Artillery Error:"
	Aufruf:
	[S1, [1,1,0], 100, "8Rnd_82mm_Mo_shells", 3, 10, 20, 1] execVM "HandleArmA3Artillery.sqf";
	S1 = Schütze oder Fahrzeug, das feuern soll
	[1,1,0] = Position, auf die geschossen werden soll
	100 = Streuradius der Einschläge
	"8Rnd_82mm_Mo_shells" = Klassenname der Munition, die verwendet werden soll (verwende "auto", um den Klassennamen automatiscch auswählen zu lassen)
	3 = Anzahl der Schussrunden
	10 = Anzahl der Schüsse pro Runde
	20 = Zeit zwischen den Runden als Sekunden
	1 = Zeit zwischen den Schüssen als Sekunden
*/

if (isServer) then
{
	private _Local_fnc_GetMagCount =
	{
		private _Local_var_ArtiObjectAllMagazines = magazinesAmmo (_this select 0);
		private _Local_var_ArtiObjectRightMagazineCount = 0;
		private _Local_var_AmmoTypeToUse = _this select 1;
		{
			if (_x select 0 == _Local_var_AmmoTypeToUse) then
			{
				_Local_var_ArtiObjectRightMagazineCount = _Local_var_ArtiObjectRightMagazineCount + (_x select 1);
			};
		} forEach _Local_var_ArtiObjectAllMagazines;
		_Local_var_ArtiObjectRightMagazineCount
	};
	private _Local_var_Exit = false;
	private _Local_var_ArtiObject = if ((!isNil "_this") && {typeName (_this select 0) == "OBJECT"}) then {_this select 0} else {_Local_var_Exit = true;false};
	private _Local_var_ArtiTargetPos = if ((count _this > 1) && {typeName (_this select 1) == "ARRAY"}) then {_this select 1} else {_Local_var_Exit = true;false};
	private _Local_var_ArtiTargetRadius = if ((count _this > 2) && {typeName (_this select 2) == "SCALAR"}) then {_this select 2} else {_Local_var_Exit = true;false};
	private _Local_var_AmmoTypeToUse = if ((count _this > 3) && {typeName (_this select 3) == "STRING"}) then {_this select 3} else {_Local_var_Exit = true;false};
	private _Local_var_RoundCount = if ((count _this > 4) && {typeName (_this select 4) == "SCALAR"}) then {_this select 4} else {_Local_var_Exit = true;false};
	private _Local_var_ShotCount = if ((count _this > 5) && {typeName (_this select 5) == "SCALAR"}) then {_this select 5} else {_Local_var_Exit = true;false};
	private _Local_var_RoundSleepTime = if ((count _this > 6) && {typeName (_this select 6) == "SCALAR"}) then {_this select 6} else {_Local_var_Exit = true;false};
	private _Local_var_ShotSleepTime = if ((count _this > 7) && {typeName (_this select 7) == "SCALAR"}) then {_this select 7} else {_Local_var_Exit = true;false};
	//Error handling
	if (_Local_var_Exit) exitWith
	{
		diag_log "HandleArmA3Artillery Error: Wrong parameters";
	};
	if (_Local_var_ArtiObject isKindOf "Man") then
	{
		if (vehicle _Local_var_ArtiObject == _Local_var_ArtiObject) exitWith
		{
			diag_log format["HandleArmA3Artillery Error: %1 is not in an artillery vehicle", str _Local_var_ArtiObject];
		};
		if (isNil {gunner vehicle _Local_var_ArtiObject}) exitWith
		{
			diag_log format["HandleArmA3Artillery Error: %1 does not have a gunner", str vehicle _Local_var_ArtiObject];
		};
		_Local_var_ArtiObject = vehicle _Local_var_ArtiObject;
	};
	if (_Local_var_AmmoTypeToUse == "auto") then
	{
		if (count (getArtilleryAmmo [_Local_var_ArtiObject]) < 1) exitWith
		{
			diag_log format["HandleArmA3Artillery Error: %1 does not have any artillery ammo", str _Local_var_ArtiObject];
		};
		_Local_var_AmmoTypeToUse = (getArtilleryAmmo [_Local_var_ArtiObject]) select 0;
	}
	else 
	{
		if(!(_Local_var_AmmoTypeToUse in getArtilleryAmmo [_Local_var_ArtiObject])) exitWith
		{
			diag_log format["HandleArmA3Artillery Error: %1 does not have the right ammo %2", str _Local_var_ArtiObject, _Local_var_AmmoTypeToUse];
		};
	};
	while {([_Local_var_ArtiObject, _Local_var_AmmoTypeToUse] call _Local_fnc_GetMagCount) < _Local_var_RoundCount * _Local_var_ShotCount} do
	{
		[_Local_var_ArtiObject, _Local_var_AmmoTypeToUse] remoteExec ["addMagazine", _Local_var_ArtiObject, false];
	};
	if (!((_Local_var_ArtiObject getRelPos [(_Local_var_ArtiTargetPos distance _Local_var_ArtiObject) + _Local_var_ArtiTargetRadius, _Local_var_ArtiObject getRelDir _Local_var_ArtiTargetPos]) inRangeOfArtillery [[_Local_var_ArtiObject], _Local_var_AmmoTypeToUse])) exitWith
	{
		diag_log format["HandleArmA3Artillery Error: Unit %1 is not close enough", str _Local_var_ArtiObject];
	};
	//Shooting
	for "_i1" from 1 to _Local_var_RoundCount do
	{
		for "_i2" from 1 to _Local_var_ShotCount do
		{
			private _Local_var_LastMagCount = [_Local_var_ArtiObject, _Local_var_AmmoTypeToUse] call _Local_fnc_GetMagCount;
			[_Local_var_ArtiObject, [_Local_var_ArtiTargetPos getPos [random _Local_var_ArtiTargetRadius, random 360], _Local_var_AmmoTypeToUse, 1]] remoteExec ["doArtilleryFire", _Local_var_ArtiObject, false];
			waitUntil{sleep 1; ([_Local_var_ArtiObject, _Local_var_AmmoTypeToUse] call _Local_fnc_GetMagCount) < _Local_var_LastMagCount};
			sleep _Local_var_ShotSleepTime;
		};
		sleep _Local_var_RoundSleepTime;
	};
};