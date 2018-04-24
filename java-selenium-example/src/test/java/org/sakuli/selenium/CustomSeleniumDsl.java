package org.sakuli.selenium; /**
 * @author tschneck
 * Date: 1/23/17
 */

import org.openqa.selenium.JavascriptExecutor;
import org.openqa.selenium.WebElement;

//import com.project.setup.WebDriverManager;

public class CustomSeleniumDsl {

    private JavascriptExecutor javascriptExecutor;

    public CustomSeleniumDsl(JavascriptExecutor javascriptExecutor) {
        this.javascriptExecutor = javascriptExecutor;
    }

    public void highlightElement(WebElement element) {
        javascriptExecutor.executeScript("arguments[0].setAttribute('style', arguments[1]);", element, "color: red; border: 2px solid red;");
        try {
            Thread.sleep(500L);
        } catch (InterruptedException e) {
            //ignore
        }
        javascriptExecutor.executeScript("arguments[0].setAttribute('style', arguments[1]);", element, "");
    }
}
