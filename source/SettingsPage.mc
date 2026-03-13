class SettingsScreen extends Ui.Screen {
    hidden var apiKey;

    function initialize() {
        // Initialize the screen
        this.apiKey = Settings.get("hevy_api_key", "");
    }

    function onShow() {
        // Display the settings UI
        // Add input field for API key
        // Save the API key when the user submits
    }

    function onSave() {
        // Save the API key to settings
        Settings.set("hevy_api_key", this.apiKey);
    }
}