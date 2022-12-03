-- // Global Variable. 
if getgenv().Internal then return getgenv().Internal end

-- // Services.
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")

-- // Variables.
local Heartbeat = RunService.Heartbeat
local LocalPlayer = Players.LocalPlayer
local CurrentCamera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- // Optimisation Variables.
local Drawingnew = Drawing.new
local Color3fromRGB = Color3.fromRGB
local Vector2new = Vector2.new
local GetGuiInset = GuiService.GetGuiInset
local Randomnew = Random.new
local mathfloor = math.floor
local CharacterAdded = LocalPlayer.CharacterAdded
local CharacterAddedWait = CharacterAdded.Wait
local WorldToViewportPoint = CurrentCamera.WorldToViewportPoint
local RaycastParamsnew = RaycastParams.new
local EnumRaycastFilterTypeBlacklist = Enum.RaycastFilterType.Blacklist
local Raycast = Workspace.Raycast
local GetPlayers = Players.GetPlayers
local Instancenew = Instance.new
local IsDescendantOf = Instancenew("Part").IsDescendantOf
local FindFirstChildWhichIsA = Instancenew("Part").FindFirstChildWhichIsA
local FindFirstChild = Instancenew("Part").FindFirstChild
local tableremove = table.remove
local tableinsert = table.insert

-- // Settings. 
getgenv().Internal = {
    Enabled = true,

    ShowFOV = true,
    FOV = 60,
    FOVSides = 12,
    FOVColour = Color3fromRGB(231, 84, 128),

    VisibleCheck = true,
    
    HitChance = 100,

    Selected = nil,
    SelectedPart = nil,

    TargetPart = {"Head", "HumanoidRootPart"},

    Ignored = {
        Teams = {
            {
                Team = LocalPlayer.Team,
                TeamColor = LocalPlayer.TeamColor,
            },
        },
        Players = {
            LocalPlayer,
            91318356
        }
    },

    RaycastIgnore = nil
}
local Internal = getgenv().Internal

-- // Create circle.
local circle = Drawingnew("Circle")
circle.Transparency = 1
circle.Thickness = 2
circle.Color = Internal.FOVColour
circle.Filled = false
Internal.FOVCircle = circle

-- // Update.
function Internal.UpdateFOV()
    -- // Check.
    if not (circle) then
        return
    end

    -- // Setting circle Properties.
    circle.Visible = Internal.ShowFOV
    circle.Radius = (Internal.FOV * 3)
    circle.Position = Vector2new(Mouse.X, Mouse.Y + GetGuiInset(GuiService).Y)
    circle.NumSides = Internal.FOVSides
    circle.Color = Internal.FOVColour

    -- // Return.
    return circle
end

-- // Custom functions.
local CalcChance = function(percentage)
    -- // Floor the percentage.
    percentage = mathfloor(percentage)

    -- // Get the chance.
    local chance = mathfloor(Randomnew().NextNumber(Randomnew(), 0, 1) * 100) / 100

    -- // Return.
    return chance <= percentage / 100
end

-- // Customizable Checking functions.
function Internal.IsPartVisible(Part, PartDescendant)
    -- // Variables.
    local Character = LocalPlayer.Character or CharacterAddedWait(CharacterAdded)
    local Origin = CurrentCamera.CFrame.Position
    local _, OnScreen = WorldToViewportPoint(CurrentCamera, Part.Position)

    -- // Check.
    if (OnScreen) then
        -- // Variables.
        local raycastParams = RaycastParamsnew()
        raycastParams.FilterType = EnumRaycastFilterTypeBlacklist
        raycastParams.FilterDescendantsInstances = Internal.RaycastIgnore or {Character, CurrentCamera}

        -- // Raycast.
        local Result = Raycast(Workspace, Origin, Part.Position - Origin, raycastParams)

        -- // Check.
        if (Result) then
            -- // Variables.
            local PartHit = Result.Instance
            local Visible = (not PartHit or IsDescendantOf(PartHit, PartDescendant))

            -- // Return.
            return Visible
        end
    end

    -- // Return.
    return false
end

-- // Ignore Player.
function Internal.IgnorePlayer(Player)
    -- // Variables.
    local Ignored = Internal.Ignored
    local IgnoredPlayers = Ignored.Players

    -- // Find the Player in the table bracket. 
    for _, IgnoredPlayer in ipairs(IgnoredPlayers) do
        -- // Make sure the Player matches.
        if (IgnoredPlayer == Player) then
            return false
        end
    end

    -- // Ignore Player.
    tableinsert(IgnoredPlayers, Player)
    return true
