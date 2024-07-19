# aar-blips
Blip Manager for ESX and QBCore - Fivem

Blip Manager is a comprehensive script for managing map blips in GTA V using the ESX and QBCore frameworks. It allows administrators to create, edit, and delete custom blips on the map, providing a user-friendly menu for customization. The script includes features such as real-time icon and color preview during selection, permission-based access, persistent storage of blips, and Discord webhook integration for monitoring blip operations.

Features
Create Custom Blips: Easily create custom blips with selectable icons and colors.
Edit Existing Blips: Modify icons, colors, and names of existing blips.
Delete Blips: Remove blips that are no longer needed.
Real-Time Preview: See a real-time preview of blip icons and colors on the minimap while making selections.
Permission-Based Access: Restrict blip management to users with specific roles.
Persistent Storage: Blips are saved to a file and reloaded on server restart.
Discord Webhook Integration: Send notifications to a Discord channel for blip creation, updates, and deletions.
Framework Compatibility: Supports both ESX and QBCore frameworks.
Installation
Download and Extract: Download the script and extract it to your server's resource folder.
Add to Server Config: Add ensure aar-blips to your server.cfg file.
Configuration: Edit the config.lua file to adjust settings such as command, key mappings, permissions, and Discord webhook URL.
Start the Server: Start your server and the script will be automatically loaded.
Configuration
Edit the config.lua file to customize the settings:

lua
Copia codice
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
Discord Webhook
To enable Discord notifications for blip operations:

Create a Webhook: In your Discord server, create a new webhook in the channel where you want to receive notifications.
Set Webhook URL: Copy the webhook URL and paste it into the Config.DiscordWebhookURL field in the config.lua file.
Usage
Open Blip Manager: Use the /createblip command or press the F7 key to open the blip manager menu.
Create a Blip: Enter the blip name, select an icon and color, and confirm the creation.
Edit a Blip: Select a blip from the list, then change its icon, color, or delete it.
Permissions: Ensure that the player has the required role to access the blip manager if permissions are enabled.
Compatibility
ESX: Ensure es_extended is running on your server.
QBCore: Ensure qb-core is running on your server.
Support
For support and updates, join our Discord.

License
This project is licensed under the MIT License.
