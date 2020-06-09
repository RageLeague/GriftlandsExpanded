-- Defines the boss that can show up and the weighting of the boss
local BOSS = {
    DRONE_GOON = 1,           
    SPARK_BARON_BOSS = 1,
    GUARDIAN_AUTOMECH = 1
}
return function(convo)
    convo:GetState("STATE_KASHIO_STUFF")

        :ClearFn()
        :Fn(function(cxt) 
            local guard
            local goons
            
            cxt.quest.param.done_asking_about_kashio = true
            cxt.location:SetPlax("INT_GrogNDog_Damaged_1")
            
            TheGame:SubmitLog("DAY 1 BOSS")
            
            for _, agent in cxt.location:Agents() do
                if agent:GetRoleAtLocation() == CHARACTER_ROLES.GUARD then
                    guard = agent
                    cxt.quest:AssignCastMember("guard", guard)
                    break
                end
            end

            goons = {cxt.quest:CreateSkinnedAgent(weightedpick(BOSS))}

            cxt.quest:AssignCastMember("kashio_goon", goons[1])
            --
            local kashio = cxt.quest:GetCastMember("kashio")
            kashio:MoveToLocation(cxt.location)
            
            
            cxt:ProgressDialog("kashio_meeting", "DIALOG_INTRO")
            

            kashio:MoveToLimbo()
            cxt.enc:SetPrimaryCast(goons[1])

            cxt:Dialog("DIALOG_GOON_THREATEN")

            
            if not cxt.enc.scratch.tried_negotiate then
                cxt:Opt("OPT_REQUEST_BACKUP", guard)
                    :Fn(function() cxt.enc:SetPrimaryCast(guard) end)
                    :Dialog("DIALOG_REQUEST_BACKUP")
                    :Negotiation{
                        difficulty = cxt.quest:GetRank(),
                        target_agent = guard,
                        helpers = { {agent= cxt.quest:GetCastMember("fssh"), reason = SUPPORT_REASON.PLAYER_FRIENDSHIP, txt = LOC"SUPPORT_DESC.LIKES_YOU"} },
						situation_modifiers =
                        {
                            { value = 10, text = "Afraid of Kashio" }
                        },
                        reward_difficulty = QUEST_MAX_RANK,
                        flags = NEGOTIATION_FLAGS.NO_BYSTANDERS,
                        reason = "NEGOTIATION_REASON",

                        on_success = function(cxt) 
                                cxt.enc:SetPrimaryCast(goons[1])
                                cxt:Dialog("DIALOG_CONVINCED")
                                cxt:Opt("OPT_DEFEND")
                                    :Battle{
                                        allies = {"guard"},
                                        flags = BATTLE_FLAGS.SELF_DEFENCE | BATTLE_FLAGS.NO_BYSTANDERS | BATTLE_FLAGS.BOSS_FIGHT,
                                        noncombatants = {cxt.quest:GetCastMember("fssh")},
                                        enemies = goons,
                                        on_win = function(cxt) 
                                            for k,v in pairs(goons) do
                                                v:MoveToLimbo()
                                            end
                                            cxt:GoTo("STATE_REWARD")
                                        end,                
                                    }
                            end,
                        on_fail = function(cxt) 
                                cxt.enc:SetPrimaryCast(goons[1])
                                cxt:Dialog("DIALOG_NOT_CONVINCED")
                                cxt:Opt("OPT_DEFEND")
                                    :Battle{
                                        --advantage = TEAM.RED,
                                        flags = BATTLE_FLAGS.SELF_DEFENCE | BATTLE_FLAGS.NO_BYSTANDERS | BATTLE_FLAGS.BOSS_FIGHT,
                                        noncombatants = {cxt.quest:GetCastMember("fssh")},
                                        enemies = goons,
                                        on_win = function(cxt) 
                                            
                                            for k,v in pairs(goons) do
                                                v:MoveToLimbo()
                                            end
                                            cxt:GoTo("STATE_REWARD")
                                        end,                
                                    }
                            end,
                    }
            end

            cxt:Opt("OPT_FIGHT")
                :Fn(function() cxt.enc:SetPrimaryCast(goons[1]) end)
                :Dialog("DIALOG_FIGHT")
                :Battle{
                    flags = BATTLE_FLAGS.SELF_DEFENCE | BATTLE_FLAGS.NO_BYSTANDERS | BATTLE_FLAGS.BOSS_FIGHT,
                    reward_difficulty = QUEST_MAX_RANK,
                    noncombatants = {cxt.quest:GetCastMember("fssh"), cxt.quest:GetCastMember("kashio")},
                    enemies = goons,
                    on_win = function(cxt) 
                        for k,v in pairs(goons) do
                            v:MoveToLimbo()
                        end
                        cxt:GoTo("STATE_REWARD")
                    end,                
                }
        end)
end 