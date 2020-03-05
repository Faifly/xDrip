var Localize = require("./index.js");
var transformer = Localize.fromGoogleSpreadsheet("1tYn-CvmGOnRfGQyerqrbzUbgN4mD3413-oVxHhFkg0E", '*');
transformer.setKeyCol('KEY');

transformer.save("xDrip/Resources/en.lproj/Localizable.strings", { valueCol: "EN", format: "ios" });
transformer.save("xDrip/Resources/ru.lproj/Localizable.strings", { valueCol: "RU", format: "ios" });
