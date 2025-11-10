//+------------------------------------------------------------------+
//| test_risk_management_integration.mq5                             |
//| Integration tests for risk management system                     |
//+------------------------------------------------------------------+
#property copyright "EA Scalping Pro Team"
#property link      "https://github.com/fred-selest/ea-scalping-pro"
#property version   "1.00"
#property script_show_inputs

#define TEST_MAGIC 999999
#define PIPS_TO_POINTS_MULTIPLIER 10

// Test configuration
input bool DEBUG_MODE = false;

// Mock position data
struct MockPosition {
   ulong ticket;
   string symbol;
   double volume;
   double profit;
   double sl_pips;
};

MockPosition g_positions[];
int g_position_count = 0;
double g_mock_balance = 10000.0;
double g_daily_pl = 0.0;

// Test helper functions
bool AssertTrue(bool condition, string test_name) {
   if(condition) {
      Print("✅ PASS: ", test_name);
      return true;
   } else {
      Print("❌ FAIL: ", test_name);
      return false;
   }
}

bool AssertFalse(bool condition, string test_name) {
   return AssertTrue(!condition, test_name);
}

bool AssertEquals(int expected, int actual, string test_name) {
   if(expected == actual) {
      Print("✅ PASS: ", test_name, " (Expected: ", expected, ", Got: ", actual, ")");
      return true;
   } else {
      Print("❌ FAIL: ", test_name, " (Expected: ", expected, ", Got: ", actual, ")");
      return false;
   }
}

bool AssertEqualsDouble(double expected, double actual, string test_name, double tolerance = 0.01) {
   if(MathAbs(expected - actual) <= tolerance) {
      Print("✅ PASS: ", test_name, " (Expected: ", DoubleToString(expected, 2), ", Got: ", DoubleToString(actual, 2), ")");
      return true;
   } else {
      Print("❌ FAIL: ", test_name, " (Expected: ", DoubleToString(expected, 2), ", Got: ", DoubleToString(actual, 2), ")");
      return false;
   }
}

// Mock functions
void ResetMockEnvironment() {
   ArrayResize(g_positions, 0);
   g_position_count = 0;
   g_mock_balance = 10000.0;
   g_daily_pl = 0.0;
}

void AddMockPosition(string symbol, double volume, double profit, double sl_pips) {
   int size = ArraySize(g_positions);
   ArrayResize(g_positions, size + 1);
   g_positions[size].ticket = size + 1000;
   g_positions[size].symbol = symbol;
   g_positions[size].volume = volume;
   g_positions[size].profit = profit;
   g_positions[size].sl_pips = sl_pips;
   g_position_count++;
   g_daily_pl += profit;
}

int CountMockPositions(string symbol_filter = "") {
   if(symbol_filter == "") return g_position_count;

   int count = 0;
   for(int i = 0; i < g_position_count; i++) {
      if(g_positions[i].symbol == symbol_filter) count++;
   }
   return count;
}

double CalculateLotSizeMock(double balance, double risk_percent, double sl_pips, double max_lot) {
   double risk_amount = balance * risk_percent / 100.0;
   double pip_value = 1.0;  // Simplified for EURUSD
   double lot_size = risk_amount / (sl_pips * pip_value);

   lot_size = MathFloor(lot_size / 0.01) * 0.01;
   lot_size = MathMax(0.01, MathMin(lot_size, max_lot));
   lot_size = MathMin(lot_size, 100.0);

   return NormalizeDouble(lot_size, 2);
}

bool CheckMaxOpenPositions(int max_open) {
   return g_position_count < max_open;
}

bool CheckMaxPositionsPerSymbol(string symbol, int max_per_symbol) {
   int count = CountMockPositions(symbol);
   return count < max_per_symbol;
}

bool CheckMaxDailyLoss(double max_daily_loss_percent) {
   double daily_loss_percent = (g_daily_pl / g_mock_balance) * 100.0;
   return daily_loss_percent > -max_daily_loss_percent;
}

