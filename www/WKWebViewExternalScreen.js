
var ExternalScreen = {
	addEventListener: function (success, fail) {
		cordova.exec(success, fail, "ExternalScreen", "addEventListener", []);
	},
	checkAvailability: function (success, fail) {
		cordova.exec(success, fail, "ExternalScreen", 'checkAvailability', []);
	},
	loadHTML: function (fileURL, success, fail) {
		cordova.exec(success, fail, "ExternalScreen", 'loadHTML', [fileURL]);
	},
	invokeJavaScript: function (str, success, fail) {
		cordova.exec(success, fail, "ExternalScreen", 'invokeJavaScript', [str]);
	},
	disconnect: function (success, fail) {
		cordova.exec(success, fail, "ExternalScreen", 'disconnect', []);
	},
	show: function (success, fail) {
		cordova.exec(success, fail, "ExternalScreen", "show", []);
	},
	hide: function (success, fail) {
		cordova.exec(success, fail, "ExternalScreen", "hide", []);
	}
};

module.exports = ExternalScreen;
