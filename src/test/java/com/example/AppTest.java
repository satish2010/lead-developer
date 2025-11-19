package com.example;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

/**
 * Unit test for App class
 */
public class AppTest {
    @Test
    public void testApp() {
        // Test passes if no exception is thrown
        App.main(new String[]{});
        assertTrue(true);
    }
}