end

-- // UnIgnore Player.
function Internal.UnIgnorePlayer(Player)
    -- // Variables.
    local Ignored = Internal.Ignored
    local IgnoredPlayers = Ignored.Players

    -- // Find the Player in the table bracket. 
    for i, IgnoredPlayer in ipairs(IgnoredPlayers) do
        -- // Make sure the Player matches.
        if (IgnoredPlayer == Player) then
            -- // Remove from the Ignored list. 
            tableremove(IgnoredPlayers, i)
            return true
        end
    end

    -- // Return.
    return false
end

-- // Ignore Team.
function Internal.IgnoreTeam(Team, TeamColor)
    -- // Variables.
    local Ignored = Internal.Ignored
    local IgnoredTeams = Ignored.Teams

    -- // Find the Team in the table bracket.
    for _, IgnoredTeam in ipairs(IgnoredTeams) do
        -- // Make sure the Team matches.
        if (IgnoredTeam.Team == Team and IgnoredTeam.TeamColor == TeamColor) then
            return false
        end
    end

    -- // Ignore Team.
    tableinsert(IgnoredTeams, {Team, TeamColor})
    return true
end

-- // UnIgnore Team.
function Internal.UnIgnoreTeam(Team, TeamColor)
    -- // Variables.
    local Ignored = Internal.Ignored
    local IgnoredTeams = Ignored.Teams

    -- // Find the Team in the table bracket.
    for i, IgnoredTeam in ipairs(IgnoredTeams) do
        -- // Make sure the Team matches.
        if (IgnoredTeam.Team == Team and IgnoredTeam.TeamColor == TeamColor) then
            -- // Remove from the Ignored list. 
            tableremove(IgnoredTeams, i)
            return true
        end
    end

    -- // Return.
    return false
end

-- //  Toggle Team Check.
function Internal.TeamCheck(Toggle)
    if (Toggle) then
        return Internal.IgnoreTeam(LocalPlayer.Team, LocalPlayer.TeamColor)
    end

    return Internal.UnIgnoreTeam(LocalPlayer.Team, LocalPlayer.TeamColor)
end

-- // Check Team.
function Internal.IsIgnoredTeam(Player)
    -- // Variables.
    local Ignored = Internal.Ignored
    local IgnoredTeams = Ignored.Teams

    -- // Check if the Team is ignored. 
    for _, IgnoredTeam in ipairs(IgnoredTeams) do
        -- // Make sure the Team matches.
        if (Player.Team == IgnoredTeam.Team and Player.TeamColor == IgnoredTeam.TeamColor) then
            return true
        end
    end

    -- // Return.
    return false
end

-- // Check to see if the Player and Team are being Ignored.
function Internal.IsIgnored(Player)
    -- // Variables.
    local Ignored = Internal.Ignored
    local IgnoredPlayers = Ignored.Players

    -- // Loop.
    for _, IgnoredPlayer in ipairs(IgnoredPlayers) do
        -- // Verify that the Player Id is correct. 
        if (typeof(IgnoredPlayer) == "number" and Player.UserId == IgnoredPlayer) then
            return true
        end

        -- // Normal Player Instance.
        if (IgnoredPlayer == Player) then
            return true
        end
    end

    -- // Team check.
    return Internal.IsIgnoredTeam(Player)
end

-- // Obtain the Direction, Normal, and Material.
function Internal.Raycast(Origin, Destination, UnitMultiplier)
    if (typeof(Origin) == "Vector3" and typeof(Destination) == "Vector3") then
        -- // Handling.
        if (not UnitMultiplier) then UnitMultiplier = 1 end

        -- // Variables.
        local Direction = (Destination - Origin).Unit * UnitMultiplier
        local Result = Raycast(Workspace, Origin, Direction)

        -- // Make sure we have a Result.
        if (Result) then
            local Normal = Result.Normal
            local Material = Result.Material

            return Direction, Normal, Material
        end
    end

    -- // Return.
    return nil
end

-- // Get Character.
function Internal.Character(Player)
    return Player.Character
end

-- // Check Health.
function Internal.CheckHealth(Player)
    -- // Get Humanoid.
    local Character = Internal.Character(Player)
    local Humanoid = FindFirstChildWhichIsA(Character, "Humanoid")

    -- // Get Health.
    local Health = (Humanoid and Humanoid.Health or 0)

    -- // Check.
    return Health > 0
