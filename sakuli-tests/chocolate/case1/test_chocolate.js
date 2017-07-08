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

var $countOfClicks = 2;

try {
    //include some shared functions
    _dynamicInclude("../../_common/common.js");
    loadPicsForEnvironment(testCase);
    var $bakeryURL = bakeryURL();
    var $reportURL = reportURL();
    var $sleep4Prasentation = sleep4Prasentation();

    cleanupReport("Reset chocolate");
    testCase.endOfStep("clean report server", 20);

    _navigateTo($bakeryURL);
    visibleHighlight(_paragraph("Place new orders:"));
    adjustAmount();
    testCase.endOfStep("move amount slider", 40);

    placeChocolateOrder();
    testCase.endOfStep("place orders", 30);

    _navigateTo($reportURL);
    validateHtmlReportView();
    testCase.endOfStep("validate report amount", 30);

    //open print preview and validate it
    validatePrintPreview();
    env.sleep($sleep4Prasentation);
    testCase.endOfStep("validate print preview", 50);


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
    bubble.dragAndDropTo(bubble.left(35)).highlight();
    env.resetSimilarity();

    //assert value of bubble is 10
    _assertEqual(10, Number(_getText(_div("slider slider-horizontal"))));
}


function placeChocolateOrder() {
    clickHighlight(_label("chocolate"));
    for (i = 0; i < $countOfClicks; i++) {
        env.sleep($sleep4Prasentation);
        clickHighlight(_submit("Place order"));
    }

    env.sleep($sleep4Prasentation);
    var $submittedSpans = _collect("_span", /Submitted 'chocolate' order.*/);

    _assertEqual($countOfClicks, $submittedSpans.length);
    $submittedSpans.forEach(function ($span) {
        _highlight($span);
        _isVisible($span);
    });
}


function validateHtmlReportView() {
    _highlight(_heading1("Cookie Bakery Reporting"));
    clickHighlight(_link("Reload"));
    _highlight(_span("chocolate"));

    var $chocolateReportIdentifier = _div("progress-bar[0]");
    _highlight($chocolateReportIdentifier);
    var $chocolateValue = _getText($chocolateReportIdentifier);
    Logger.logInfo("chocolate:" + $chocolateValue);
    _assertEqual($countOfClicks * 10, Number($chocolateValue), "Number of chocolate orders does not fit!");
    //also do screen varification
    screen.find("pic_chocolate.png").grow(50).highlight().find("web_chocolate_20.png").highlight();
    env.sleep($sleep4Prasentation);
}


function validatePrintPreview() {
    openPrintPreview();
    screen.waitForImage("report_header.png", 60).highlight();
    screen.find("report_pic_chocolate.png").highlight();
    var chocolateRegion = screen.find("report_chocolate.png").highlight();
    var chocolateValueRegion = chocolateRegion.below(100).highlight().find("report_value_20.png").highlight();

    var ocrValue = chocolateValueRegion.extractText();   //experimental works only on a few font arts
    Logger.logInfo("chocolate value: " + ocrValue);
}
