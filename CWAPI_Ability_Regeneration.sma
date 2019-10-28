#include <amxmodx>
#include <reapi>
#include <cwapi>

#pragma semicolon 1

// TODO: Перенести дефайны в параметры способности
#define REGEN_DELAY 0.5
#define REGEN_ADD_HEALTH 1
#define REGEN_MAX_HEALTH 100

new const PLUG_NAME[] = "[CWAPI][Ability] Regeneration";
new const PLUG_VER[] = "1.0.0";

public CWAPI_LoadWeaponsPost(){
    register_plugin(PLUG_NAME, PLUG_VER, "ArKaNeMaN");

    new Array:WeaponsList = CWAPI_GetAbilityWeaponsList("Regeneration");
    new WeaponAbilityData[CWAPI_WeaponAbilityData];
    for(new i = 0; i < ArraySize(WeaponsList); i++){
        ArrayGetArray(WeaponsList, i, WeaponAbilityData);

        CWAPI_RegisterHook(WeaponAbilityData[CWAPI_WAD_WeaponName], CWAPI_WE_Deploy, "Hook_CWAPI_Deploy");
        CWAPI_RegisterHook(WeaponAbilityData[CWAPI_WAD_WeaponName], CWAPI_WE_Holster, "Hook_CWAPI_Holster");
    }

    server_print("[%s v%s] loaded.", PLUG_NAME, PLUG_VER);
}

public Hook_CWAPI_Deploy(const ItemId){
    set_task(REGEN_DELAY, "Task_Regen", ItemId, "", 0, "b");
}

public Hook_CWAPI_Holster(const ItemId){
    if(task_exists(ItemId))
        remove_task(ItemId);
}

public Task_Regen(const ItemId){
    static UserId; UserId = get_member(ItemId, m_pPlayer);

    if(get_member(UserId, m_pActiveItem) != ItemId){
        remove_task(ItemId);
        return;
    }

    _rg_add_user_health(UserId, REGEN_ADD_HEALTH, REGEN_MAX_HEALTH);
}

Float:_rg_add_user_health(id, hp, _max = 99999){
	static Float:health; health = get_entvar(id, var_health, health);
	health = floatmin(float(_max), health+hp);
	set_entvar(id, var_health, health);
	return health;
}