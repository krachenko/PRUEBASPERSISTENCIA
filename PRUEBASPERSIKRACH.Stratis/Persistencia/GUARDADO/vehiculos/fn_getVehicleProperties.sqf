// ******************************************************************************************
// * This project is licensed under the GNU Affero GPL v3. Copyright © 2014 A3Wasteland.com *
// ******************************************************************************************
//	@file Name: fn_getVehicleProperties.sqf
//	@file Author: AgentRev

private ["_veh", "_flying", "_class","_pos", "_dir", "_vel", "_fuel", "_damage", "_hitPoints", "_variables", "_doubleBSlash", "_tex", "_texArr", "_weapons", "_magazines", "_items", "_backpacks", "_turretMags", "_turretMags2", "_turretMags3", "_hasDoorGuns", "_turrets", "_path", "_ammoCargo", "_fuelCargo", "_repairCargo", "_props","_nombre","_initveh"];

_veh = _this select 0;
_nombre = _this select 1;
_flying = if (count _this > 1) then { _this select 1 } else { false };
_class = typeOf _veh;
_pos = ASLtoATL getPosWorld _veh;
{ _pos set [_forEachIndex, _x call fn_numToStr] } forEach _pos;
_dir = [vectorDir _veh, vectorUp _veh];
_vel = velocity _veh;
_fuel = fuel _veh;
_damage = damage _veh;
_hitPoints = [];
_initveh = "n";
if !(isNil {_veh getVariable ["iniciacion", ""]}) then {_initveh = _veh getVariable ["iniciacion", ""]};
{
	_hitPoint = configName _x;
	_hitPoints set [count _hitPoints, [_hitPoint, _veh getHitPointDamage _hitPoint]];
} forEach (_class call getHitPoints);

_variables = [];
_weapons = [];
_magazines = [];
_items = [];
_backpacks = [];
_backpackscontenido = [];
_mochilamagazine = [];
_mochilaitem = [];
_mochilaweapon = [];

if (_class call fn_hasInventory) then
{
	_weapons = (getWeaponCargo _veh) call cargoToPairs;
	_magazines = _veh call fn_magazineAmmoCargo;
	_items = (getItemCargo _veh) call cargoToPairs;
	_backpacks = (getBackpackCargo _veh) call cargoToPairs;      
	_vehicleBackpacks = everyBackpack _veh;
	{
_classname = typeOf _x;
_mochilamagazine = getMagazineCargo _x;
_mochilaitem = getitemCargo _x;
_mochilaweapon = getweaponCargo _x;
if ((count (_mochilamagazine select 0) == 0) and (count (_mochilaitem select 0) == 0) and (count (_mochilaweapon select 0) == 0) ) then {  
 }
else {if (count _backpackscontenido == 0) then { _backpackscontenido = [_classname] + [_mochilaweapon] + [_mochilaitem] + [_mochilamagazine];} else {_backpackscontenido = [_backpackscontenido] + [_classname] + [_mochilaweapon] + [_mochilaitem] + [_mochilamagazine];
};} ;
} forEach _vehicleBackpacks;
};

_turretMags = magazinesAmmo _veh;
_turretMags2 = [];
_turretMags3 = [];
_hasDoorGuns = isClass (configFile >> "CfgVehicles" >> _class >> "Turrets" >> "RightDoorGun");

_turrets = allTurrets [_veh, false];

if !(_class isKindOf "B_Heli_Transport_03_unarmed_F") then
{
	_turrets = [[-1]] + _turrets; // only add driver turret if not unarmed Huron, otherwise flares get saved twice
};

if (_hasDoorGuns) then
{
	// remove left door turret, because its mags are already returned by magazinesAmmo
	{
		if (_x isEqualTo [1]) exitWith
		{
			_turrets set [_forEachIndex, 1];
		};
	} forEach _turrets;

	_turrets = _turrets - [1];
};

{
	_path = _x;

	{
		if ([_turretMags, _x, -1] call fn_getFromPairs == -1 || _hasDoorGuns) then
		{
			if (_veh currentMagazineTurret _path == _x && {count _turretMags3 == 0}) then
			{
				_turretMags3 pushBack [_x, _path, [_veh currentMagazineDetailTurret _path] call getMagazineDetailAmmo];
			}
			else
			{
				_turretMags2 pushBack [_x, _path];
			};
		};
	} forEach (_veh magazinesTurret _path);
} forEach _turrets;

_ammoCargo = getAmmoCargo _veh;
_fuelCargo = getFuelCargo _veh;
_repairCargo = getRepairCargo _veh;

// Fix for -1.#IND
if (isNil "_ammoCargo" || {!finite _ammoCargo}) then { _ammoCargo = 0 };
if (isNil "_fuelCargo" || {!finite _fuelCargo}) then { _fuelCargo = 0 };
if (isNil "_repairCargo" || {!finite _repairCargo}) then { _repairCargo = 0 };

_props =
[
	["Class", _class],
	["Nombre", _nombre],
	["Position", _pos],
	["Direction", _dir],
	["Velocity", _vel],
	["Fuel", _fuel],
	["Damage", _damage],
	["HitPoints", _hitPoints],
	["Weapons", _weapons],
	["Magazines", _magazines],
	["Items", _items],
	["Backpacks", _backpacks],
	["BackpacksContenido", _backpackscontenido],
    ["TurretMagazines", _turretMags],
	["TurretMagazines2", _turretMags2],
	["TurretMagazines3", _turretMags3],

	["AmmoCargo", _ammoCargo],
	["FuelCargo", _fuelCargo],
	["RepairCargo", _repairCargo],
	["Init", _initveh]
];
_props
