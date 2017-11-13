//some shared variables
var COMMON_PATH = "../../_common";
var PDF_EDITOR_NAME = "masterpdfeditor4";

function bakeryURL() {
    envUrl = getEnvVar('BAKERY_BAKERY_URL');
    if (!envUrl) {
        envUrl = "http://bakery-web-server:8080/bakery/";
    }
    Logger.logInfo("BAKERY_URL: " + envUrl);
    return envUrl;
}

function reportURL() {
    envUrl = getEnvVar('BAKERY_REPORT_URL');
    if (!envUrl) {
        envUrl = "http://bakery-report-server:8080/report/";
    }
    Logger.logInfo("REPORT_URL: " + envUrl);
    return envUrl;
}

function sleep4Prasentation() {
    return 1;
}

function loadPicsForEnvironment(testCase) {
    testCase.addImagePaths(COMMON_PATH);

    //over load common environmen (centos firefox) if needed
    var envPicFolder = getEnvPicFolder();
    if (envPicFolder != null) {
        testCase.addImagePaths(COMMON_PATH + "/" + envPicFolder);
        testCase.addImagePaths(envPicFolder);
    }
}

function getEnvPicFolder() {
    if (_isChrome()) {
        if (isUbuntu()) {
            Logger.logInfo('Detected environment: Ubuntu + Chrome >> overload some image patterns');
            return "ubuntu_chrome";
        }
        Logger.logInfo('Detected environment: CentOS + Chrome >> overload some image patterns');
        return "centos_chrome"
    }
    if (isUbuntu()) {
        Logger.logInfo('Detected environment: Ubuntu + Firefox >> overload some image patterns');
        return "ubuntu_firefox";
    }
    Logger.logInfo('Detected default environment: CentOS + Firefox >> no image patterns to overload');
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
        env.type("f", Key.ALT).type("v");
    } else {
        env.type("p", Key.CTRL);
    }
}

function getEnvVar(key) {
    var ret = Packages.java.lang.System.getenv(key);
    if (ret == "" || ret == "null") {
        return undefined;
    }
}