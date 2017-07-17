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

var $countOfClicks = 3;

try {
    //include some shared functions
    _dynamicInclude("../../_common/common.js");
    loadPicsForEnvironment(testCase);
    var $bakeryURL = bakeryURL();
    var $reportURL = reportURL();
    var $sleep4Prasentation = sleep4Prasentation();

    cleanupReport("Reset blueberry");
    testCase.endOfStep("clean report server", 20);


    _navigateTo($bakeryURL);
    visibleHighlight(_paragraph("Place XXXXXXXX orders:"));
    adjustAmount();
    testCase.endOfStep("move amount slider", 40);

    placeBlueberryOrders();
    testCase.endOfStep("place orders", 30);

    _navigateTo($reportURL);
    validateHtmlReportView();
    testCase.endOfStep("validate report amount", 30);

    //open print preview and validate it
    validatePrintPreview();
    env.sleep($sleep4Prasentation);
    testCase.endOfStep("validate print preview", 45);


} catch (e) {
    testCase.handleException(e);
    // env.sleep(9999);
} finally {
    testCase.saveResult();
}

function adjustAmount() {
    env.setSimilarity(0.99);
    _isVisible("slider-handle min-slider-handle round");
    _assertEqual(15, Number(_getText(_div("slider slider-horizontal"))));

    var bubble = new Region().waitForImage("bubble.png", 20);
    bubble.dragAndDropTo(bubble.right(30)).highlight();
    env.resetSimilarity();

    //assert value of bubble is 20
    _assertEqual(20, Number(_getText(_div("slider slider-horizontal"))));
}


function placeBlueberryOrders() {
    clickHighlight(_label("blueberry"));
    for (i = 0; i < $countOfClicks; i++) {
        env.sleep($sleep4Prasentation);
        clickHighlight(_submit("Place order"));
    }

    env.sleep($sleep4Prasentation);
    var $submittedSpans = _collect("_span", /Submitted 'blueberry' order.*/);

    _assertEqual($countOfClicks, $submittedSpans.length);
    $submittedSpans.forEach(function ($span) {
        _highlight($span);
        _isVisible($span);
    });
}


function validateHtmlReportView() {
    _highlight(_heading1("Cookie Bakery Reporting"));
    env.sleep(3);
    clickHighlight(_link("Reload"));
    _highlight(_span("blueberry"));

    var $blueberryIdentifier = _div("progress-bar[1]");
    _highlight($blueberryIdentifier);
    var $blueberryVal = _getText($blueberryIdentifier);
    Logger.logInfo("blueberry:" + $blueberryVal);
    _assertEqual($countOfClicks * 20, Number($blueberryVal), "Number of blueberry orders does not fit!");
    //also do screen varification
    screen.find("pic_blueberries.png").grow(50).highlight().find("web_blueberry_60.png").highlight();
    env.sleep($sleep4Prasentation);
}


function validatePrintPreview() {
    openPrintPreview();
    screen.waitForImage("report_header.png", 60).highlight();
    screen.find("print_pic_blueberries.png").highlight();
    var blueberryRegion = screen.find("report_blueberry.png").highlight();
    var blueberryValueRegion = blueberryRegion.below(100).highlight().find("report_value_60.png").highlight();

    var ocrValue = blueberryValueRegion.extractText();   //experimental works only on a few font arts
    Logger.logInfo("blueberry value: " + ocrValue);
}
