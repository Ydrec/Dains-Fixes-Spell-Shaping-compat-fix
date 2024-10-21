
#include "events_h"
// #include "achievement_core_h"

// #include "approval_h"
// #include "ai_main_h_2"
// #include "tutorials_h"
// #include "placeable_h"

// #include "ability_h"
// #include "log_h"
// #include "utility_h"
// #include "wrappers_h"
// #include "world_maps_h"
// #include "sys_soundset_h"
// #include "plt_gen00pt_party"
// #include "plt_tut_combat_basic"
// #include "plt_tut_combat_basic_magic"
// #include "plt_tut_codex_item"
// #include "plt_tut_aicontrol"
// #include "plt_tut_areamap"
// #include "plt_tut_crafting"
// #include "plt_tut_journal"
// #include "plt_tut_store"
// #include "plt_tut_worldmap"
// #include "plt_tut_overload"
// #include "plt_tut_chanters_board"
// #include "plt_tut_item_upgrade"
// #include "stats_core_h"

#include "ss_dheu_constants_h"

void main()
{
    event ev   = GetCurrentEvent();
    int nEvent = GetEventType(ev);

    Log_Events("", ev);

    switch (nEvent)
    {
        ////////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: The module starts. This can happen only once for a single
        //       game instance.
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_MODULE_START:
        {
            PrintToLog("Spell Shaping : EVENT_TYPE_MODULE_START");
            string appStr = GetM2DAString(TABLE_EVENTS, "Script", EVENT_TYPE_APPLY_EFFECT);
            string ablStr = GetM2DAString(TABLE_EVENTS, "Script", EVENT_TYPE_ABILITY_CAST_IMPACT);

            if ((appStr != "ss_dheu_app_eff_override" && appStr != "effectmanager") || (ablStr != "ss_dheu_impact_override" && ablStr != "eventmanager"))
            {
                ShowPopup(WARNING_STRREFID, 1, OBJECT_INVALID, FALSE, 0);
            }
            TrackModuleEvent(nEvent, OBJECT_SELF);
            TrackSendGameId(TRUE);
            break;
        }
        ////////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: The module loads from a save game, or for the first time. This event can fire more than
        //       once for a single module or game instance.
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_MODULE_LOAD:
        {
            PrintToLog("Spell Shaping : EVENT_TYPE_MODULE_LOAD");
            string appStr = GetM2DAString(TABLE_EVENTS, "Script", EVENT_TYPE_APPLY_EFFECT);
            string ablStr = GetM2DAString(TABLE_EVENTS, "Script", EVENT_TYPE_ABILITY_CAST_IMPACT);

            if ((appStr != "ss_dheu_app_eff_override" && appStr != "effectmanager") || (ablStr != "ss_dheu_impact_override" && ablStr != "eventmanager"))
            {
                ShowPopup(WARNING_STRREFID, 1, OBJECT_INVALID, FALSE, 0);
            }
            TrackModuleEvent(nEvent, OBJECT_SELF);
            TrackSendGameId(FALSE);
            break;
        }
        ////////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: The player changes a game option from the options menu
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_OPTIONS_CHANGED:
        {
            PrintToLog("Spell Shaping : EVENT_TYPE_OPTIONS_CHANGED");
            string appStr = GetM2DAString(TABLE_EVENTS, "Script", EVENT_TYPE_APPLY_EFFECT);
            string ablStr = GetM2DAString(TABLE_EVENTS, "Script", EVENT_TYPE_ABILITY_CAST_IMPACT);

            if ((appStr != "ss_dheu_app_eff_override" && appStr != "effectmanager") || (ablStr != "ss_dheu_impact_override" && ablStr != "eventmanager"))
            {
                ShowPopup(WARNING_STRREFID, 1, OBJECT_INVALID, FALSE, 0);
            }
            break;
        }
        ////////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: A player objects enters the module
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_ENTER:
        {
            PrintToLog("Spell Shaping : EVENT_TYPE_ENTER");
            string appStr = GetM2DAString(TABLE_EVENTS, "Script", EVENT_TYPE_APPLY_EFFECT);
            string ablStr = GetM2DAString(TABLE_EVENTS, "Script", EVENT_TYPE_ABILITY_CAST_IMPACT);

            if ((appStr != "ss_dheu_app_eff_override" && appStr != "effectmanager") || (ablStr != "ss_dheu_impact_override" && ablStr != "eventmanager"))
            {
                ShowPopup(WARNING_STRREFID, 1, OBJECT_INVALID, FALSE, 0);
            }
            object oCreature = GetEventObject(ev, 0);
            // TrackModuleEvent(nEvent, OBJECT_SELF, oCreature);
            break;
        }

        // ---------------------------------------------------------------------
        // Game Mode Switch
        //      int(0) - New Game Mode (GM_* constant)
        //      int(1) - Old Game Mode (GM_* constant)
        // ---------------------------------------------------------------------
        case EVENT_TYPE_GAMEMODE_CHANGE:
        {
            int nNewGameMode = GetEventInteger(ev,0);
            int nOldGameMode = GetEventInteger(ev,1);

            // -----------------------------------------------------------------
            // Georg: I'm tracking game mode switches for aggregated
            //        'time spent in mode x' analysis
            // -----------------------------------------------------------------
            TrackModuleEvent(nEvent, OBJECT_SELF,OBJECT_INVALID, nNewGameMode,nOldGameMode);
            Log_Trace(LOG_CHANNEL_SYSTEMS,"Game mode changed from " + ToString(nOldGameMode) + " to " + ToString(nNewGameMode));
            break;
        }

        case EVENT_TYPE_POPUP_RESULT:
        {
            PrintToLog("Spell Shaping : EVENT_TYPE_POPUP_RESULT");
            /*
            object oOwner = GetEventObject(ev, 0);      // owner of popup
            int nPopupID  = GetEventInteger(ev, 0);     // popup ID
            int nButton   = GetEventInteger(ev, 1);     // button result (1 - 4)

            switch (nPopupID)
            {
                case 1:     // Placeable area transition
                    SignalEvent(oOwner, ev);
                    break;
            }
            */
            break;
        }


        default:
        {
            // -----------------------------------------------------------------
            // Handle character generation events sent by the engine.
            // -----------------------------------------------------------------
            Log_Trace(LOG_CHANNEL_EVENTS, GetCurrentScriptName(), Log_GetEventNameById(nEvent) + " (" + ToString(nEvent) + ") *** Unhandled event ***");
            break;
        }
    }
}

