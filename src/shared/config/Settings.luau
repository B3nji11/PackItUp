-- Player settings, saved per profile. Defaults apply when a setting has never been changed.
return table.freeze({
    Order = table.freeze({ "PetsFollow", "ShowOtherPets" }),
    Names = table.freeze({ PetsFollow = "Pets follow me", ShowOtherPets = "Show other players' pets" }),
    Hints = table.freeze({
        PetsFollow = "When off, nobody sees your equipped pets. Bonuses still apply.",
        ShowOtherPets = "Only changes what you see. Turn off for a cleaner or faster view.",
    }),
    Defaults = table.freeze({ PetsFollow = true, ShowOtherPets = true }),
})
