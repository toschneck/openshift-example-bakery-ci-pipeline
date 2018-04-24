package org.sakuli.example.github;

import org.sakuli.actions.screenbased.Key;
import org.sakuli.example.AbstractSakuliSeTest;
import org.sakuli.selenium.testng.SakuliTestCase;
import org.testng.annotations.Test;

/**
 * Test the website of the Citrus integration testing framework.
 *
 * @author tschneck
 * Date: 12/2/15
 */
public class GitHubSakuliSeExampleTest extends AbstractSakuliSeTest {

    private static final String SAKULI_URL = "https://github.com/ConSol/sakuli/blob/master/README.adoc";

    @Test
    @SakuliTestCase(additionalImagePaths = "/common_pics")
    public void test1() throws Exception {
        //your test code
        driver.get(SAKULI_URL);
        screen.highlight(5);
        screen.find("sakuli_logo.png").highlight();
    }

    @Test
    @SakuliTestCase(testCaseName = "mysecondtest", warningTime = 15, criticalTime = 25, additionalImagePaths = "/common_pics")
    public void test2() throws Exception {
        //your test code
        driver.get(SAKULI_URL);
        screen.highlight(5);
        screen.type(Key.END).find("github_logo.png").highlight();
    }

}