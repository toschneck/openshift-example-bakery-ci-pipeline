package org.sakuli.example.citrus;

import org.openqa.selenium.By;
import org.openqa.selenium.JavascriptExecutor;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.chrome.ChromeDriver;
import org.sakuli.selenium.CustomSeleniumDsl;
import org.testng.annotations.AfterMethod;
import org.testng.annotations.BeforeMethod;
import org.testng.annotations.Test;

import static org.testng.Assert.assertEquals;
import static org.testng.Assert.assertTrue;

/**
 * Test the website of the Citrus integration testing framework.
 *
 * @author tschneck
 * Date: 12/2/15
 */
public class CitrusHtmSeleniumTest {

    private static final String CITRUS_URL = "http://www.citrusframework.org/";
    private WebDriver driver;
    private CustomSeleniumDsl dsl;

    @BeforeMethod
    public void setUp() {
        driver = new ChromeDriver();
        dsl = new CustomSeleniumDsl((JavascriptExecutor) driver);
    }

    @Test
    public void testCitrusHtmlContent() throws Exception {
        driver.get(CITRUS_URL);

        //find Heading
        WebElement heading1 = driver.findElement(By.cssSelector("p.first"));
        dsl.highlightElement(heading1);
        assertEquals(heading1.getText(), "Citrus Integration\nTesting");
        assertTrue(heading1.isDisplayed());

        //validate HTML content
        WebElement heading2 = driver.findElement(By.tagName("h1"));
        dsl.highlightElement(heading2);
        assertEquals(heading2.getText(), "Integration challenge");
        assertTrue(heading2.isDisplayed());
    }

    @AfterMethod
    public void tearDown() {
        driver.close();
    }
}