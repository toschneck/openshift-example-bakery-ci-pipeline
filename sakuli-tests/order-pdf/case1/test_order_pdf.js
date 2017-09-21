/*
 * Sakuli - Testing and Monitoring-Tool for Websites and common UIs.
 *
 * Copyright 2013 - 2015 the original author or authors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

_dynamicInclude($includeFolder);
var testCase = new TestCase(80, 100);
var env = new Environment();
var screen = new Region();
var appPDF;

var pdfFilePath = "/tmp/bakery.pdf";

try {
    if (!_isChrome()) {
        throw "this case is only designed for the chrome pdf generating function";
    }
    //include some shared functions
    _dynamicInclude("../../_common/common.js");
    loadPicsForEnvironment(testCase);
    var $bakeryURL = bakeryURL();
    var $sleep4Prasentation = sleep4Prasentation();

    _navigateTo($bakeryURL);
    visibleHighlight(_heading1("Cookie Bakery Application"));

    [
        _label("chocolate"),
        _label("blueberry"),
        _label("caramel")]
        .forEach(function ($identifier) {
            visibleHighlight($identifier);
        });
    env.sleep($sleep4Prasentation);
    testCase.endOfStep("validate HTML view", 30);

    //open print preview
    env.type("p", Key.CTRL);


    //rotate to landscape
    screen.waitForImage("layout_label.png", 30).highlight()
        .right(140).highlight().click()
        .grow(0, 40)
        .find("landscape.png").click();
    env.sleep($sleep4Prasentation);
    testCase.endOfStep("rotate to landscap", 30);

    //save as pdf
    screen.find("save_button").highlight().click();
    env.sleep($sleep4Prasentation);
    env.type("a", Key.CTRL) //mark filename in "save under" dialog
        .type(pdfFilePath + Key.ENTER) //type filename and press ENTER
        .sleep($sleep4Prasentation);

    //open pdf and validate
    appPDF = openPdfFile(pdfFilePath);
    env.sleep($sleep4Prasentation);
    var warn = screen.exists("masterpdf_update_warning", 5);
    if (warn){
        warn.highlight().click().type(Key.ESC);
    }
    screen.waitForImage("pdf_order_header", 30).highlight();
    [
        "pdf_blueberry",
        "pdf_caramel",
        "pdf_chocolate",
        "pdf_place_order"
    ].forEach(function (imgPattern) {
        screen.find(imgPattern).highlight();
    });
    testCase.endOfStep("validate PDF output", 50);

} catch (e) {
    testCase.handleException(e);
    // env.sleep(9999);
} finally {
    if (undefined != appPDF) {
        appPDF.kill(true);
    }
    testCase.saveResult();
}
