---@meta _
---@diagnostic disable: lowercase-global

-- Artificer Indicator Mod
-- Displays remaining uses of Artificer (MetaToRunMetaUpgrade) in the trait tray

local function UpdateArtificerIndicator()
    if not config.ArtificerIndicator then
        return
    end

    local trait = GetHeroTrait("MetaToRunMetaUpgrade")
    -- Helper: apply scale and icon settings to both the hero trait and raw TraitData
    local function applyScaleAndIcon(tr, scale)
        tr.Icon = "CardArt_18"
        tr.HUDScale = scale
        tr.IconScale = scale
        tr.PinIconScale = scale
        tr.PinIconFrameScale = scale
        tr.HighlightAnimScale = scale
        local raw = TraitData and TraitData[tr.Name]
        if raw then
            raw.Icon = tr.Icon
            raw.HUDScale = scale
            raw.IconScale = scale
            raw.PinIconScale = scale
            raw.PinIconFrameScale = scale
            raw.HighlightAnimScale = scale
        end
    end

    -- Helper: clear any changes we made so the trait won't reappear as an empty entry on load
    local function clearUIFields(tr)
        tr.ShowInHUD = false
        tr.Hidden = true
        tr.Icon = nil
        tr.AnchorId = nil
        tr.HUDScale = nil
        tr.IconScale = nil
        tr.PinIconScale = nil
        tr.PinIconFrameScale = nil
        tr.HighlightAnimScale = nil
        local raw = TraitData and TraitData[tr.Name]
        if raw then
            raw.Icon = nil
            raw.HUDScale = nil
            raw.IconScale = nil
            raw.PinIconScale = nil
            raw.PinIconFrameScale = nil
            raw.HighlightAnimScale = nil
        end
    end

    if not trait then
        return
    end

    local uses = trait.MetaConversionUses or 0
    trait.RemainingUses = uses

    local scale = tonumber(config.ArtificerHUDScale) or 0.14

    if uses > 0 then
        trait.UsesAsEncounters = false
        trait.Hidden = false
        trait.ShowInHUD = true
        applyScaleAndIcon(trait, scale)

        if trait.AnchorId then
            -- update existing UI immediately
            SetAnimation({ Name = trait.Icon, DestinationId = trait.AnchorId })
            SetScale({ Id = trait.AnchorId, Fraction = scale })
            UpdateTraitNumber(trait)

            -- update the trait component table so future hovers/pins use our scale
            local tc = (HUDScreen and HUDScreen.SlottedTraitComponents and HUDScreen.SlottedTraitComponents[trait.AnchorId])
                    or (HUDScreen and HUDScreen.ActiveTraitComponents and HUDScreen.ActiveTraitComponents[trait.AnchorId])
            if tc then
                tc.IconScale = scale
                tc.PinIconScale = scale
                tc.PinIconFrameScale = scale
            end

            -- update any pinned hover icons that exist
            local tray = ActiveScreens and ActiveScreens.TraitTrayScreen
            if tray and tray.Pins then
                for _, pin in ipairs(tray.Pins) do
                    if pin and pin.Button == tc and pin.Components then
                        if pin.Components.Icon then
                            SetScale({ Id = pin.Components.Icon.Id, Fraction = scale })
                        end
                        if pin.Components.Frame then
                            SetScale({ Id = pin.Components.Frame.Id, Fraction = scale })
                        end
                    end
                end
            end
        end

        TraitUIUpdateText(trait)
    else
        -- no uses; remove UI and clear fields so it doesn't reappear empty
        TraitUIRemove(trait)
        clearUIFields(trait)
    end

    UpdateHeroTraitDictionary()
end

-- Hook EquipMetaUpgrades to set up indicator when equipping
modutil.mod.Path.Wrap("EquipMetaUpgrades", function(base, hero, args)
    base(hero, args)
    UpdateArtificerIndicator()
end)

-- Hook ConvertMetaRewardPresentation to update after gift usage
modutil.mod.Path.Wrap("ConvertMetaRewardPresentation", function(base, sourceDrop)
    base(sourceDrop)
    UpdateArtificerIndicator()
end)

-- Hook StartNewRun to ensure setup at run start
modutil.mod.Path.Wrap("StartNewRun", function(base, prevRun, args)
    local result = base(prevRun, args)
    UpdateArtificerIndicator()
    return result
end)

-- Hook ShowTraitUI to update before showing
modutil.mod.Path.Wrap("ShowTraitUI", function(base, args)
    UpdateArtificerIndicator()
    return base(args)
end)

-- Hook IncrementTableValue to catch MetaConversionUses changes
modutil.mod.Path.Wrap("IncrementTableValue", function(base, tableArg, key, amount)
    base(tableArg, key, amount)
    if key == "MetaConversionUses" then
        UpdateArtificerIndicator()
    end
end)

print("ArtificerIndicator: Mod loaded successfully")
