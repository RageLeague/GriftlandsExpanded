-- Defines the boss that can show up and the weighting of the boss
local BOSS = {
    SHROOG = 1,           
    DRUSK_1 = 1,
    DRUSK_ANCIENT = 1
}
return function(convo)
    convo:GetState("STATE_FIGHT_BEAST")

        :ClearFn()
        :Fn(function(cxt)
            cxt:Dialog("DIALOG_INTRO")

            if not cxt.quest.param.jake_help then
                cxt.quest.param.ship_jake:MoveToLimbo()
            end

            if not cxt.quest.param.clerk_help then
                cxt.quest.param.ship_clerk:MoveToLimbo()
            end

            cxt.quest.param.beast = TheGame:GetGameState():AddSkinnedAgent(weightedpick(BOSS)) 
            cxt.enc:SetPrimaryCast(cxt.quest.param.beast)

            local allies = {}
            cxt:Dialog("DIALOG_SHROOG")
            if cxt.quest.param.clerk_help then
                cxt:Dialog("DIALOG_CLERK_FIGHT")
                table.insert(allies, cxt.quest.param.ship_clerk)
            elseif cxt.quest.param.jake_help then
                cxt:Dialog("DIALOG_JAKE_FIGHT")
                table.insert(allies, cxt.quest.param.ship_jake)
            else
                cxt:Dialog("DIALOG_NO_ONE_FIGHT")
            end

            cxt:Opt("OPT_DEFEND")
                :Dialog("DIALOG_ATTACK")
                :Battle{
                    flags = BATTLE_FLAGS.BOSS_FIGHT | BATTLE_FLAGS.SELF_DEFENCE,
                    allies = allies,
                    on_win = function()
                        if cxt.quest.param.clerk_help and not cxt.quest.param.ship_clerk:IsDead() then
                            cxt:Dialog("DIALOG_PST_FIGHT_CLERK")
                        elseif cxt.quest.param.jake_help and not cxt.quest.param.ship_jake:IsDead() then
                            cxt:Dialog("DIALOG_PST_FIGHT_JAKE")
                        else
                            cxt:Dialog("DIALOG_PST_FIGHT")
                        end
                        cxt.quest:Complete("get_the_package")
                        StateGraphUtil.AddLeaveLocation(cxt)
                    end,
                }


        end)
end 