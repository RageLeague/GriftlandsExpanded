MountModData( "JuniorElderExpandedMod" )

local function OnLoad()
    local self_dir = "JuniorElderExpandedMod:mod_content/"
    local LOAD_FILE_ORDER =
    {
        "basic_negotiation_mod",
        "basic_actions_mod",
        "battle_conditions_mod",
        "sal_negotiation_mod",
        "sal_battle_mod",
        --"sal_battle_grafts_mod",
        "custom_boss_mod",
    }
    for k, filepath in ipairs(LOAD_FILE_ORDER) do
        require(self_dir .. filepath)
    end
end

return {
    OnLoad = OnLoad
}