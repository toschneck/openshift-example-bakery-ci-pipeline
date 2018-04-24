package org.sakuli.example;

import org.openqa.selenium.JavascriptExecutor;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.firefox.FirefoxDriver;
import org.openqa.selenium.remote.RemoteWebDriver;
import org.sakuli.actions.environment.Environment;
import org.sakuli.actions.screenbased.Region;
import org.sakuli.datamodel.properties.TestSuiteProperties;
import org.sakuli.exceptions.SakuliActionException;
import org.sakuli.exceptions.SakuliRuntimeException;
import org.sakuli.selenium.CustomSeleniumDsl;
import org.sakuli.selenium.actions.testcase.SeTestCaseAction;
import org.sakuli.selenium.testng.SakuliSeTest;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.testng.annotations.AfterMethod;
import org.testng.annotations.BeforeMethod;
import org.testng.annotations.Listeners;

import java.util.Optional;
import java.util.function.Supplier;

/**
 * @author tschneck
 * Date: 1/23/17
 */
@Listeners(SakuliSeTest.class)
public abstract class AbstractSakuliSeTest {
    private static Logger LOGGER = LoggerFactory.getLogger(AbstractSakuliSeTest.class);
    protected WebDriver driver;
    protected CustomSeleniumDsl dsl;
    protected Region screen;
    protected Environment env;
    protected SeTestCaseAction tcAction;

    public static boolean isTargetEnvironment(String distro) {
        try {
            if (Environment.runCommand("cat /etc/lsb-release", false).getOutput()
                    .contains(distro)) {
                return true;
            }
        } catch (Exception e) {
            //just log
            LOGGER.warn("Error on identify target environment", e);
        }
        return false;

    }

    private RemoteWebDriver getSeleniumDriver() {
        final String browserName = env.getProperty(TestSuiteProperties.BROWSER_NAME);
        switch (browserName) {
            case "chrome":
                return new ChromeDriver();
            case "firefox":
                return new FirefoxDriver();
        }
        throw new SakuliRuntimeException("Browser '" + browserName + "' not defined!");
    }

    @BeforeMethod
    public void setUp() throws Exception {
        env = new Environment();
        driver = getSeleniumDriver();
        dsl = new CustomSeleniumDsl((JavascriptExecutor) driver);
        screen = new Region();
        tcAction = new SeTestCaseAction();
    }

    @AfterMethod(alwaysRun = true)
    public void tearDown() throws Exception {
        if (driver != null)
            driver.close();
    }

    public void scroll(Supplier<Region> check, Supplier doScroll, int times) throws SakuliActionException {
        for (int i = 1; !Optional.ofNullable(check.get()).isPresent() && i <= times; i++) {
            LOGGER.info("Scroll page ({})", i);
            doScroll.get();
        }
        Optional.ofNullable(check.get()).orElseThrow(() ->
                new SakuliActionException("Cannot find region by scrooling!")).highlight();
    }
}
