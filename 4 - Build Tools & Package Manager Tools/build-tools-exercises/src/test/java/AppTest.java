import com.example.Application;
import org.junit.Test;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;

public class AppTest {

    @Test
    public void testAppOne() {
        Application myApp = new Application();

        String result = myApp.getStatus();

        assertEquals("OK", result);
    }

    @Test
    public void testAppTwo() {
        Application myApp = new Application();

        boolean result = myApp.getCondition("true");

        assertTrue(result);
    }

}
