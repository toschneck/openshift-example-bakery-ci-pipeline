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
var testCase = new TestCase(60, 70);
var env = new Environment();
var screen = new Region();

var $countOfClicks = 4;

try {
    //include some shared functions
    _dynamicInclude("../../_common/common.js");
    loadPicsForEnvironment(testCase);
    var $bakeryURL = bakeryURL();
    var $reportURL = reportURL();
    var $sleep4Prasentation = sleep4Prasentation();

    cleanupReport("Reset caramel");
    testCase.endOfStep("clean report server", 20);


    _navigateTo($bakeryURL);
    visibleHighlight(_paragraph("Place new orders:"));
    adjustAmount();
    testCase.endOfStep("move amount slider", 40);

    placeCaramelOrder();
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
    bubble.dragAndDropTo(bubble.right(135)).highlight();
    env.resetSimilarity();

    //assert value of bubble is 30
    _assertEqual(30, Number(_getText(_div("slider slider-horizontal"))));
}


function placeCaramelOrder() {
    clickHighlight(_label("caramel"));
    for (i = 0; i < $countOfClicks; i++) {
        env.sleep($sleep4Prasentation);
        clickHighlight(_submit("Place order"));
    }

    env.sleep($sleep4Prasentation);
    var $submittedSpans = _collect("_span", /Submitted 'caramel' order.*/);

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
    _highlight(_span("caramel"));

    var $caramelReportIdentifier = _div("progress-bar[2]");
    _highlight($caramelReportIdentifier);
    var $caramelValue = _getText($caramelReportIdentifier);
    Logger.logInfo("caramel:" + $caramelValue);
    _assertEqual($countOfClicks * 30, Number($caramelValue), "Number of caramel orders does not fit!");
    //also do screen varification
    screen.find("pic_caramel.png").grow(50).highlight().find("web_caramel_120.png").highlight();
    env.sleep($sleep4Prasentation);
}


function validatePrintPreview() {
    openPrintPreview();
    screen.waitForImage("report_header.png", 60).highlight();
    screen.find("print_pic_caramel.png").highlight();
    var caramelRegion = screen.find("report_caramel.png").highlight();
    var caramelValueRegion = caramelRegion.below(100).highlight().find("report_value_120.png").highlight();

    var ocrValue = caramelValueRegion.extractText();   //experimental works only on a few font arts
    Logger.logInfo("caramel value: " + ocrValue);
}