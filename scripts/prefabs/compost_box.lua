require "prefabutil"

local assets=
{
	Asset("ANIM", "anim/composter.zip"),
	Asset("ANIM", "anim/ui_chest_3x3.zip"),
}
local prefabs =
{
    "collapse_small",
}

local function onopen(inst) 
	 
	inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open")		
        inst.AnimState:PlayAnimation("open")
end 

local function onclose(inst) 
	inst.AnimState:PlayAnimation("close")
	inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close")		
end 

local function onhammered(inst, worker)
    inst.components.lootdropper:DropLoot()
    inst.components.container:DropEverything()
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")
    inst:Remove()
end

local function onhit(inst, worker)
    inst.AnimState:PlayAnimation("hit")
    inst.components.container:DropEverything()
    inst.AnimState:PushAnimation("close", false)
    inst.components.container:Close()
end

local function onbuilt(inst)
	inst.AnimState:PlayAnimation("place")
	inst.AnimState:PushAnimation("idle")	
end

local function itemtest(inst, item, slot)
	return (item.components.edible and item.components.perishable) or item.prefab == "spoiled_food" or item.prefab == "rottenegg" or item.prefab == "guano"
end

local function onsave(inst, data)
    if inst:HasTag("burnt") or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) then
        data.burnt = true
    end
end

local function onload(inst, data)
    if data ~= nil and data.burnt and inst.components.burnable then
        inst.components.burnable.onburnt(inst)
    end
end

local function fn(Sim)
	local inst = CreateEntity()

    inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()

	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon( "composter.tex" )
	
	MakeObstaclePhysics(inst, .7)    
	inst:AddTag("composter")
    inst:AddTag("structure")
    inst.AnimState:SetBank("composter")
    inst.AnimState:SetBuild("composter")
    inst.AnimState:PlayAnimation("idle", true)
    
	MakeSnowCoveredPristine(inst)

	inst.entity:SetPristine()
	
    if not TheWorld.ismastersim then
		inst.OnEntityReplicated = function(inst) inst.replica.container:WidgetSetup("compost_box") end
		return inst
	end
	if TUNING.COMPOSTER.DECAYSINTO == 1 then
		inst:AddTag("guano")
	end
	if TUNING.COMPOSTER.DECAYSINTO == 2 then
		inst:AddTag("poop")
	end
    inst:AddComponent("inspectable")
	inst:AddComponent("container")
    inst.components.container:WidgetSetup("compost_box")
	
    inst.components.container.onopenfn = onopen
    inst.components.container.onclosefn = onclose   

    inst:AddComponent("lootdropper")

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(1)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)
	
	MakeSmallBurnable(inst, nil, nil, true)
	MakeSmallPropagator(inst)
	
	inst:ListenForEvent("onburnt", function(inst)
	inst:DoTaskInTime(0, inst.Remove)
end)
	
	AddHauntableDropItemOrWork(inst)
    MakeSnowCovered(inst)
	
	inst.OnSave = onsave 
	inst.OnLoad = onload	
	

    return inst
end

return Prefab( "common/composter", fn, assets),
	MakePlacer("common/composter_placer", "composter", "composter", "idle") 

