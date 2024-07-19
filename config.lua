Config = {}

-- Command and key to open the blip menu
Config.MenuCommand = 'createblip'
Config.MenuKey = 'F7'

-- Text used in the user interface and debug messages
Config.Text = {
    BlipManager = "Blip Manager",
    CreateBlip = "Create Blip",
    EditBlips = "Edit Blips",
    Close = "Close",
    EnterBlipName = "Enter Blip Name",
    SelectBlipIcon = "Select Blip Icon",
    CustomIcon = "Custom Icon",
    Back = "Back",
    SelectBlipColor = "Select Blip Color",
    CustomColor = "Custom Color",
    EnterCustomIconID = "Enter Custom Icon ID",
    EnterCustomColorID = "Enter Custom Color ID",
    ChangeIcon = "Change Icon",
    ChangeColor = "Change Color",
    DeleteBlip = "Delete Blip",
    ManageBlip = "Manage Blip - %s",
    ErrorMissingData = "Error: Missing data for %s",
    FrameworkNotInitialized = "Error: Framework not properly initialized during %s",
    PlayerLoadedEvent = "PlayerLoaded event triggered for %s",
    WarningFrameworkNotInitialized = "Warning: Framework not fully initialized after %d seconds",
    ResourceStarted = "Resource %s has started.",
    TriggeringPlayerLoadedEvent = "Triggering PlayerLoaded event",
    FrameworkPlayerLoadedNotFound = "Warning: Framework.PlayerLoaded not found. Using fallback method.",
    ConfirmBlipCreation = "Are you sure you want to create this blip?",
    ConfirmBlipDeletion = "Are you sure you want to delete this blip?",
    BlipCreated = "Blip created successfully",
    BlipUpdated = "Blip updated successfully",
    BlipDeleted = "Blip deleted successfully",
    BlipNameLabel = "Blip Name",
    IconIDLabel = "Icon ID",
    ColorIDLabel = "Color ID",
    Confirm = "Confirm",
    Cancel = "Cancel",
    NoBlipsFound = "No blips found",
    LoadingBlips = "Loading blips...",
    BlipList = "Blip List",
    NoPermission = "You do not have permission to use this command"
}

-- Blip creation settings
Config.DefaultBlipScale = 1.0
Config.DefaultBlipAlpha = 255

-- Limits for blip creation (0 for no limit)
Config.MaxBlipsPerPlayer = 10
Config.MinBlipNameLength = 3
Config.MaxBlipNameLength = 30

-- Permissions
Config.RequirePermission = true -- Set to true to require permission to create/edit blips
Config.AdminRole = "admin" -- Role required if RequirePermission is true

-- Sync settings
Config.SyncInterval = 60000 -- Interval in milliseconds for syncing blips between server and client

-- Debug
Config.DebugMode = false -- Set to true to enable debug messages

-- Discord Webhook
Config.DiscordWebhookURL = "YOUR_DISCORD_WEBHOOK_URL"
