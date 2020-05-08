local battle_defs = require "battle/battle_defs"
local BATTLE_EVENT = battle_defs.BATTLE_EVENT
local CARD_FLAGS = battle_defs.CARD_FLAGS

local negotiation_defs = require "negotiation/negotiation_defs"
local EVENT = negotiation_defs.EVENT

local def = CharacterDef("Drusk_Prime",
{
    unique = true,
    renown = 3,
    combat_strength = 3, 
    name = "Drusk Prime",
    base_def = "NPC_BASE",
    species = SPECIES.BEAST,
    gender = GENDER.MALE,
		boss = true,
        battle_preview_anim = "anim/boss_drusk_slide.zip",
        battle_preview_offset = { x = 135, y = 0 },
        battle_preview_glow = { colour = 0xC3DE2EFF, bloom = 0.15, threshold = 0.02 },
        battle_preview_audio = "event:/ui/prebattle_overlay/prebattle_overlay_whooshin_boss_drusk1",
        death_item = "drusk_core",

        faction_id = MONSTER_FACTION,
        tags = { "beast", "no_rob", "enforcer" },

        combat_anims = { "anim/med_combat_drusk_01.zip" },
        build = "drusk_01",

    
    fight_data = 
    {
            MAX_MORALE = MAX_MORALE_LOOKUP.IMMUNE,
            MAX_HEALTH = 180,
            battle_scale = 1.20,
            status_widget_dx = 0.5,
            status_widget_dy = -0.95,
        
	conditions = 
        { 
            enraged =
            {
                name = "Enraged",
                feature_desc = "You have angered the boss, it will more agressive from now on.",
                desc = "You have angered the boss, it will more agressive from now on.",
                icon = "battle/conditions/ravenous.tex",		
                ctype = CTYPE.DEBUFF,

                apply_fx = {"power"},

            },
        },
        
        
        attacks = 
        {
            -- Max Health attacks
            forceful_escalation = table.extend(NPC_MELEE)
            {
                anim = "stab",
                flags = CARD_FLAGS.MELEE,

                base_damage = 4,
                defensiveness_amount = 2	,

                OnPostResolve = function( self, battle, attack )
                    self.owner:AddCondition("SURE_FOOTING", self.defensiveness_amount, self)
                end

            },

            steady_reinforcement = table.extend(NPC_BUFF)
            {
                anim = "taunt_defend",
                flags = CARD_FLAGS.BUFF | CARD_FLAGS.SKILL,
                target_type = TARGET_TYPE.SELF,
                defend_amount = 4,
                power_amount = 2,

                OnPostResolve = function( self, battle, attack )
                    self.owner:AddCondition("DEFEND", self.defend_amount, self)
                    self.owner:AddCondition("POWER", self.power_amount, self)
                end
            },

            cautious_jab = table.extend(NPC_MELEE)
            {
                anim = "stab",
                flags = CARD_FLAGS.BUFF | CARD_FLAGS.MELEE,

                base_damage = 6,
                defend_amount = 6,

                OnPostResolve = function( self, battle, attack )
                    self.owner:AddCondition("DEFEND", self.defend_amount, self)
                end
            },

            -- Enraged Attacks
            wild_flailing = table.extend(NPC_MELEE)
            {
                anim = "stab",
                flags = CARD_FLAGS.MELEE,

                base_damage = 1,
   		        hit_count = 2,

            },

            protect_the_core = table.extend(NPC_BUFF)
            {
                anim = "splort",
                flags = CARD_FLAGS.BUFF | CARD_FLAGS.SKILL,
                target_type = TARGET_TYPE.SELF,
                defend_amount = 6,
                options = {"corrosive_goo", "anesthetic_goo", "adherent_goo", "replicating_goo"},
                num_copies = 2,

                OnPostResolve = function( self, battle, attack )
                    self.owner:AddCondition("DEFEND", self.defend_amount, self)

                    local cards = {}
                    for i = 1, self.num_copies do
                    local incepted_card = Battle.Card(self.options[math.random(#self.options)], self.battle:GetPlayerFighter() )
                    incepted_card.incepted = true
                    incepted_card.show_dealt = true
                    self.battle:DealCards( {incepted_card}, self.battle:GetDrawDeck() )
                    end
                end,

            },

            last_reserves = table.extend(NPC_MELEE)
            {
                anim = "stab",
                flags = CARD_FLAGS.BUFF | CARD_FLAGS.MELEE,

                base_damage = 2,
                defend_amount = 2,
                power_amount = 1,
                defensiveness_amount = 1,

                OnPostResolve = function( self, battle, attack )
                    self.owner:AddCondition("DEFEND", self.defend_amount, self)
                    self.owner:AddCondition("POWER", self.power_amount, self)
                    self.owner:AddCondition("SURE_FOOTING", self.defensiveness_amount, self)
                end
            },
        },

        behaviour =
        {
            OnActivate = function( self, fighter )
                self.high_health_attacks = self:MakePicker()
                    :AddID("forceful_escalation", 2)
                    :AddID("steady_reinforcement", 2)
                    :AddID("cautious_jab", 1)


                self.low_health_attacks = self:MakePicker()
                    :AddID("wild_flailing", 3)
                    :AddID("protect_the_core", 1)
                    :AddID("last_reserves", 1)

                    self.fighter:AddCondition("leaking_core", 1, self)
                self:SetPattern(self.HighHealth)
            end,

            HighHealth = function( self )
            	if self.fighter:GetHealthPercent() > 0.5 then
                    self.high_health_attacks:ChooseCards(1)
                else
                    self.fighter:AddCondition("enraged", 1, self)
                    self.low_health_attacks:ChooseCards(1)
                    self:SetPattern(self.LowHealth)
                end
            end,

            LowHealth = function( self )
                self.low_health_attacks:ChooseCards(1)
            end,

        },


    },
})

Content.AddCharacterDef( def )
    