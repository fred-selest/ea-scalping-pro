//+------------------------------------------------------------------+
//| test_position_counting.mq5                                       |
//| Unit tests for position counting logic                           |
//+------------------------------------------------------------------+
#property copyright "EA Scalping Pro Team"
#property link      "https://github.com/fred-selest/ea-scalping-pro"
#property version   "1.00"
#property script_show_inputs

// Mock position data structure
struct MockPosition {
   ulong ticket;
   string symbol;
   long magic;
   int type; // POSITION_TYPE_BUY or POSITION_TYPE_SELL
};

// Global mock position array
MockPosition g_mock_positions[];
int g_mock_count = 0;
long g_test_magic = 270520;

// Test helper functions
bool AssertEquals(int expected, int actual, string test_name) {
   if(expected == actual) {
      Print("✅ PASS: ", test_name, " (Expected: ", expected, ", Got: ", actual, ")");
      return true;
   } else {
      Print("❌ FAIL: ", test_name, " (Expected: ", expected, ", Got: ", actual, ")");
      return false;
   }
}

bool AssertTrue(bool condition, string test_name) {
   if(condition) {
      Print("✅ PASS: ", test_name);
      return true;
   } else {
      Print("❌ FAIL: ", test_name);
      return false;
   }
}

// Mock position management functions
void ClearMockPositions() {
   ArrayResize(g_mock_positions, 0);
   g_mock_count = 0;
}

void AddMockPosition(string symbol, long magic, int type = POSITION_TYPE_BUY) {
   int size = ArraySize(g_mock_positions);
   ArrayResize(g_mock_positions, size + 1);
   g_mock_positions[size].ticket = size + 1000;
   g_mock_positions[size].symbol = symbol;
   g_mock_positions[size].magic = magic;
   g_mock_positions[size].type = type;
   g_mock_count++;
}

// Replicate CountPositions logic with mock data
int CountPositionsMock(string symbol_filter = "", int max_count = 0, long magic_filter = 0) {
   int count = 0;
   int total = g_mock_count;

   // If max_count not specified, use a very high number
   if(max_count == 0) max_count = 999999;

   if(magic_filter == 0) magic_filter = g_test_magic;

   for(int i = total - 1; i >= 0; i--) {
      // Early exit optimization
      if(count >= max_count) break;

      // Check magic number
      if(g_mock_positions[i].magic != magic_filter) continue;

      // If symbol filter specified, check it
      if(symbol_filter != "" && g_mock_positions[i].symbol != symbol_filter) continue;

      count++;
   }

   return count;
}

// Test GetTotalPositions logic
int GetTotalPositionsMock(int MaxOpenPositions) {
   return CountPositionsMock("", MaxOpenPositions);
}

