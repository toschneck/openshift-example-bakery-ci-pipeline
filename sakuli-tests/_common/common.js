//some shared variables
var COMMON_PATH = "../../_common";
var PDF_EDITOR_NAME = "masterpdfeditor4";

function bakeryURL() {
    var bakeryUrl = env.getEnv('BAKERY_BAKERY_URL');
    if (!bakeryUrl) {
        bakeryUrl = "http://bakery-web-server:8080/bakery/";
    }
    Logger.logInfo("BAKERY_URL: " + bakeryUrl);
    return bakeryUrl;
}

function reportURL() {
    var reportUrl = env.getEnv('BAKERY_REPORT_URL');
    if (!reportUrl) {
        reportUrl = "http://bakery-report-server:8080/report/";
    }
    Logger.logInfo("REPORT_URL: " + reportUrl);
    return reportUrl;
}

function loadPicsForEnvironment(testCase) {
    testCase.addImagePaths(COMMON_PATH);

    //over load common environment (centos firefox) if needed
    var envPicFolder = getEnvPicFolder();
    if (envPicFolder != null) {
        testCase.addImagePaths(COMMON_PATH + "/" + envPicFolder);
        testCase.addImagePaths(envPicFolder);
    }
}

function getEnvPicFolder() {
    if (_isFF()) {
        Logger.logInfo('Detected environment: Ubuntu + Firefox >> overload some image patterns');
        return "firefox";
    }
    Logger.logInfo('Detected default environment: Ubuntu + Chrome >> no image patterns to overload');
    return null;
}

function isUbuntu() {
    var dist = env.runCommand('cat /etc/os-release').getOutput();
    if (dist.match(/NAME=.*Ubuntu.*/)) {
        return true;
    }
    return false;
}

function openPdfFile(pdfFileLocation) {
    return new Application(PDF_EDITOR_NAME + ' "' + pdfFileLocation + '"').open();
}

function clickHighlight($selector) {
    _highlight($selector);
    _click($selector);
}

function visibleHighlight($selector) {
    _isVisible($selector);
    _highlight($selector);
}

function cleanupReport($linkname) {
    var $url = reportURL();
    _navigateTo($url);
    clickHighlight(_link($linkname));
    new RegionRectangle(50, 0, 0, 0).mouseMove();
}


function openPrintPreview() {
    new RegionRectangle(500, 500, 0, 0).mouseMove();
    if (_isFF()) {
        env.type("f", Key.ALT).sleep(1).type("v");
    } else {
        env.type("p", Key.CTRL);
    }
}