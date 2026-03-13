class SettingsScreen extends Ui.Screen {
    hidden var apiKey;

    function initialize() {
        // Initialize UI components
        this.apiKey = "";
    }

    function onShow() {
        // Display input field for API key
        this.showInputField("Enter Hevy API Key", this.apiKey, function(key) {
            this.apiKey = key;
            // Save API key locally
            LocalStorage.save("hevyApiKey", this.apiKey);
        });
    }
}