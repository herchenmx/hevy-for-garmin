class SettingsScreen extends Ui.Screen {
    hidden var apiKey;

    function initialize() {
        // Initialize the screen
        apiKey = Settings.get("hevy_api_key", "");
    }

    function onShow() {
        // Display the settings UI
        Ui.drawText("Enter Hevy API Key:", 0, 0);
        Ui.drawTextInput(apiKey, 0, 20);
    }

    function onSave() {
        // Save the API key
        Settings.set("hevy_api_key", apiKey);
    }
}