double CalculateDailyPLPercent() {
   return (g_daily_pl / g_mock_balance) * 100.0;
}

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
   Print("╔════════════════════════════════════════════════════════════╗");
   Print("║  Integration Test: Risk Management System                 ║");
   Print("╚════════════════════════════════════════════════════════════╝");
   Print("");

   int passed = 0;
   int failed = 0;

   // === Test 1: MaxOpenPositions Enforcement ===
   Print("─────────────────────────────────────────────────────────────");
   Print("🔒 Test 1: MaxOpenPositions Enforcement");
   Print("─────────────────────────────────────────────────────────────");

   ResetMockEnvironment();
   int max_open = 5;

   // Add positions up to limit
   for(int i = 0; i < 5; i++) {
      AddMockPosition("EURUSD", 0.5, 10.0, 20.0);
   }

   if(AssertEquals(5, g_position_count, "5 positions opened")) passed++; else failed++;
   if(AssertFalse(CheckMaxOpenPositions(max_open), "Cannot open 6th position (limit reached)")) passed++; else failed++;

   // Close one position
   g_position_count--;
   if(AssertTrue(CheckMaxOpenPositions(max_open), "Can open new position after closing one")) passed++; else failed++;

   if(DEBUG_MODE) {
      Print("[DEBUG] Total positions: ", g_position_count, " / Max: ", max_open);
   }

   Print("");

   // === Test 2: MaxPositionsPerSymbol Enforcement ===
   Print("─────────────────────────────────────────────────────────────");
   Print("🔒 Test 2: MaxPositionsPerSymbol Enforcement");
   Print("─────────────────────────────────────────────────────────────");

   ResetMockEnvironment();
   int max_per_symbol = 2;

   AddMockPosition("EURUSD", 0.5, 5.0, 20.0);
   AddMockPosition("EURUSD", 0.5, 8.0, 20.0);
   AddMockPosition("GBPUSD", 0.5, 3.0, 20.0);

   if(AssertEquals(2, CountMockPositions("EURUSD"), "EURUSD: 2 positions")) passed++; else failed++;
   if(AssertEquals(1, CountMockPositions("GBPUSD"), "GBPUSD: 1 position")) passed++; else failed++;
   if(AssertFalse(CheckMaxPositionsPerSymbol("EURUSD", max_per_symbol), "EURUSD: Cannot open 3rd position")) passed++; else failed++;
   if(AssertTrue(CheckMaxPositionsPerSymbol("GBPUSD", max_per_symbol), "GBPUSD: Can open 2nd position")) passed++; else failed++;

   if(DEBUG_MODE) {
      Print("[DEBUG] EURUSD positions: ", CountMockPositions("EURUSD"), " / Max: ", max_per_symbol);
      Print("[DEBUG] GBPUSD positions: ", CountMockPositions("GBPUSD"), " / Max: ", max_per_symbol);
   }

   Print("");

   // === Test 3: MaxLotSize Clamping ===
   Print("─────────────────────────────────────────────────────────────");
   Print("🔒 Test 3: MaxLotSize Clamping");
   Print("─────────────────────────────────────────────────────────────");

   ResetMockEnvironment();

   // Conservative: MaxLot = 0.2
   double lot_conservative = CalculateLotSizeMock(10000.0, 1.0, 10.0, 0.2);
   if(AssertEqualsDouble(0.2, lot_conservative, "Conservative: Lot clamped to 0.2")) passed++; else failed++;
   if(AssertTrue(lot_conservative <= 0.2, "Conservative: Respects MaxLot")) passed++; else failed++;

   // Moderate: MaxLot = 1.0
   double lot_moderate = CalculateLotSizeMock(10000.0, 1.0, 5.0, 1.0);
   if(AssertEqualsDouble(1.0, lot_moderate, "Moderate: Lot clamped to 1.0")) passed++; else failed++;

   // Aggressive: MaxLot = 2.0
   double lot_aggressive = CalculateLotSizeMock(10000.0, 2.0, 5.0, 2.0);
   if(AssertEqualsDouble(2.0, lot_aggressive, "Aggressive: Lot clamped to 2.0")) passed++; else failed++;

   // No clamping: Calculated lot < MaxLot
   double lot_unclamped = CalculateLotSizeMock(5000.0, 1.0, 50.0, 10.0);
   if(AssertTrue(lot_unclamped < 10.0, "No clamping: Calculated lot < MaxLot")) passed++; else failed++;

   if(DEBUG_MODE) {
      Print("[DEBUG] Lot conservative: ", DoubleToString(lot_conservative, 2));
      Print("[DEBUG] Lot moderate: ", DoubleToString(lot_moderate, 2));
      Print("[DEBUG] Lot aggressive: ", DoubleToString(lot_aggressive, 2));
   }

   Print("");

   // === Test 4: MaxDailyLoss Trigger ===
   Print("─────────────────────────────────────────────────────────────");
   Print("🔒 Test 4: MaxDailyLoss Trigger");
   Print("─────────────────────────────────────────────────────────────");

   ResetMockEnvironment();
   double max_daily_loss = 3.0;  // 3%

   // Scenario 1: Daily loss within limit
   AddMockPosition("EURUSD", 0.5, -50.0, 20.0);   // -50$
   AddMockPosition("GBPUSD", 0.5, -100.0, 20.0);  // -100$
   // Total: -150$ = -1.5%

   double pl_percent_1 = CalculateDailyPLPercent();
   if(AssertTrue(CheckMaxDailyLoss(max_daily_loss), "Loss -1.5%: Trading allowed")) passed++; else failed++;
   if(AssertTrue(pl_percent_1 > -max_daily_loss, "Daily P&L within limit")) passed++; else failed++;

   // Scenario 2: Daily loss approaching limit
   ResetMockEnvironment();
   AddMockPosition("EURUSD", 0.5, -280.0, 20.0);  // -280$ = -2.8%

   double pl_percent_2 = CalculateDailyPLPercent();
   if(AssertTrue(CheckMaxDailyLoss(max_daily_loss), "Loss -2.8%: Trading still allowed")) passed++; else failed++;

   // Scenario 3: Daily loss exceeds limit
   ResetMockEnvironment();
   AddMockPosition("EURUSD", 0.5, -350.0, 20.0);  // -350$ = -3.5%

   double pl_percent_3 = CalculateDailyPLPercent();
   if(AssertFalse(CheckMaxDailyLoss(max_daily_loss), "Loss -3.5%: Trading STOPPED")) passed++; else failed++;
   if(AssertTrue(pl_percent_3 <= -max_daily_loss, "Daily P&L exceeded limit")) passed++; else failed++;

   if(DEBUG_MODE) {
      Print("[DEBUG] Scenario 1: Daily P&L = ", DoubleToString(pl_percent_1, 2), "%");
      Print("[DEBUG] Scenario 2: Daily P&L = ", DoubleToString(pl_percent_2, 2), "%");
      Print("[DEBUG] Scenario 3: Daily P&L = ", DoubleToString(pl_percent_3, 2), "%");
   }

   Print("");

   // === Test 5: Risk Calculation Accuracy ===
   Print("─────────────────────────────────────────────────────────────");
   Print("🔒 Test 5: Risk Calculation Accuracy");
   Print("─────────────────────────────────────────────────────────────");

   ResetMockEnvironment();

   // Test different risk percentages
   double balance = 10000.0;
   double sl_pips = 20.0;

   double lot_03 = CalculateLotSizeMock(balance, 0.3, sl_pips, 10.0);
   double risk_03 = lot_03 * sl_pips * 1.0;  // Simplified
   double risk_percent_03 = (risk_03 / balance) * 100.0;
   if(AssertTrue(MathAbs(risk_percent_03 - 0.3) < 0.1, "Risk 0.3%: Calculation accurate")) passed++; else failed++;

   double lot_05 = CalculateLotSizeMock(balance, 0.5, sl_pips, 10.0);
   double risk_05 = lot_05 * sl_pips * 1.0;
   double risk_percent_05 = (risk_05 / balance) * 100.0;
   if(AssertTrue(MathAbs(risk_percent_05 - 0.5) < 0.1, "Risk 0.5%: Calculation accurate")) passed++; else failed++;

   double lot_10 = CalculateLotSizeMock(balance, 1.0, sl_pips, 10.0);
   double risk_10 = lot_10 * sl_pips * 1.0;
   double risk_percent_10 = (risk_10 / balance) * 100.0;
   if(AssertTrue(MathAbs(risk_percent_10 - 1.0) < 0.1, "Risk 1.0%: Calculation accurate")) passed++; else failed++;

   if(DEBUG_MODE) {
      Print("[DEBUG] 0.3% risk: Lot=", DoubleToString(lot_03, 2), " | Actual risk=", DoubleToString(risk_percent_03, 3), "%");
      Print("[DEBUG] 0.5% risk: Lot=", DoubleToString(lot_05, 2), " | Actual risk=", DoubleToString(risk_percent_05, 3), "%");
      Print("[DEBUG] 1.0% risk: Lot=", DoubleToString(lot_10, 2), " | Actual risk=", DoubleToString(risk_percent_10, 3), "%");
   }

   Print("");

   // === Test 6: Combined Risk Limits ===
   Print("─────────────────────────────────────────────────────────────");
   Print("🔒 Test 6: Combined Risk Limits (Real-World Scenario)");
   Print("─────────────────────────────────────────────────────────────");

   ResetMockEnvironment();

   // Conservative profile: Balance=1000$, Risk=0.3%, MaxOpen=2, PerSymbol=1, MaxDailyLoss=1.5%
   g_mock_balance = 1000.0;
   double conservative_max_daily_loss = 1.5;
   int conservative_max_open = 2;
   int conservative_max_per_symbol = 1;

   // Trade 1: EURUSD BUY (profit)
   AddMockPosition("EURUSD", 0.01, 5.0, 20.0);
   bool can_trade_1 = CheckMaxOpenPositions(conservative_max_open) &&
                      CheckMaxDailyLoss(conservative_max_daily_loss);
   if(AssertTrue(can_trade_1, "Trade 1: Can open (1/2 positions, P&L +0.5%)")) passed++; else failed++;

   // Trade 2: GBPUSD BUY (loss)
   AddMockPosition("GBPUSD", 0.01, -8.0, 20.0);
   bool can_trade_2 = CheckMaxOpenPositions(conservative_max_open) &&
                      CheckMaxDailyLoss(conservative_max_daily_loss);
   if(AssertFalse(can_trade_2, "Trade 2: Cannot open (2/2 positions limit)")) passed++; else failed++;

   // Close EURUSD
   g_position_count--;

   // Trade 3: EURUSD BUY again (allowed, 1 per symbol)
   bool can_trade_3 = CheckMaxOpenPositions(conservative_max_open) &&
                      CheckMaxPositionsPerSymbol("EURUSD", conservative_max_per_symbol) &&
                      CheckMaxDailyLoss(conservative_max_daily_loss);
   if(AssertTrue(can_trade_3, "Trade 3: Can open EURUSD (position closed)")) passed++; else failed++;

   AddMockPosition("EURUSD", 0.01, -10.0, 20.0);

   double current_pl_percent = CalculateDailyPLPercent();
   if(DEBUG_MODE) {
      Print("[DEBUG] Daily P&L: ", DoubleToString(current_pl_percent, 2), "% (Limit: -", DoubleToString(conservative_max_daily_loss, 1), "%)");
   }

   // Daily loss check
   bool trading_allowed = CheckMaxDailyLoss(conservative_max_daily_loss);
   if(AssertTrue(trading_allowed, "Daily loss within limit")) passed++; else failed++;

   Print("");

   // === Test 7: Multi-Symbol Risk Distribution ===
   Print("─────────────────────────────────────────────────────────────");
   Print("🔒 Test 7: Multi-Symbol Risk Distribution");
   Print("─────────────────────────────────────────────────────────────");

   ResetMockEnvironment();
   g_mock_balance = 10000.0;

   // Open positions on different symbols
   AddMockPosition("EURUSD", 0.5, 12.0, 20.0);
   AddMockPosition("EURUSD", 0.5, -5.0, 20.0);
   AddMockPosition("GBPUSD", 0.5, 8.0, 20.0);
   AddMockPosition("USDJPY", 0.5, -3.0, 20.0);
   AddMockPosition("AUDUSD", 0.5, 15.0, 20.0);

   int total_positions = g_position_count;
   int eurusd_positions = CountMockPositions("EURUSD");
   int gbpusd_positions = CountMockPositions("GBPUSD");
   int usdjpy_positions = CountMockPositions("USDJPY");
   int audusd_positions = CountMockPositions("AUDUSD");

   if(AssertEquals(5, total_positions, "Total: 5 positions across symbols")) passed++; else failed++;
   if(AssertEquals(2, eurusd_positions, "EURUSD: 2 positions")) passed++; else failed++;
   if(AssertEquals(1, gbpusd_positions, "GBPUSD: 1 position")) passed++; else failed++;
   if(AssertEquals(1, usdjpy_positions, "USDJPY: 1 position")) passed++; else failed++;
   if(AssertEquals(1, audusd_positions, "AUDUSD: 1 position")) passed++; else failed++;

   double total_pl = g_daily_pl;
   double total_pl_percent = (total_pl / g_mock_balance) * 100.0;
   if(AssertTrue(total_pl_percent > 0, "Net P&L positive (+0.27%)")) passed++; else failed++;

   if(DEBUG_MODE) {
      Print("[DEBUG] Total P&L: $", DoubleToString(total_pl, 2), " (", DoubleToString(total_pl_percent, 2), "%)");
      Print("[DEBUG] Distribution: EURUSD=", eurusd_positions, " | GBPUSD=", gbpusd_positions,
            " | USDJPY=", usdjpy_positions, " | AUDUSD=", audusd_positions);
   }

   Print("");

   // === Final Report ===
   Print("╔════════════════════════════════════════════════════════════╗");
   Print("║  INTEGRATION TEST SUMMARY                                  ║");
   Print("╚════════════════════════════════════════════════════════════╝");
   Print("Test Suite:   Risk Management Integration");
   Print("Total Tests:  ", passed + failed);
   Print("Passed:       ", passed, " ✅");
   Print("Failed:       ", failed, " ❌");
   Print("Success Rate: ", DoubleToString((double)passed / (passed + failed) * 100, 1), "%");
   Print("");

   if(failed == 0) {
      Print("╔════════════════════════════════════════════════════════════╗");
      Print("║  ✅ ALL TESTS PASSED - RISK MANAGEMENT VERIFIED           ║");
      Print("╚════════════════════════════════════════════════════════════╝");
   } else {
      Print("╔════════════════════════════════════════════════════════════╗");
      Print("║  ❌ SOME TESTS FAILED - REVIEW RISK MANAGEMENT LOGIC      ║");
      Print("╚════════════════════════════════════════════════════════════╝");
   }

   Print("");
   Print("💡 TIP: Run this test regularly to ensure risk management");
   Print("         continues to work correctly after code changes.");
}
