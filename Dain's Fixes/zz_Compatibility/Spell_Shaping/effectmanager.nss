#include "effects_h"
#include "ability_h"
#include "ss_dheu_constants_h"

const int TABLE_EFFECT_OVERRIDE = 700524475;
const int TABLE_EFFECT_MANAGER = 739227090;

int CheckCriterion(int nRow, string sCol, int nComparison) {
    int nVal = GetM2DAInt(TABLE_EFFECT_MANAGER, sCol, nRow);
    return nVal == -1 || nVal == nComparison;
}

int IsSpellShapingApplicable(int nEffectType, object oCreator) {
    return (nEffectType == EFFECT_TYPE_DAMAGE || IsEffectTypeHostile(nEffectType) || nEffectType == EFFECT_TYPE_PETRIFY || nEffectType == EFFECT_TYPE_SLIP) &&
        IsObjectValid(oCreator) && IsObjectValid(OBJECT_SELF) && !IsDead(oCreator) &&
        HasAbility(oCreator,SPELLSHAPING) && Ability_IsAbilityActive(oCreator, SPELLSHAPING) &&
        !IsObjectHostile(OBJECT_SELF, oCreator);
}

float GetCostMultiplier(object oCreator, int nDifficulty) {
    float fManacost;
    float fAdjust;
    switch (nDifficulty) {
        case GAME_DIFFICULTY_CASUAL: {
            return 0.0;
        }
        case GAME_DIFFICULTY_NORMAL: {
            fManacost = 0.15;
            fAdjust = 0.05;
            break;
        }
        case GAME_DIFFICULTY_HARD: {
            fManacost = 0.30;
            fAdjust = 0.05;
            break;
        }
        // nightmare, for which no constant is defined apparently
        default: {
            fManacost = 0.60;
            fAdjust = 0.10;
        }
    }

    int nRanks = HasAbility(oCreator,IMPROVED_SPELLSHAPING) + HasAbility(oCreator,EXPERT_SPELLSHAPING) + HasAbility(oCreator,MASTER_SPELLSHAPING);
    return fManacost - nRanks*fAdjust;
}

int HandleDamage(object oCreator, int nAbility, float fDamage) {
    if (nAbility == ABILITY_SPELL_BLOOD_SACRIFICE)
        return FALSE;

    int nDifficulty = GetGameDifficulty();
    if (nDifficulty == GAME_DIFFICULTY_CASUAL)
        return TRUE;

    float fCost = fDamage * GetCostMultiplier(oCreator, nDifficulty);
    //if (Ability_IsBloodMagic(oCreator)) {
    if (Ability_IsBloodMagic(oCreator)) {
        int nBloodMagicVFX = 1519;
        float fMultiplier = 0.8f;
        if (GetHasEffects(oCreator, EFFECT_TYPE_BLOOD_MAGIC_BONUS))
            fMultiplier = 0.6f;

        fCost = fCost* fMultiplier;

        // NO need to check health for nightmare mode if using blood magic
        // because they will die if they run out of health.

        // Effects_ApplyInstantEffectDamage expects positive value
        Effects_ApplyInstantEffectDamage(oCreator, oCreator, fCost, DAMAGE_TYPE_PLOT, DAMAGE_EFFECT_FLAG_UNRESISTABLE, nAbility, nBloodMagicVFX);
    } else {
        // For Nightmare, we stop damage protection when they run out of mana.
        if (nDifficulty > GAME_DIFFICULTY_HARD) {
            float fMana = GetCurrentManaStamina(oCreator);
            if (fMana < fCost)
                return FALSE;
        }

        Effect_InstantApplyEffectModifyManaStamina(oCreator, -1.0*fCost);
    }
    return TRUE;
}

int CheckSpellShaping(effect ef) {
    int nEffectType = GetEffectType(ef);
    object oCreator = GetEffectCreator(ef);
    if (IsSpellShapingApplicable(nEffectType, oCreator))
        return (nEffectType == EFFECT_TYPE_DAMAGE) ? HandleDamage(oCreator, GetEffectAbilityID(ef), GetEffectFloat(ef, 0)) : TRUE;

    return FALSE;
}


void main() {
    // Get event
    event ev = GetCurrentEvent();
    int nEventType = GetEventType(ev);

    // Get effect
    effect ef = GetCurrentEffect();
    int nEffectType = GetEffectType(ef);

    // Time to check spell shaping
    if (nEventType == 33 && CheckSpellShaping(ef)) {
        return;
    }

    // Prep override and listeners
    string sOverride = GetM2DAString(TABLE_EFFECT_OVERRIDE, "Script", nEffectType);
    string[] arListeners;
    int nListeners = 0;

    // Parse m2da
    int i, nRows = GetM2DARows(TABLE_EFFECT_MANAGER);
    for (i = 0; i < nRows; i++) {
        int nRow = GetM2DARowIdFromRowIndex(TABLE_EFFECT_MANAGER, i);
        if (CheckCriterion(nRow, "EffectType", nEffectType))
            if (CheckCriterion(nRow, "DurationType", GetEffectDurationType(ef)))
                if (CheckCriterion(nRow, "Event", nEventType))
                    if (CheckCriterion(nRow, "AbilityId", GetEffectAbilityID(ef))) {
                        int nMode = GetM2DAInt(TABLE_EFFECT_MANAGER, "Mode", nRow);
                        string sScript = GetM2DAString(TABLE_EFFECT_MANAGER, "Script", nRow);
                        if (nMode)
                            arListeners[nListeners++] = sScript;
                        else
                            sOverride = sScript;
                    }
    }

    // Execute override if present or else default functionality
    if (sOverride != "")
        HandleEvent_String(ev, sOverride);
    else if (nEventType == 33)
        Effects_HandleApplyEffect();
    else if (nEventType == 34)
        Effects_HandleRemoveEffect();

    // Handle listeners
    for (i = 0; i < nListeners; i++)
        HandleEvent_String(ev, arListeners[i]);
}