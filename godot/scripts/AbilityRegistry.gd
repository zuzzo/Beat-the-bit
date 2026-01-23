extends Node

var _registry: Dictionary = {}

func _ready() -> void:
    _register("extra_die_then_remove_blue")
    _register("extra_die_then_remove_blue_coin_3")
    _register("next_roll_plus_3")
    _register("reveal_2_keep_1")
    _register("boss_finale_cost_minus_5")
    _register("frog_transform")
    _register("aging_penalty")
    _register("boss_even_discard_or_odd_lose_heart")
    _register("boss_even_poison_or_odd_lose_heart")
    _register("boss_even_lose_3_coins_or_odd_lose_heart")
    _register("boss_even_flip_or_odd_lose_heart")
    _register("astaroth_phase_penalties")
    _register("armor_extra_slot_1")
    _register("armor_extra_slot_2")
    _register("sacrifice_prevent_heart_loss")
    _register("discard_revealed_adventure")
    _register("reroll_same_dice")
    _register("after_roll_minus_1_all_dice")
    _register("after_roll_set_one_die_to_1")
    _register("reroll_5_or_6")
    _register("halve_even_dice")
    _register("add_red_die")
    _register("reflect_damage_poison")
    _register("next_roll_minus_2_all_dice")
    _register("lowest_die_applies_to_all")
    _register("deal_1_damage")
    _register("ignore_fatigue_if_all_different")
    _register("next_roll_double_then_remove_half")
    _register("on_heart_loss_destroy_fatigue")
    _register("regno_del_male_portal")
    _register("sacrifice_open_portal")
    _register("bonus_damage_multiheart")
    _register("reset_hearts_and_dice")
    _register("flip_on_one_heart")
    _register("remove_dice_showing_6")
    _register("flip_if_more_than_one_heart")
    _register("regno_del_male_track")

func _register(ability_id: String) -> void:
    var path := "res://scripts/abilities/%s.gd" % ability_id
    var script := load(path)
    if script == null:
        return
    _registry[ability_id] = script.new()

func apply(ability_id: String, context: Dictionary) -> void:
    if not _registry.has(ability_id):
        return
    _registry[ability_id].apply(context)
