#!/usr/bin/env python3

import asyncio
import iterm2

async def main(conn):
    async with iterm2.VariableMonitor(conn, iterm2.VariableScopes.APP, "effectiveTheme", None) as mon:
        while True:
            theme = await mon.async_get()
            if "dark" in theme.split():
                shade = "Dark"
            else:
                shade = "Light"
            preset = await iterm2.ColorPreset.async_get(conn, f"Gruvbox {shade}")
            for partial in await iterm2.PartialProfile.async_query(conn):
                profile = await partial.async_get_full_profile()
                await profile.async_set_color_preset(preset)

iterm2.run_forever(main)
