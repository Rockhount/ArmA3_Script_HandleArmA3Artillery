/*
	Made by Rockhount - HandleArmA3FakeArtillery Script v1.1 (SP/MP & HC compatible)
	Errors will be written into the rpt and starts with "HandleArmA3FakeArtillery Error:"
	Call:
	[[1,1,0], 100, "R_80mm_HE", 3, 10, 20, 1, 30] execVM "HandleArmA3FakeArtillery.sqf";
	[1,1,0] = Position, where to shoot at
	100 = Radius of the impact-area
	"R_80mm_HE" = Type of ammo to use
	3 = Count of rounds
	10 = Count of shots per round
	20 = Time between Rounds as seconds 
	1 = Time between Shots as seconds 
	30 = Dealy for the first shot
	-------------------------------------------------------------------------------------------------------------------------
	Gemacht von Rockhount - HandleArmA3FakeArtillery Skript v1.1 (SP/MP & HC Kompatibel)
	Fehler werden in die RPT geschrieben und starten mit "HandleArmA3FakeArtillery Error:"
	Aufruf:
	[[1,1,0], 100, "R_80mm_HE", 3, 10, 20, 1, 30] execVM "HandleArmA3FakeArtillery.sqf";
	[1,1,0] = Position, auf die geschossen werden soll
	100 = Streuradius der Einschläge
	"R_80mm_HE" = Klassenname der Munition, die verwendet werden soll
	3 = Anzahl der Schussrunden
	10 = Anzahl der Schüsse pro Runde
	20 = Zeit zwischen den Runden als Sekunden
	1 = Zeit zwischen den Schüssen als Sekunden
	30 = Verzögerung bis zum ersten Schuss
*/

if (isServer) then
{
	private _Local_var_Exit = false;
	private _Local_var_ArtiTargetPos = if ((count _this > 0) && {typeName (_this select 0) == "ARRAY"}) then {_this select 0} else {_Local_var_Exit = true};
	private _Local_var_ArtiTargetRadius = if ((count _this > 1) && {typeName (_this select 1) == "SCALAR"}) then {_this select 1} else {_Local_var_Exit = true};
	private _Local_var_AmmoTypeToUse = if ((count _this > 2) && {typeName (_this select 2) == "STRING"}) then {_this select 2} else {_Local_var_Exit = true};
	private _Local_var_RoundCount = if ((count _this > 3) && {typeName (_this select 3) == "SCALAR"}) then {_this select 3} else {_Local_var_Exit = true};
	private _Local_var_ShotCount = if ((count _this > 4) && {typeName (_this select 4) == "SCALAR"}) then {_this select 4} else {_Local_var_Exit = true};
	private _Local_var_RoundSleepTime = if ((count _this > 5) && {typeName (_this select 5) == "SCALAR"}) then {_this select 5} else {_Local_var_Exit = true};
	private _Local_var_ShotSleepTime = if ((count _this > 6) && {typeName (_this select 6) == "SCALAR"}) then {_this select 6} else {_Local_var_Exit = true};
	private _Local_var_StartSleepTime = if ((count _this > 7) && {typeName (_this select 7) == "SCALAR"}) then {_this select 7} else {_Local_var_Exit = true};
	//Error handling
	if (_Local_var_Exit) exitWith
	{
		diag_log "HandleArmA3FakeArtillery Error: Wrong parameters";
	};
	if (!canSuspend) exitWith 
	{
		diag_log "HandleArmA3FakeArtillery Error: This script does not work in an unscheduled environment";
	};
	sleep _Local_var_StartSleepTime;
	//Shooting
	Private ["_Local_var_CurPos"];
	for "_i1" from 1 to _Local_var_RoundCount do
	{
		for "_i2" from 1 to _Local_var_ShotCount do
		{
			_Local_var_CurPos = _Local_var_ArtiTargetPos getPos [random _Local_var_ArtiTargetRadius, random 360];
			playSound3D [([(str missionConfigFile), 0, -15] call BIS_fnc_trimString) + "Sounds\incoming.ogg", objNull, false, ATLToASL _Local_var_CurPos, 3, 1, 150];
			sleep 1.5;
			_Local_var_AmmoTypeToUse createVehicle _Local_var_CurPos;
			sleep _Local_var_ShotSleepTime;
		};
		sleep _Local_var_RoundSleepTime;
	};
};