// Test GetSymbolPositions logic
int GetSymbolPositionsMock(string symbol, int MaxPositionsPerSymbol) {
   return CountPositionsMock(symbol, MaxPositionsPerSymbol);
}

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
   Print("╔════════════════════════════════════════════════════════════╗");
   Print("║  Test Suite: Position Counting Logic                      ║");
   Print("╚════════════════════════════════════════════════════════════╝");
   Print("");

   int passed = 0;
   int failed = 0;

   // === Test Category 1: Empty Position Set ===
   Print("─────────────────────────────────────────────────────────────");
   Print("📊 Test Category: EMPTY POSITION SET");
   Print("─────────────────────────────────────────────────────────────");

   ClearMockPositions();

   if(AssertEquals(0, CountPositionsMock(), "CountPositions() with no positions")) passed++; else failed++;
   if(AssertEquals(0, CountPositionsMock("EURUSD"), "CountPositions('EURUSD') with no positions")) passed++; else failed++;
   if(AssertEquals(0, GetTotalPositionsMock(10), "GetTotalPositions() with no positions")) passed++; else failed++;
   if(AssertEquals(0, GetSymbolPositionsMock("EURUSD", 3), "GetSymbolPositions() with no positions")) passed++; else failed++;

   Print("");

   // === Test Category 2: Single Position ===
   Print("─────────────────────────────────────────────────────────────");
   Print("📊 Test Category: SINGLE POSITION");
   Print("─────────────────────────────────────────────────────────────");

   ClearMockPositions();
   AddMockPosition("EURUSD", g_test_magic, POSITION_TYPE_BUY);

   if(AssertEquals(1, CountPositionsMock(), "CountPositions() with 1 position")) passed++; else failed++;
   if(AssertEquals(1, CountPositionsMock("EURUSD"), "CountPositions('EURUSD') with 1 EURUSD position")) passed++; else failed++;
   if(AssertEquals(0, CountPositionsMock("GBPUSD"), "CountPositions('GBPUSD') with 0 GBPUSD positions")) passed++; else failed++;
   if(AssertEquals(1, GetTotalPositionsMock(10), "GetTotalPositions() = 1")) passed++; else failed++;
   if(AssertEquals(1, GetSymbolPositionsMock("EURUSD", 3), "GetSymbolPositions('EURUSD') = 1")) passed++; else failed++;
   if(AssertEquals(0, GetSymbolPositionsMock("GBPUSD", 3), "GetSymbolPositions('GBPUSD') = 0")) passed++; else failed++;

   Print("");

   // === Test Category 3: Multiple Positions Same Symbol ===
   Print("─────────────────────────────────────────────────────────────");
   Print("📊 Test Category: MULTIPLE POSITIONS SAME SYMBOL");
   Print("─────────────────────────────────────────────────────────────");

   ClearMockPositions();
   AddMockPosition("EURUSD", g_test_magic, POSITION_TYPE_BUY);
   AddMockPosition("EURUSD", g_test_magic, POSITION_TYPE_BUY);
   AddMockPosition("EURUSD", g_test_magic, POSITION_TYPE_SELL);

   if(AssertEquals(3, CountPositionsMock(), "CountPositions() with 3 positions")) passed++; else failed++;
   if(AssertEquals(3, CountPositionsMock("EURUSD"), "CountPositions('EURUSD') = 3")) passed++; else failed++;
   if(AssertEquals(0, CountPositionsMock("GBPUSD"), "CountPositions('GBPUSD') = 0")) passed++; else failed++;
   if(AssertEquals(3, GetTotalPositionsMock(10), "GetTotalPositions() = 3")) passed++; else failed++;
   if(AssertEquals(3, GetSymbolPositionsMock("EURUSD", 10), "GetSymbolPositions('EURUSD') = 3")) passed++; else failed++;

   Print("");

   // === Test Category 4: Multiple Positions Different Symbols ===
   Print("─────────────────────────────────────────────────────────────");
   Print("📊 Test Category: MULTIPLE POSITIONS DIFFERENT SYMBOLS");
   Print("─────────────────────────────────────────────────────────────");

   ClearMockPositions();
   AddMockPosition("EURUSD", g_test_magic, POSITION_TYPE_BUY);
   AddMockPosition("EURUSD", g_test_magic, POSITION_TYPE_BUY);
   AddMockPosition("GBPUSD", g_test_magic, POSITION_TYPE_BUY);
   AddMockPosition("USDJPY", g_test_magic, POSITION_TYPE_SELL);
   AddMockPosition("AUDUSD", g_test_magic, POSITION_TYPE_BUY);

   if(AssertEquals(5, CountPositionsMock(), "CountPositions() total = 5")) passed++; else failed++;
   if(AssertEquals(2, CountPositionsMock("EURUSD"), "CountPositions('EURUSD') = 2")) passed++; else failed++;
   if(AssertEquals(1, CountPositionsMock("GBPUSD"), "CountPositions('GBPUSD') = 1")) passed++; else failed++;
   if(AssertEquals(1, CountPositionsMock("USDJPY"), "CountPositions('USDJPY') = 1")) passed++; else failed++;
   if(AssertEquals(1, CountPositionsMock("AUDUSD"), "CountPositions('AUDUSD') = 1")) passed++; else failed++;
   if(AssertEquals(0, CountPositionsMock("NZDUSD"), "CountPositions('NZDUSD') = 0")) passed++; else failed++;

   if(AssertEquals(5, GetTotalPositionsMock(10), "GetTotalPositions() = 5")) passed++; else failed++;
   if(AssertEquals(2, GetSymbolPositionsMock("EURUSD", 10), "GetSymbolPositions('EURUSD') = 2")) passed++; else failed++;
   if(AssertEquals(1, GetSymbolPositionsMock("GBPUSD", 10), "GetSymbolPositions('GBPUSD') = 1")) passed++; else failed++;

   Print("");

   // === Test Category 5: Magic Number Filtering ===
   Print("─────────────────────────────────────────────────────────────");
   Print("📊 Test Category: MAGIC NUMBER FILTERING");
   Print("─────────────────────────────────────────────────────────────");

   ClearMockPositions();
   AddMockPosition("EURUSD", g_test_magic, POSITION_TYPE_BUY);     // Belongs to EA
   AddMockPosition("EURUSD", g_test_magic, POSITION_TYPE_BUY);     // Belongs to EA
   AddMockPosition("EURUSD", 12345, POSITION_TYPE_BUY);            // Different magic
   AddMockPosition("GBPUSD", g_test_magic, POSITION_TYPE_SELL);    // Belongs to EA
   AddMockPosition("GBPUSD", 99999, POSITION_TYPE_BUY);            // Different magic

   if(AssertEquals(3, CountPositionsMock("", 0, g_test_magic), "CountPositions() with EA magic = 3")) passed++; else failed++;
   if(AssertEquals(2, CountPositionsMock("", 0, 12345), "CountPositions() with magic 12345 = 1")) passed++; else failed++;
   if(AssertEquals(2, CountPositionsMock("EURUSD", 0, g_test_magic), "CountPositions('EURUSD') EA magic = 2")) passed++; else failed++;
   if(AssertEquals(1, CountPositionsMock("EURUSD", 0, 12345), "CountPositions('EURUSD') magic 12345 = 1")) passed++; else failed++;

   if(AssertEquals(3, GetTotalPositionsMock(10), "GetTotalPositions() ignores other magics = 3")) passed++; else failed++;
   if(AssertEquals(2, GetSymbolPositionsMock("EURUSD", 10), "GetSymbolPositions('EURUSD') ignores other magics = 2")) passed++; else failed++;

   Print("");

   // === Test Category 6: Early Exit Optimization (max_count) ===
   Print("─────────────────────────────────────────────────────────────");
   Print("📊 Test Category: EARLY EXIT OPTIMIZATION");
   Print("─────────────────────────────────────────────────────────────");

   ClearMockPositions();
   AddMockPosition("EURUSD", g_test_magic);
   AddMockPosition("EURUSD", g_test_magic);
   AddMockPosition("EURUSD", g_test_magic);
   AddMockPosition("GBPUSD", g_test_magic);
   AddMockPosition("GBPUSD", g_test_magic);
   AddMockPosition("USDJPY", g_test_magic);
   AddMockPosition("USDJPY", g_test_magic);
   AddMockPosition("USDJPY", g_test_magic);
   AddMockPosition("AUDUSD", g_test_magic);
   AddMockPosition("AUDUSD", g_test_magic);
   // Total: 10 positions

   // Test early exit with max_count
   if(AssertEquals(5, CountPositionsMock("", 5), "CountPositions() max=5, stops at 5")) passed++; else failed++;
   if(AssertEquals(3, CountPositionsMock("", 3), "CountPositions() max=3, stops at 3")) passed++; else failed++;
   if(AssertEquals(1, CountPositionsMock("", 1), "CountPositions() max=1, stops at 1")) passed++; else failed++;
   if(AssertEquals(10, CountPositionsMock("", 0), "CountPositions() max=0 (unlimited), returns all 10")) passed++; else failed++;
   if(AssertEquals(10, CountPositionsMock("", 999), "CountPositions() max=999, returns all 10")) passed++; else failed++;

   // Test GetTotalPositions with MaxOpenPositions limit
   if(AssertEquals(5, GetTotalPositionsMock(5), "GetTotalPositions() with MaxOpen=5, stops at 5")) passed++; else failed++;
   if(AssertEquals(10, GetTotalPositionsMock(20), "GetTotalPositions() with MaxOpen=20, returns all 10")) passed++; else failed++;

   // Test GetSymbolPositions with MaxPositionsPerSymbol limit
   if(AssertEquals(2, GetSymbolPositionsMock("EURUSD", 2), "GetSymbolPositions('EURUSD') max=2, stops at 2")) passed++; else failed++;
   if(AssertEquals(3, GetSymbolPositionsMock("EURUSD", 10), "GetSymbolPositions('EURUSD') max=10, returns all 3")) passed++; else failed++;
   if(AssertEquals(1, GetSymbolPositionsMock("USDJPY", 1), "GetSymbolPositions('USDJPY') max=1, stops at 1")) passed++; else failed++;

   Print("");

   // === Test Category 7: Edge Cases ===
   Print("─────────────────────────────────────────────────────────────");
   Print("📊 Test Category: EDGE CASES");
   Print("─────────────────────────────────────────────────────────────");

   // Empty symbol filter
   ClearMockPositions();
   AddMockPosition("EURUSD", g_test_magic);
   AddMockPosition("GBPUSD", g_test_magic);

   if(AssertEquals(2, CountPositionsMock(""), "CountPositions('') empty string = all positions")) passed++; else failed++;

   // Symbol case sensitivity
   if(AssertEquals(1, CountPositionsMock("EURUSD"), "CountPositions('EURUSD') uppercase")) passed++; else failed++;
   if(AssertEquals(0, CountPositionsMock("eurusd"), "CountPositions('eurusd') lowercase (case sensitive)")) passed++; else failed++;

   // Non-existent symbol
   if(AssertEquals(0, CountPositionsMock("XYZXYZ"), "CountPositions('XYZXYZ') non-existent symbol")) passed++; else failed++;

   // Boundary: max_count = 0 (should count all)
   ClearMockPositions();
   for(int i = 0; i < 100; i++) {
      AddMockPosition("EURUSD", g_test_magic);
   }
   if(AssertEquals(100, CountPositionsMock("", 0), "CountPositions() max=0 with 100 positions")) passed++; else failed++;

   // Boundary: Exactly at max_count
   if(AssertEquals(50, CountPositionsMock("", 50), "CountPositions() max=50 with 100 positions")) passed++; else failed++;

   Print("");

   // === Test Category 8: Real-World Scenarios ===
   Print("─────────────────────────────────────────────────────────────");
   Print("📊 Test Category: REAL-WORLD SCENARIOS");
   Print("─────────────────────────────────────────────────────────────");

   // Scenario 1: Conservative profile (MaxOpen=2, PerSymbol=1)
   ClearMockPositions();
   AddMockPosition("EURUSD", g_test_magic);
   AddMockPosition("GBPUSD", g_test_magic);

   int total_conservative = GetTotalPositionsMock(2);
   int eurusd_conservative = GetSymbolPositionsMock("EURUSD", 1);
   int gbpusd_conservative = GetSymbolPositionsMock("GBPUSD", 1);

   if(AssertEquals(2, total_conservative, "Conservative: Total positions = 2")) passed++; else failed++;
   if(AssertEquals(1, eurusd_conservative, "Conservative: EURUSD positions = 1")) passed++; else failed++;
   if(AssertEquals(1, gbpusd_conservative, "Conservative: GBPUSD positions = 1")) passed++; else failed++;
   if(AssertTrue(total_conservative <= 2, "Conservative: Within MaxOpenPositions limit")) passed++; else failed++;
   if(AssertTrue(eurusd_conservative <= 1, "Conservative: EURUSD within limit")) passed++; else failed++;

   // Scenario 2: Moderate profile (MaxOpen=5, PerSymbol=2)
   ClearMockPositions();
   AddMockPosition("EURUSD", g_test_magic);
   AddMockPosition("EURUSD", g_test_magic);
   AddMockPosition("GBPUSD", g_test_magic);
   AddMockPosition("USDJPY", g_test_magic);
   AddMockPosition("AUDUSD", g_test_magic);

   int total_moderate = GetTotalPositionsMock(5);
   int eurusd_moderate = GetSymbolPositionsMock("EURUSD", 2);

   if(AssertEquals(5, total_moderate, "Moderate: Total positions = 5")) passed++; else failed++;
   if(AssertEquals(2, eurusd_moderate, "Moderate: EURUSD positions = 2")) passed++; else failed++;
   if(AssertTrue(total_moderate <= 5, "Moderate: Within MaxOpenPositions limit")) passed++; else failed++;
   if(AssertTrue(eurusd_moderate <= 2, "Moderate: EURUSD within limit")) passed++; else failed++;

   // Scenario 3: Aggressive profile (MaxOpen=10, PerSymbol=3)
   ClearMockPositions();
   AddMockPosition("EURUSD", g_test_magic);
   AddMockPosition("EURUSD", g_test_magic);
   AddMockPosition("EURUSD", g_test_magic);
   AddMockPosition("GBPUSD", g_test_magic);
   AddMockPosition("GBPUSD", g_test_magic);
   AddMockPosition("USDJPY", g_test_magic);
   AddMockPosition("USDJPY", g_test_magic);
   AddMockPosition("AUDUSD", g_test_magic);
   AddMockPosition("USDCAD", g_test_magic);
   AddMockPosition("NZDUSD", g_test_magic);

   int total_aggressive = GetTotalPositionsMock(10);
   int eurusd_aggressive = GetSymbolPositionsMock("EURUSD", 3);

   if(AssertEquals(10, total_aggressive, "Aggressive: Total positions = 10")) passed++; else failed++;
   if(AssertEquals(3, eurusd_aggressive, "Aggressive: EURUSD positions = 3")) passed++; else failed++;
   if(AssertTrue(total_aggressive <= 10, "Aggressive: Within MaxOpenPositions limit")) passed++; else failed++;
   if(AssertTrue(eurusd_aggressive <= 3, "Aggressive: EURUSD within limit")) passed++; else failed++;

   // Scenario 4: Position limit prevents new trade
   ClearMockPositions();
   AddMockPosition("EURUSD", g_test_magic);
   AddMockPosition("EURUSD", g_test_magic);
   AddMockPosition("GBPUSD", g_test_magic);
   AddMockPosition("USDJPY", g_test_magic);
   AddMockPosition("AUDUSD", g_test_magic);

   int check_total = GetTotalPositionsMock(5);
   int check_eurusd = GetSymbolPositionsMock("EURUSD", 2);

   bool can_open_new_position = (check_total < 5);
   bool can_open_eurusd = (check_eurusd < 2);
   bool can_open_gbpusd = (GetSymbolPositionsMock("GBPUSD", 2) < 2);

   if(AssertFalse(can_open_new_position, "Scenario: Cannot open new (MaxOpen reached)")) passed++; else failed++;
   if(AssertFalse(can_open_eurusd, "Scenario: Cannot open EURUSD (PerSymbol reached)")) passed++; else failed++;
   if(AssertTrue(can_open_gbpusd, "Scenario: Can open GBPUSD (PerSymbol limit)")) passed++; else failed++;

   Print("");

   // === Test Category 9: Performance Tests ===
   Print("─────────────────────────────────────────────────────────────");
   Print("📊 Test Category: PERFORMANCE");
   Print("─────────────────────────────────────────────────────────────");

   // Test with large number of positions
   ClearMockPositions();
   for(int i = 0; i < 500; i++) {
      AddMockPosition("EURUSD", g_test_magic);
   }
   for(int i = 0; i < 500; i++) {
      AddMockPosition("GBPUSD", g_test_magic);
   }
   // Total: 1000 positions

   datetime start = TimeCurrent();
   int result = CountPositionsMock("EURUSD", 0);
   datetime end = TimeCurrent();

   if(AssertEquals(500, result, "Performance: Count 500 EURUSD in 1000 total")) passed++; else failed++;
   Print("   Execution time: ", (end - start), " seconds");

   // Test early exit optimization benefit
   start = TimeCurrent();
   result = CountPositionsMock("", 10); // Early exit at 10
   end = TimeCurrent();

   if(AssertEquals(10, result, "Performance: Early exit at 10 from 1000 positions")) passed++; else failed++;
   Print("   Execution time with early exit: ", (end - start), " seconds");

   Print("");

   // === Final Report ===
   Print("╔════════════════════════════════════════════════════════════╗");
   Print("║  TEST SUMMARY                                              ║");
   Print("╚════════════════════════════════════════════════════════════╝");
   Print("Total Tests:  ", passed + failed);
   Print("Passed:       ", passed, " ✅");
   Print("Failed:       ", failed, " ❌");
   Print("Success Rate: ", DoubleToString((double)passed / (passed + failed) * 100, 1), "%");
   Print("");

   if(failed == 0) {
      Print("╔════════════════════════════════════════════════════════════╗");
      Print("║  ✅ ALL TESTS PASSED - POSITION COUNTING LOGIC VERIFIED   ║");
      Print("╚════════════════════════════════════════════════════════════╝");
   } else {
      Print("╔════════════════════════════════════════════════════════════╗");
      Print("║  ❌ SOME TESTS FAILED - REVIEW COUNTING LOGIC             ║");
      Print("╚════════════════════════════════════════════════════════════╝");
   }
}
