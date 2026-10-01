#!/bin/env bash

# My coding virtual desktop
CODING_DESKTOP_ID="${1}"
if [[ -z "${CODING_DESKTOP_ID}" ]]
then
    exit 1
fi

dbus-monitor "type='signal', interface='org.kde.KWin.VirtualDesktopManager', member='currentChanged'" | \
while read -r line;
do
    is_night_light_enabled=${ qdbus6 org.kde.KWin /org/kde/KWin/NightLight org.kde.KWin.NightLight.enabled ; }
    [[ $is_night_light_enabled == "false" ]] && continue

    is_night_light_running=${ qdbus6 org.kde.KWin /org/kde/KWin/NightLight org.kde.KWin.NightLight.running; }
    current_desktop_id=${ qdbus6 org.kde.KWin /VirtualDesktopManager org.kde.KWin.VirtualDesktopManager.current; }
    if [[ $is_night_light_running == "true" &&
          $current_desktop_id == "${CODING_DESKTOP_ID}" ]]
    then
        qdbus6 org.kde.kglobalaccel /component/kwin org.kde.kglobalaccel.Component.invokeShortcut "Toggle Night Color"
    elif [[ $is_night_light_running == "false" &&
            $current_desktop_id != "${CODING_DESKTOP_ID}" ]]
    then
        qdbus6 org.kde.kglobalaccel /component/kwin org.kde.kglobalaccel.Component.invokeShortcut "Toggle Night Color"
    fi
done
