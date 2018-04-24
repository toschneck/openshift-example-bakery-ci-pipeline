package org.sakuli.example.citrus;

import org.openqa.selenium.By;
import org.openqa.selenium.WebElement;
import org.sakuli.actions.screenbased.Key;
import org.sakuli.example.AbstractSakuliSeTest;
import org.sakuli.selenium.testng.SakuliTestCase;
import org.testng.annotations.Test;

import static org.testng.Assert.assertEquals;
import static org.testng.Assert.assertTrue;

/**
 * Test the website of the Citrus integration testing framework.
 *
 * @author tschneck
 * Date: 12/2/15
 */
public class CitrusHtmlPdfTest extends AbstractSakuliSeTest {

    private static final String CITRUS_URL = "http://www.citrusframework.org/";
    private static int hSec = 2;

    @Test
    @SakuliTestCase(additionalImagePaths = "citrus_pics")
    public void testLogos() throws Exception {
        searchHeading();
        screen.find("citrus_logo.png").highlight(hSec);
        screen.type(Key.END).find("consol_logo.png").highlight(hSec);
    }

    @Test
    @SakuliTestCase
    public void testCitrusHtmlContent() throws Exception {
        testCitrusContent("HTML");

        //validate HTML content
        WebElement heading = driver.findElement(By.tagName("h1"));
        dsl.highlightElement(heading);
        assertEquals(heading.getText(), "Citrus");
        assertTrue(heading.isDisplayed());
        WebElement author = driver.findElement(By.className("author"));
        dsl.highlightElement(author);
        assertEquals(author.getText(), "Christoph Deppisch");
        assertTrue(author.isDisplayed());
    }

    @Test
    @SakuliTestCase(additionalImagePaths = "citrus_pics")
    public void testCitrusPdfContent() throws Exception {

        //opens PDF download page and click download
        testCitrusContent("PDF");
        screen.find("reload_button.png").highlight();

        scroll( //search citrus logo on PDF
                () -> screen.exists("pdf_citrus_title.png", 1),
                //scroll action
                () -> env.type(Key.DOWN).type(Key.DOWN).type(Key.DOWN).type(Key.DOWN),
                //times to try
                10
        );
        env.sleep(hSec);

        //navigate over bookmark menu of PDF viewer
        screen.find("reload_button.png")
                .below(40).highlight()
                .mouseMove();
        screen.find("bookmark_button.png").highlight().click();
        screen.find("bookmark_entry.png").highlight().click();
        screen.find("test_case_pdf_heading.png").highlight().click();

        //scroll until the expected diagram is visible
        scroll(() -> screen.exists("test_case_diagram.png", 1),
                () -> env.type(Key.DOWN).type(Key.DOWN).type(Key.DOWN).type(Key.DOWN),
                10
        );
    }

    public void testCitrusContent(String dest) throws Exception {
        searchHeading();

        WebElement docuLink = driver.findElement(By.partialLinkText("DOCUMENTATION"));
        dsl.highlightElement(docuLink);
        assertTrue(docuLink.isDisplayed());
        docuLink.click();

        WebElement userGuideLink = driver.findElement(By.partialLinkText("User Guide"));
        dsl.highlightElement(userGuideLink);
        assertTrue(userGuideLink.isDisplayed());
        userGuideLink.click();

        WebElement htmlUserGuideLink = driver.findElement(By.partialLinkText(dest));
        dsl.highlightElement(htmlUserGuideLink);
        assertTrue(htmlUserGuideLink.isDisplayed());
        htmlUserGuideLink.click();
    }

    private void searchHeading() {
        driver.get(CITRUS_URL);
        WebElement heading1 = driver.findElement(By.cssSelector("p.first"));
        dsl.highlightElement(heading1);
        assertTrue(heading1.isDisplayed());
    }


}