end

-- // Check to see if the Silent Aim is still available. 
function Internal.Check()
    return (Internal.Enabled == true and Internal.Selected ~= LocalPlayer and Internal.SelectedPart ~= nil)
end
Internal.checkSilentAim = Internal.Check

-- // Find the nearest Target Part. 
function Internal.GetClosestTargetPartToCursor(Character)
    local TargetParts = Internal.TargetPart

    -- // Variables.
    local ClosestPart = nil
    local ClosestPartPosition = nil
    local ClosestPartOnScreen = false
    local ClosestPartMagnitudeFromMouse = nil
    local ShortestDistance = 1/0

    -- // Check.
    local function CheckTargetPart(TargetPart)
        -- // String to Instance conversion.
        if (typeof(TargetPart) == "string") then
            TargetPart = FindFirstChild(Character, TargetPart)
        end

        -- // Make sure we have a Target.
        if not (TargetPart) then
            return
        end

        -- // Calculate the distance between the Mouse pointer and the Target area (on the screen).
        local PartPos, onScreen = WorldToViewportPoint(CurrentCamera, TargetPart.Position)
        local GuiInset = GetGuiInset(GuiService)
        local Magnitude = (Vector2new(PartPos.X, PartPos.Y - GuiInset.Y) - Vector2new(Mouse.X, Mouse.Y)).Magnitude

        -- // Variables.
        if (Magnitude < ShortestDistance) then
            ClosestPart = TargetPart
            ClosestPartPosition = PartPos
            ClosestPartOnScreen = onScreen
            ClosestPartMagnitudeFromMouse = Magnitude
            ShortestDistance = Magnitude
        end
    end

    -- // String Check.
    if (typeof(TargetParts) == "string") then
        -- // Check if it's all.
        if (TargetParts == "All") then
            -- // Character Children in a loop.
            for _, v in ipairs(Character:GetChildren()) do
                -- // Check to see if it's a Part. 
                if not (v:IsA("BasePart")) then
                    continue
                end

                -- // Check it.
                CheckTargetPart(v)
            end
        else
            -- // Individual.
            CheckTargetPart(TargetParts)
        end
    end

    -- // Check if it's a table.
    if (typeof(TargetParts) == "table") then
        -- // Check all of the Target Parts in a loop.
        for _, TargetPartName in ipairs(TargetParts) do
            CheckTargetPart(TargetPartName)
        end
    end

    -- // Return.
    return ClosestPart, ClosestPartPosition, ClosestPartOnScreen, ClosestPartMagnitudeFromMouse
end

-- // The function "GetClosestPlayerToCursor" is called.
function Internal.GetClosestPlayerToCursor()
        -- // Variables.
        local TargetPart = nil
        local ClosestPlayer = nil
        local Chance = CalcChance(Internal.HitChance)
        local ShortestDistance = 1/0

        -- // Chance.
        if (not Chance) then
            Internal.Selected = LocalPlayer
            Internal.SelectedPart = nil

        return LocalPlayer
    end

        -- // Loop through all Players.
        for _, Player in ipairs(GetPlayers(Players)) do
            -- // Get Character.
            local Character = Internal.Character(Player)

            -- // Make certain that it is not Ignored and that the Character exists. 
            if (Internal.IsIgnored(Player) == false and Character) then
                -- // Variables.
                local TargetPartTemp, _, _, Magnitude = Internal.GetClosestTargetPartToCursor(Character)

                -- // Check if the Part exists and is Healthy.
                if (TargetPartTemp and Internal.CheckHealth(Player)) then
                    -- // Check to see if it is in the FOV. 
                    if (circle.Radius > Magnitude and Magnitude < ShortestDistance) then
                        -- // Check if it is Visible.
                        if (Internal.VisibleCheck and not Internal.IsPartVisible(TargetPartTemp, Character)) then continue end

                    -- // Setting Variables.
                    ClosestPlayer = Player
                    ShortestDistance = Magnitude
                    TargetPart = TargetPartTemp
                end
            end
        end
    end

    -- // End.
    Internal.Selected = ClosestPlayer
    Internal.SelectedPart = TargetPart
end

-- // Heartbeat function.
Heartbeat:Connect(function()
    Internal.UpdateFOV()
    Internal.GetClosestPlayerToCursor()
end)

-- // Return.
return Internal