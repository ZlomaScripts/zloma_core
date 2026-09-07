ZlomaCore.RegisterClientFuel('ox_fuel',
    function(vehicle) return Entity(vehicle).state.fuel or GetVehicleFuelLevel(vehicle) end,
    function(vehicle, fuelLevel)
        Entity(vehicle).state.fuel = fuelLevel
        SetVehicleFuelLevel(vehicle, fuelLevel + 0.0)
    end
)