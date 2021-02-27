#include <amxmodx>
#define MEMBER_UNSAFE
#include <reapi>
#include <cwapi>

#pragma semicolon 1

new const _STR_NUM[] = "%d";
#define IntToStr(%1) fmt(_STR_NUM,%1)

#define RgAddUserHealthM(%1,%2,%3) (%3==0)?RgAddUserHealth(%1,%2):set_entvar(%1,var_health,float(clamp(floatround(get_entvar(%1,var_health))+%2,1,%3)))
#define RgAddUserHealth(%1,%2) set_entvar(%1,var_health,float(max(floatround(get_entvar(%1,var_health))+%2,1)))

new ArmorType:_ARMOR_TYPE = ARMOR_NONE;
#define RgAddUserArmorM(%1,%2,%3,%4) (%4==0)?RgAddUserArmor(%1,%2,%3):rg_set_user_armor(%1,clamp(rg_get_user_armor(%1,_ARMOR_TYPE)+%2,0,%4),(_ARMOR_TYPE>%3)?_ARMOR_TYPE:%3)
#define RgAddUserArmor(%1,%2,%3) rg_set_user_armor(%1,max(rg_get_user_armor(%1,_ARMOR_TYPE)+%2,0),(_ARMOR_TYPE>%3)?_ARMOR_TYPE:%3)

new const ABIL_NAME[] = "Regen";

new const ABIL_PARAM_DELAY[] = "Delay";
const Float:ABIL_DEFAULT_DELAY = 1.0;

new const ABIL_PARAM_HP_VAL[] = "Health";
const ABIL_DEFAULT_HP_VAL = 1;

new const ABIL_PARAM_HP_MAX[] = "HealthMax";
const ABIL_DEFAULT_HP_MAX = 100;

new const ABIL_PARAM_AP_VAL[] = "Armor";
const ABIL_DEFAULT_AP_VAL = 3;

new const ABIL_PARAM_AP_MAX[] = "ArmorMax";
const ABIL_DEFAULT_AP_MAX = 100;

new const ABIL_PARAM_AP_HELM[] = "ArmorHelm";
const bool:ABIL_DEFAULT_AP_HELM = true;

enum _:E_AbilParams{
    Float:AP_Delay,
    AP_Health,
    AP_HealthMax,
    AP_Armor,
    AP_ArmorMax,
    ArmorType:AP_ArmorHelm,
}
new Trie:Params; // ["WeaponId"] => [E_AbilParams]
#define GetWeaponAbil(%1,%2) TrieGetArray(Params,IntToStr(CWAPI_GetWeaponIdFromEnt(%1)),%2,E_AbilParams)

new const PLUG_NAME[] = "[CWAPI][Ability] Regeneration";
new const PLUG_VER[] = "2.0.0";

public CWAPI_LoadWeaponsPost(){
    register_plugin(PLUG_NAME, PLUG_VER, "ArKaNeMaN");

    if(!CWAPI_CheckVersionV1(0.7.0))
        set_fail_state("[ERROR] Required CWAPI v0.7.0 or above.");

    Params = TrieCreate();

    new Array:WeaponsList = CWAPI_GetAbilityWeaponsList(ABIL_NAME);
    new WeaponAbilityData[CWAPI_WeaponAbilityData];
    for(new i = 0; i < ArraySize(WeaponsList); i++){
        ArrayGetArray(WeaponsList, i, WeaponAbilityData);

        CWAPI_RegisterHook(WeaponAbilityData[CWAPI_WAD_WeaponName], CWAPI_WE_Deploy, "Hook_CWAPI_Deploy");
        CWAPI_RegisterHook(WeaponAbilityData[CWAPI_WAD_WeaponName], CWAPI_WE_Holster, "Hook_CWAPI_Holster");

        #define _GetAbilParam(%1,%2) CWAPI_GetAbilParam%2(WeaponAbilityData[CWAPI_WAD_CustomData],ABIL_PARAM_%1,ABIL_DEFAULT_%1)
        new AbilParams[E_AbilParams];
        AbilParams[AP_Delay] = _GetAbilParam(DELAY,Float);
        AbilParams[AP_Health] = _GetAbilParam(HP_VAL,Int);
        AbilParams[AP_HealthMax] = _GetAbilParam(HP_MAX,Int);
        AbilParams[AP_Armor] = _GetAbilParam(AP_VAL,Int);
        AbilParams[AP_ArmorMax] = _GetAbilParam(AP_MAX,Int);
        AbilParams[AP_ArmorHelm] = _GetAbilParam(AP_HELM,Bool) ? ARMOR_VESTHELM : ARMOR_KEVLAR;
        TrieSetArray(Params, IntToStr(CWAPI_GetWeaponId(WeaponAbilityData[CWAPI_WAD_WeaponName])), AbilParams, E_AbilParams);
    }

    server_print("[%s v%s] loaded.", PLUG_NAME, PLUG_VER);
}

public Hook_CWAPI_Deploy(const ItemId){
    new AbilParams[E_AbilParams];
    GetWeaponAbil(ItemId, AbilParams);

    set_task(AbilParams[AP_Delay], "Task_Regen", ItemId, _, _, "b");
}

public Hook_CWAPI_Holster(const ItemId){
    if(task_exists(ItemId))
        remove_task(ItemId);
}

public Task_Regen(const ItemId){
    if(is_entity(ItemId))
        return remove_task(ItemId);

    static UserId;
    UserId = get_member(ItemId, m_pPlayer);

    if(
        !is_user_alive(UserId)
        || get_member(UserId, m_pActiveItem) != ItemId
    ) return remove_task(ItemId);

    new AbilParams[E_AbilParams];
    GetWeaponAbil(ItemId, AbilParams);

    if(AbilParams[AP_Health])
        RgAddUserHealthM(UserId, AbilParams[AP_Health], AbilParams[AP_HealthMax]);

    if(AbilParams[AP_Armor])
        RgAddUserArmorM(UserId, AbilParams[AP_Armor], AbilParams[AP_ArmorHelm], AbilParams[AP_ArmorMax]);

    return 0;
}