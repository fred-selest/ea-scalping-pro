//+------------------------------------------------------------------+
//| test_lot_calculation.mq5                                         |
//| Unit tests for lot size calculation logic                        |
//+------------------------------------------------------------------+
#property copyright "EA Scalping Pro Team"
#property link      "https://github.com/fred-selest/ea-scalping-pro"
#property version   "1.00"
#property script_show_inputs

#define PIPS_TO_POINTS_MULTIPLIER 10

// Mock symbol data
struct SymbolData {
   string name;
   double tick_value;
   double tick_size;
   double point;
   double min_lot;
   double max_lot;
   double lot_step;
};

// Test helper functions
bool AssertEquals(double expected, double actual, string test_name, double tolerance = 0.01) {
   if(MathAbs(expected - actual) <= tolerance) {
      Print("✅ PASS: ", test_name, " (Expected: ", DoubleToString(expected, 2), ", Got: ", DoubleToString(actual, 2), ")");
      return true;
   } else {
      Print("❌ FAIL: ", test_name, " (Expected: ", DoubleToString(expected, 2), ", Got: ", DoubleToString(actual, 2), ")");
      return false;
   }
}

bool AssertInRange(double value, double min, double max, string test_name) {
   if(value >= min && value <= max) {
      Print("✅ PASS: ", test_name, " (", DoubleToString(value, 2), " in [", DoubleToString(min, 2), "-", DoubleToString(max, 2), "])");
      return true;
   } else {
      Print("❌ FAIL: ", test_name, " (", DoubleToString(value, 2), " NOT in [", DoubleToString(min, 2), "-", DoubleToString(max, 2), "])");
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

// Create mock symbol data
SymbolData CreateEURUSD() {
   SymbolData s;
   s.name = "EURUSD";
   s.tick_value = 1.0;
   s.tick_size = 0.00001;
   s.point = 0.00001;
   s.min_lot = 0.01;
   s.max_lot = 100.0;
   s.lot_step = 0.01;
   return s;
}

SymbolData CreateGBPUSD() {
   SymbolData s;
   s.name = "GBPUSD";
   s.tick_value = 1.0;
   s.tick_size = 0.00001;
   s.point = 0.00001;
   s.min_lot = 0.01;
   s.max_lot = 100.0;
   s.lot_step = 0.01;
   return s;
}

SymbolData CreateUSDJPY() {
   SymbolData s;
   s.name = "USDJPY";
   s.tick_value = 0.91;  // Approximate USD/JPY tick value
   s.tick_size = 0.001;
   s.point = 0.001;
   s.min_lot = 0.01;
   s.max_lot = 100.0;
   s.lot_step = 0.01;
   return s;
}

SymbolData CreateXAUUSD() {
   SymbolData s;
   s.name = "XAUUSD";  // Gold
   s.tick_value = 1.0;
   s.tick_size = 0.01;
   s.point = 0.01;
   s.min_lot = 0.01;
   s.max_lot = 50.0;
   s.lot_step = 0.01;
   return s;
}

// Replicate CalculateLotSize logic with mock data
double CalculateLotSizeMock(SymbolData &symbol, double balance, double risk_percent, double sl_pips, double max_lot_size) {
   double risk_amount = balance * risk_percent / 100.0;

   double tick_value = symbol.tick_value;
   double tick_size = symbol.tick_size;
   double point = symbol.point;
   double min_lot = symbol.min_lot;
   double max_lot = symbol.max_lot;
   double lot_step = symbol.lot_step;

   double pip_value = tick_value / tick_size * point * PIPS_TO_POINTS_MULTIPLIER;
   double lot_size = risk_amount / (sl_pips * pip_value);

   lot_size = MathFloor(lot_size / lot_step) * lot_step;
   lot_size = MathMax(min_lot, MathMin(lot_size, max_lot_size));
   lot_size = MathMin(lot_size, max_lot);

   return NormalizeDouble(lot_size, 2);
}

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
   Print("╔════════════════════════════════════════════════════════════╗");
   Print("║  Test Suite: Lot Size Calculation Logic                   ║");
   Print("╚════════════════════════════════════════════════════════════╝");
   Print("");

   int passed = 0;
   int failed = 0;

   // === Test Category 1: Basic Lot Calculation ===
   Print("─────────────────────────────────────────────────────────────");
   Print("📊 Test Category: BASIC LOT CALCULATION");
   Print("─────────────────────────────────────────────────────────────");

   SymbolData eurusd = CreateEURUSD();

   // Test 1: Standard calculation (Balance=10000, Risk=1%, SL=20 pips)
   double lot1 = CalculateLotSizeMock(eurusd, 10000.0, 1.0, 20.0, 10.0);
   // Expected: (10000 × 0.01) / (20 × 1.0) = 100 / 20 = 5.0 lots
   if(AssertEquals(5.0, lot1, "Lot calc: 10000$ @ 1% risk, SL=20 pips")) passed++; else failed++;

   // Test 2: Conservative calculation (Balance=5000, Risk=0.5%, SL=15 pips)
   double lot2 = CalculateLotSizeMock(eurusd, 5000.0, 0.5, 15.0, 10.0);
   // Expected: (5000 × 0.005) / (15 × 1.0) = 25 / 15 = 1.66... → 1.66 lots
   if(AssertEquals(1.66, lot2, "Lot calc: 5000$ @ 0.5% risk, SL=15 pips", 0.02)) passed++; else failed++;

   // Test 3: Small account (Balance=1000, Risk=0.3%, SL=20 pips)
   double lot3 = CalculateLotSizeMock(eurusd, 1000.0, 0.3, 20.0, 1.0);
   // Expected: (1000 × 0.003) / (20 × 1.0) = 3 / 20 = 0.15 lots
   if(AssertEquals(0.15, lot3, "Lot calc: 1000$ @ 0.3% risk, SL=20 pips")) passed++; else failed++;

   // Test 4: Large account (Balance=100000, Risk=1%, SL=10 pips)
   double lot4 = CalculateLotSizeMock(eurusd, 100000.0, 1.0, 10.0, 100.0);
   // Expected: (100000 × 0.01) / (10 × 1.0) = 1000 / 10 = 100 lots (clamped to max_lot)
   if(AssertEquals(100.0, lot4, "Lot calc: 100000$ @ 1% risk, SL=10 pips (max)")) passed++; else failed++;

   Print("");

   // === Test Category 2: Risk Percentage Variations ===
   Print("─────────────────────────────────────────────────────────────");
   Print("📊 Test Category: RISK PERCENTAGE VARIATIONS");
   Print("─────────────────────────────────────────────────────────────");

   double balance = 10000.0;
   double sl_pips = 20.0;

   // Conservative: 0.3%
   double lot_conservative = CalculateLotSizeMock(eurusd, balance, 0.3, sl_pips, 1.0);
   if(AssertEquals(0.15, lot_conservative, "Risk 0.3%: Conservative")) passed++; else failed++;

   // Moderate: 0.5%
   double lot_moderate = CalculateLotSizeMock(eurusd, balance, 0.5, sl_pips, 1.0);
   if(AssertEquals(0.25, lot_moderate, "Risk 0.5%: Moderate")) passed++; else failed++;

   // Aggressive: 1.0%
   double lot_aggressive = CalculateLotSizeMock(eurusd, balance, 1.0, sl_pips, 10.0);
   if(AssertEquals(0.5, lot_aggressive, "Risk 1.0%: Aggressive")) passed++; else failed++;

   // Very aggressive: 2.0%
   double lot_very_aggressive = CalculateLotSizeMock(eurusd, balance, 2.0, sl_pips, 10.0);
   if(AssertEquals(1.0, lot_very_aggressive, "Risk 2.0%: Very Aggressive")) passed++; else failed++;

   // Verify risk proportionality (doubling risk doubles lot size)
   if(AssertTrue(lot_aggressive == 2 * lot_moderate, "Risk 1% is 2× Risk 0.5%")) passed++; else failed++;

   Print("");

   // === Test Category 3: Stop Loss Variations ===
   Print("─────────────────────────────────────────────────────────────");
   Print("📊 Test Category: STOP LOSS VARIATIONS");
   Print("─────────────────────────────────────────────────────────────");

   balance = 10000.0;
   double risk = 1.0;

   // Tight SL: 10 pips
   double lot_tight_sl = CalculateLotSizeMock(eurusd, balance, risk, 10.0, 10.0);
   if(AssertEquals(1.0, lot_tight_sl, "SL=10 pips (tight)")) passed++; else failed++;

   // Standard SL: 20 pips
   double lot_standard_sl = CalculateLotSizeMock(eurusd, balance, risk, 20.0, 10.0);
   if(AssertEquals(0.5, lot_standard_sl, "SL=20 pips (standard)")) passed++; else failed++;

   // Wide SL: 50 pips
   double lot_wide_sl = CalculateLotSizeMock(eurusd, balance, risk, 50.0, 10.0);
   if(AssertEquals(0.2, lot_wide_sl, "SL=50 pips (wide)")) passed++; else failed++;

   // Very wide SL: 100 pips
   double lot_very_wide_sl = CalculateLotSizeMock(eurusd, balance, risk, 100.0, 10.0);
   if(AssertEquals(0.1, lot_very_wide_sl, "SL=100 pips (very wide)")) passed++; else failed++;

   // Verify inverse proportionality (doubling SL halves lot size)
   if(AssertTrue(lot_tight_sl == 2 * lot_standard_sl, "SL 10 pips is 2× lot vs SL 20 pips")) passed++; else failed++;

   Print("");

   // === Test Category 4: Balance Variations ===
   Print("─────────────────────────────────────────────────────────────");
   Print("📊 Test Category: BALANCE VARIATIONS");
   Print("─────────────────────────────────────────────────────────────");

   risk = 1.0;
   sl_pips = 20.0;

   // Micro account: $500
   double lot_micro = CalculateLotSizeMock(eurusd, 500.0, risk, sl_pips, 1.0);
   if(AssertEquals(0.02, lot_micro, "Balance=$500 (micro)", 0.01)) passed++; else failed++;

   // Small account: $1000
   double lot_small = CalculateLotSizeMock(eurusd, 1000.0, risk, sl_pips, 1.0);
   if(AssertEquals(0.05, lot_small, "Balance=$1000 (small)")) passed++; else failed++;

   // Standard account: $5000
   double lot_standard = CalculateLotSizeMock(eurusd, 5000.0, risk, sl_pips, 10.0);
   if(AssertEquals(0.25, lot_standard, "Balance=$5000 (standard)")) passed++; else failed++;

   // Large account: $50000
   double lot_large = CalculateLotSizeMock(eurusd, 50000.0, risk, sl_pips, 100.0);
   if(AssertEquals(2.5, lot_large, "Balance=$50000 (large)")) passed++; else failed++;

   // Verify proportionality (10× balance = 10× lot size)
   if(AssertTrue(lot_standard == 5 * lot_small, "Balance $5000 is 5× lot vs $1000")) passed++; else failed++;

   Print("");

   // === Test Category 5: MaxLotSize Clamping ===
   Print("─────────────────────────────────────────────────────────────");
   Print("📊 Test Category: MAX LOT SIZE CLAMPING");
   Print("─────────────────────────────────────────────────────────────");

   // Conservative: MaxLot = 0.2
   double lot_clamped1 = CalculateLotSizeMock(eurusd, 10000.0, 1.0, 10.0, 0.2);
   if(AssertEquals(0.2, lot_clamped1, "MaxLotSize=0.2 (Conservative)")) passed++; else failed++;
   if(AssertTrue(lot_clamped1 <= 0.2, "Respects MaxLotSize limit")) passed++; else failed++;

   // Moderate: MaxLot = 1.0
   double lot_clamped2 = CalculateLotSizeMock(eurusd, 10000.0, 1.0, 5.0, 1.0);
   if(AssertEquals(1.0, lot_clamped2, "MaxLotSize=1.0 (Moderate)")) passed++; else failed++;

   // Aggressive: MaxLot = 2.0
   double lot_clamped3 = CalculateLotSizeMock(eurusd, 10000.0, 2.0, 5.0, 2.0);
   if(AssertEquals(2.0, lot_clamped3, "MaxLotSize=2.0 (Aggressive)")) passed++; else failed++;

   // No clamping: MaxLot = 10.0 (high enough)
   double lot_unclamped = CalculateLotSizeMock(eurusd, 5000.0, 1.0, 20.0, 10.0);
   if(AssertTrue(lot_unclamped < 10.0, "Not clamped when calculated < MaxLot")) passed++; else failed++;

   Print("");

   // === Test Category 6: Broker Limits (min/max lot) ===
   Print("─────────────────────────────────────────────────────────────");
   Print("📊 Test Category: BROKER LIMITS");
   Print("─────────────────────────────────────────────────────────────");

   // Test min_lot enforcement
   SymbolData symbol_high_minlot = CreateEURUSD();
   symbol_high_minlot.min_lot = 0.1;  // Broker requires minimum 0.1 lots

   double lot_min_enforced = CalculateLotSizeMock(symbol_high_minlot, 500.0, 0.5, 20.0, 10.0);
   // Calculated: (500 × 0.005) / 20 = 0.125, but min_lot = 0.1
   if(AssertTrue(lot_min_enforced >= 0.1, "Respects broker min_lot=0.1")) passed++; else failed++;

   // Test max_lot enforcement
   SymbolData symbol_low_maxlot = CreateEURUSD();
   symbol_low_maxlot.max_lot = 5.0;  // Broker limits to 5 lots max

   double lot_max_enforced = CalculateLotSizeMock(symbol_low_maxlot, 100000.0, 2.0, 10.0, 100.0);
   // Calculated: (100000 × 0.02) / 10 = 200 lots, but max_lot = 5.0
   if(AssertEquals(5.0, lot_max_enforced, "Respects broker max_lot=5.0")) passed++; else failed++;

   Print("");

   // === Test Category 7: Lot Step Rounding ===
   Print("─────────────────────────────────────────────────────────────");
   Print("📊 Test Category: LOT STEP ROUNDING");
   Print("─────────────────────────────────────────────────────────────");

   // Standard lot_step = 0.01
   double lot_step_01 = CalculateLotSizeMock(eurusd, 10000.0, 1.0, 23.0, 10.0);
   // Calculated: 100 / 23 = 4.347... → rounded down to 4.34
   if(AssertTrue(MathAbs(lot_step_01 - MathRound(lot_step_01 / 0.01) * 0.01) < 0.001, "Rounded to lot_step=0.01")) passed++; else failed++;

   // Large lot_step = 0.1
   SymbolData symbol_large_step = CreateEURUSD();
   symbol_large_step.lot_step = 0.1;

   double lot_step_10 = CalculateLotSizeMock(symbol_large_step, 10000.0, 1.0, 20.0, 10.0);
   // Calculated: 100 / 20 = 5.0, rounded to 5.0 (already multiple of 0.1)
   if(AssertEquals(5.0, lot_step_10, "lot_step=0.1: 5.0 lots")) passed++; else failed++;

   // Verify floor rounding (always rounds down)
   double lot_floor_test = CalculateLotSizeMock(symbol_large_step, 10000.0, 1.0, 22.0, 10.0);
   // Calculated: 100 / 22 = 4.545... → floor to 4.5 (with step 0.1)
   if(AssertEquals(4.5, lot_floor_test, "Floor rounding: 4.545 → 4.5", 0.02)) passed++; else failed++;

   Print("");

   // === Test Category 8: Different Symbols ===
   Print("─────────────────────────────────────────────────────────────");
   Print("📊 Test Category: DIFFERENT SYMBOLS");
   Print("─────────────────────────────────────────────────────────────");

   balance = 10000.0;
   risk = 1.0;
   sl_pips = 20.0;

   // EURUSD
   SymbolData s_eurusd = CreateEURUSD();
   double lot_eurusd = CalculateLotSizeMock(s_eurusd, balance, risk, sl_pips, 10.0);
   Print("   EURUSD lot: ", DoubleToString(lot_eurusd, 2));
   if(AssertTrue(lot_eurusd > 0, "EURUSD: Valid lot calculated")) passed++; else failed++;

   // GBPUSD
   SymbolData s_gbpusd = CreateGBPUSD();
   double lot_gbpusd = CalculateLotSizeMock(s_gbpusd, balance, risk, sl_pips, 10.0);
   Print("   GBPUSD lot: ", DoubleToString(lot_gbpusd, 2));
   if(AssertTrue(lot_gbpusd > 0, "GBPUSD: Valid lot calculated")) passed++; else failed++;

   // USDJPY (different pip calculation)
   SymbolData s_usdjpy = CreateUSDJPY();
   double lot_usdjpy = CalculateLotSizeMock(s_usdjpy, balance, risk, sl_pips, 10.0);
   Print("   USDJPY lot: ", DoubleToString(lot_usdjpy, 2));
   if(AssertTrue(lot_usdjpy > 0, "USDJPY: Valid lot calculated")) passed++; else failed++;

   // XAUUSD (Gold)
   SymbolData s_xauusd = CreateXAUUSD();
   double lot_xauusd = CalculateLotSizeMock(s_xauusd, balance, risk, 50.0, 10.0);  // Gold needs wider SL
   Print("   XAUUSD lot: ", DoubleToString(lot_xauusd, 2));
   if(AssertTrue(lot_xauusd > 0, "XAUUSD: Valid lot calculated")) passed++; else failed++;

   Print("");

   // === Test Category 9: Real-World Scenarios ===
   Print("─────────────────────────────────────────────────────────────");
   Print("📊 Test Category: REAL-WORLD SCENARIOS");
   Print("─────────────────────────────────────────────────────────────");

   // Scenario 1: Conservative profile
   Print("   Scenario: Conservative (1000$, Risk=0.3%, SL=20, MaxLot=0.2)");
   double lot_scenario1 = CalculateLotSizeMock(eurusd, 1000.0, 0.3, 20.0, 0.2);
   Print("   → Lot size: ", DoubleToString(lot_scenario1, 2));
   if(AssertInRange(lot_scenario1, 0.01, 0.2, "Conservative scenario")) passed++; else failed++;

   double risk_amount1 = 1000.0 * 0.003;  // $3
   Print("   → Risk amount: $", DoubleToString(risk_amount1, 2));
   if(AssertTrue(risk_amount1 <= 10.0, "Risk ≤ $10 (safe)")) passed++; else failed++;

   // Scenario 2: Moderate profile
   Print("   Scenario: Moderate (5000$, Risk=0.5%, SL=15, MaxLot=1.0)");
   double lot_scenario2 = CalculateLotSizeMock(eurusd, 5000.0, 0.5, 15.0, 1.0);
   Print("   → Lot size: ", DoubleToString(lot_scenario2, 2));
   if(AssertInRange(lot_scenario2, 0.01, 1.0, "Moderate scenario")) passed++; else failed++;

   double risk_amount2 = 5000.0 * 0.005;  // $25
   Print("   → Risk amount: $", DoubleToString(risk_amount2, 2));

   // Scenario 3: Aggressive profile
   Print("   Scenario: Aggressive (10000$, Risk=1.0%, SL=12, MaxLot=2.0)");
   double lot_scenario3 = CalculateLotSizeMock(eurusd, 10000.0, 1.0, 12.0, 2.0);
   Print("   → Lot size: ", DoubleToString(lot_scenario3, 2));
   if(AssertInRange(lot_scenario3, 0.01, 2.0, "Aggressive scenario")) passed++; else failed++;

   double risk_amount3 = 10000.0 * 0.01;  // $100
   Print("   → Risk amount: $", DoubleToString(risk_amount3, 2));

   // Scenario 4: Account growth simulation
   Print("   Scenario: Account growth (1000$ → 1500$ → 2000$)");
   double lot_1000 = CalculateLotSizeMock(eurusd, 1000.0, 1.0, 20.0, 10.0);
   double lot_1500 = CalculateLotSizeMock(eurusd, 1500.0, 1.0, 20.0, 10.0);
   double lot_2000 = CalculateLotSizeMock(eurusd, 2000.0, 1.0, 20.0, 10.0);

   Print("   → $1000: ", DoubleToString(lot_1000, 2), " lots");
   Print("   → $1500: ", DoubleToString(lot_1500, 2), " lots");
   Print("   → $2000: ", DoubleToString(lot_2000, 2), " lots");

   if(AssertTrue(lot_1500 > lot_1000, "Lot increases as balance grows")) passed++; else failed++;
   if(AssertTrue(lot_2000 > lot_1500, "Lot continues to increase")) passed++; else failed++;

   Print("");

   // === Test Category 10: Edge Cases ===
   Print("─────────────────────────────────────────────────────────────");
   Print("📊 Test Category: EDGE CASES");
   Print("─────────────────────────────────────────────────────────────");

   // Zero balance (should return min_lot)
   double lot_zero_balance = CalculateLotSizeMock(eurusd, 0.0, 1.0, 20.0, 10.0);
   if(AssertEquals(0.01, lot_zero_balance, "Zero balance returns min_lot")) passed++; else failed++;

   // Very small balance
   double lot_tiny = CalculateLotSizeMock(eurusd, 10.0, 1.0, 20.0, 10.0);
   if(AssertEquals(0.01, lot_tiny, "Tiny balance ($10) returns min_lot")) passed++; else failed++;

   // Zero risk percent (should return min_lot)
   double lot_zero_risk = CalculateLotSizeMock(eurusd, 10000.0, 0.0, 20.0, 10.0);
   if(AssertEquals(0.01, lot_zero_risk, "Zero risk returns min_lot")) passed++; else failed++;

   // Very large SL (should return min_lot or very small)
   double lot_huge_sl = CalculateLotSizeMock(eurusd, 1000.0, 1.0, 500.0, 10.0);
   if(AssertTrue(lot_huge_sl <= 0.05, "Huge SL (500 pips) returns tiny lot")) passed++; else failed++;

   // MaxLotSize = min_lot (should return min_lot)
   double lot_max_equals_min = CalculateLotSizeMock(eurusd, 10000.0, 1.0, 20.0, 0.01);
   if(AssertEquals(0.01, lot_max_equals_min, "MaxLot=MinLot returns MinLot")) passed++; else failed++;

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
      Print("║  ✅ ALL TESTS PASSED - LOT CALCULATION VERIFIED           ║");
      Print("╚════════════════════════════════════════════════════════════╝");
   } else {
      Print("╔════════════════════════════════════════════════════════════╗");
      Print("║  ❌ SOME TESTS FAILED - REVIEW CALCULATION LOGIC          ║");
      Print("╚════════════════════════════════════════════════════════════╝");
   }
}
