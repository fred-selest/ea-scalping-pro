//+------------------------------------------------------------------+
//| test_validation.mq5                                              |
//| Unit tests for EA input parameter validation                     |
//+------------------------------------------------------------------+
#property copyright "EA Scalping Pro Team"
#property link      "https://github.com/fred-selest/ea-scalping-pro"
#property version   "1.00"
#property script_show_inputs

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

bool AssertEquals(double expected, double actual, string test_name) {
   if(MathAbs(expected - actual) < 0.0001) {
      Print("✅ PASS: ", test_name, " (Expected: ", expected, ", Got: ", actual, ")");
      return true;
   } else {
      Print("❌ FAIL: ", test_name, " (Expected: ", expected, ", Got: ", actual, ")");
      return false;
   }
}

bool AssertInRange(double value, double min, double max, string test_name) {
   if(value >= min && value <= max) {
      Print("✅ PASS: ", test_name, " (", value, " in [", min, "-", max, "])");
      return true;
   } else {
      Print("❌ FAIL: ", test_name, " (", value, " NOT in [", min, "-", max, "])");
      return false;
   }
}

// Validation functions (replicate EA logic)
bool ValidateRiskPercent(double risk) {
   if(risk <= 0.0) {
      Print("ERROR: RiskPercent must be > 0 (got ", risk, ")");
      return false;
   }
   if(risk > 5.0) {
      Print("WARNING: RiskPercent > 5% is very risky (got ", risk, "%)");
      return false;
   }
   return true;
}

bool ValidateMaxLotSize(double lot) {
   if(lot <= 0.0) {
      Print("ERROR: MaxLotSize must be > 0 (got ", lot, ")");
      return false;
   }
   if(lot > 100.0) {
      Print("ERROR: MaxLotSize > 100 is unrealistic (got ", lot, ")");
      return false;
   }
   return true;
}

bool ValidateMaxDailyLoss(double loss) {
   if(loss <= 0.0) {
      Print("ERROR: MaxDailyLoss must be > 0 (got ", loss, ")");
      return false;
   }
   if(loss > 20.0) {
      Print("WARNING: MaxDailyLoss > 20% is very high (got ", loss, "%)");
      return false;
   }
   return true;
}

bool ValidateMaxOpenPositions(int positions) {
   if(positions < 1) {
      Print("ERROR: MaxOpenPositions must be >= 1 (got ", positions, ")");
      return false;
   }
   if(positions > 50) {
      Print("WARNING: MaxOpenPositions > 50 may overload broker (got ", positions, ")");
      return false;
   }
   return true;
}

bool ValidateMaxPositionsPerSymbol(int positions) {
   if(positions < 1) {
      Print("ERROR: MaxPositionsPerSymbol must be >= 1 (got ", positions, ")");
      return false;
   }
   if(positions > 10) {
      Print("WARNING: MaxPositionsPerSymbol > 10 is excessive (got ", positions, ")");
      return false;
   }
   return true;
}

bool ValidateScalpTPPips(double tp) {
   if(tp < 1.0) {
      Print("ERROR: ScalpTP_Pips must be >= 1.0 (got ", tp, ")");
      return false;
   }
   if(tp > 100.0) {
      Print("WARNING: ScalpTP_Pips > 100 is not scalping (got ", tp, ")");
      return false;
   }
   return true;
}

bool ValidateScalpSLPips(double sl) {
   if(sl < 2.0) {
      Print("ERROR: ScalpSL_Pips must be >= 2.0 (got ", sl, ")");
      return false;
   }
   if(sl > 200.0) {
      Print("WARNING: ScalpSL_Pips > 200 is very large (got ", sl, ")");
      return false;
   }
   return true;
}

bool ValidateTrailingStopPips(double ts) {
   if(ts < 0.0) {
      Print("ERROR: TrailingStop_Pips must be >= 0 (got ", ts, ")");
      return false;
   }
   if(ts > 100.0) {
      Print("WARNING: TrailingStop_Pips > 100 is excessive (got ", ts, ")");
      return false;
   }
   return true;
}

bool ValidateBreakEvenPips(double be) {
   if(be < 0.0) {
      Print("ERROR: BreakEven_Pips must be >= 0 (got ", be, ")");
      return false;
   }
   if(be > 50.0) {
      Print("WARNING: BreakEven_Pips > 50 may never trigger (got ", be, ")");
      return false;
   }
   return true;
}

bool ValidateMaxSpreadPoints(int spread) {
   if(spread < 1) {
      Print("ERROR: MaxSpread_Points must be >= 1 (got ", spread, ")");
      return false;
   }
   if(spread > 200) {
      Print("WARNING: MaxSpread_Points > 200 allows very wide spreads (got ", spread, ")");
      return false;
   }
   return true;
}

bool ValidateMinutesBeforeNews(int minutes) {
   if(minutes < 0) {
      Print("ERROR: MinutesBeforeNews must be >= 0 (got ", minutes, ")");
      return false;
   }
   if(minutes > 240) {
      Print("WARNING: MinutesBeforeNews > 240 (4h) may skip too many trades (got ", minutes, ")");
      return false;
   }
   return true;
}

bool ValidateMinutesAfterNews(int minutes) {
   if(minutes < 0) {
      Print("ERROR: MinutesAfterNews must be >= 0 (got ", minutes, ")");
      return false;
   }
   if(minutes > 240) {
      Print("WARNING: MinutesAfterNews > 240 (4h) may skip too many trades (got ", minutes, ")");
      return false;
   }
   return true;
}

bool ValidateMaxTradesPerDay(int trades) {
   if(trades < 1) {
      Print("ERROR: MaxTradesPerDay must be >= 1 (got ", trades, ")");
      return false;
   }
   if(trades > 1000) {
      Print("WARNING: MaxTradesPerDay > 1000 is unrealistic (got ", trades, ")");
      return false;
   }
   return true;
}

bool ValidateMinConfidence(double conf) {
   if(conf < 0.0 || conf > 1.0) {
      Print("ERROR: MinConfidence must be in [0.0, 1.0] (got ", conf, ")");
      return false;
   }
   return true;
}

bool ValidateEMAPeriods(int fast, int slow) {
   if(fast < 2) {
      Print("ERROR: EMA_Fast must be >= 2 (got ", fast, ")");
      return false;
   }
   if(slow < 2) {
      Print("ERROR: EMA_Slow must be >= 2 (got ", slow, ")");
      return false;
   }
   if(fast >= slow) {
      Print("ERROR: EMA_Fast must be < EMA_Slow (got ", fast, " >= ", slow, ")");
      return false;
   }
   return true;
}

bool ValidateRSIPeriod(int period) {
   if(period < 2) {
      Print("ERROR: RSI_Period must be >= 2 (got ", period, ")");
      return false;
   }
   if(period > 100) {
      Print("WARNING: RSI_Period > 100 is very slow (got ", period, ")");
      return false;
   }
   return true;
}

bool ValidateATRPeriod(int period) {
   if(period < 2) {
      Print("ERROR: ATR_Period must be >= 2 (got ", period, ")");
      return false;
   }
   if(period > 100) {
      Print("WARNING: ATR_Period > 100 is very slow (got ", period, ")");
      return false;
   }
   return true;
}

bool ValidateATRFilter(double filter) {
   if(filter < 0.0) {
      Print("ERROR: ATR_Filter must be >= 0 (got ", filter, ")");
      return false;
   }
   if(filter > 10.0) {
      Print("WARNING: ATR_Filter > 10 is very restrictive (got ", filter, ")");
      return false;
   }
   return true;
}

// Cross-parameter validation
bool ValidateRiskRewardRatio(double tp, double sl) {
   double rr_ratio = tp / sl;
   if(rr_ratio < 0.3) {
      Print("WARNING: Risk/Reward ratio too low: ", DoubleToString(rr_ratio, 2), " (TP:", tp, " / SL:", sl, ")");
      return false;
   }
   if(rr_ratio > 5.0) {
      Print("WARNING: Risk/Reward ratio too high: ", DoubleToString(rr_ratio, 2), " (TP:", tp, " / SL:", sl, ")");
      return false;
   }
   return true;
}

bool ValidatePositionLimits(int total, int per_symbol) {
   if(per_symbol > total) {
      Print("ERROR: MaxPositionsPerSymbol (", per_symbol, ") > MaxOpenPositions (", total, ")");
      return false;
   }
   return true;
}

bool ValidateTrailingStopVsTP(double trailing, double tp) {
   if(trailing > tp) {
      Print("WARNING: TrailingStop (", trailing, ") > TP (", tp, ") may cause early exits");
      return false;
   }
   return true;
}

bool ValidateBreakEvenVsTP(double be, double tp) {
   if(be > tp) {
      Print("ERROR: BreakEven (", be, ") > TP (", tp, ") will never trigger");
      return false;
   }
   return true;
}

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
   Print("╔════════════════════════════════════════════════════════════╗");
   Print("║  Test Suite: EA Input Parameter Validation                ║");
   Print("╚════════════════════════════════════════════════════════════╝");
   Print("");

   int passed = 0;
   int failed = 0;

   // === Test Category 1: Risk Parameters ===
   Print("─────────────────────────────────────────────────────────────");
   Print("📊 Test Category: RISK PARAMETERS");
   Print("─────────────────────────────────────────────────────────────");

   // RiskPercent validation
   if(AssertTrue(ValidateRiskPercent(0.5), "RiskPercent = 0.5% (valid)")) passed++; else failed++;
   if(AssertTrue(ValidateRiskPercent(1.0), "RiskPercent = 1.0% (valid)")) passed++; else failed++;
   if(AssertTrue(ValidateRiskPercent(5.0), "RiskPercent = 5.0% (edge case)")) passed++; else failed++;
   if(AssertFalse(ValidateRiskPercent(0.0), "RiskPercent = 0.0% (invalid)")) passed++; else failed++;
   if(AssertFalse(ValidateRiskPercent(-1.0), "RiskPercent = -1.0% (invalid)")) passed++; else failed++;
   if(AssertFalse(ValidateRiskPercent(10.0), "RiskPercent = 10.0% (too high)")) passed++; else failed++;

   // MaxLotSize validation
   if(AssertTrue(ValidateMaxLotSize(0.01), "MaxLotSize = 0.01 (min)")) passed++; else failed++;
   if(AssertTrue(ValidateMaxLotSize(1.0), "MaxLotSize = 1.0 (standard)")) passed++; else failed++;
   if(AssertTrue(ValidateMaxLotSize(10.0), "MaxLotSize = 10.0 (large)")) passed++; else failed++;
   if(AssertFalse(ValidateMaxLotSize(0.0), "MaxLotSize = 0.0 (invalid)")) passed++; else failed++;
   if(AssertFalse(ValidateMaxLotSize(150.0), "MaxLotSize = 150.0 (unrealistic)")) passed++; else failed++;

   // MaxDailyLoss validation
   if(AssertTrue(ValidateMaxDailyLoss(1.0), "MaxDailyLoss = 1.0% (conservative)")) passed++; else failed++;
   if(AssertTrue(ValidateMaxDailyLoss(5.0), "MaxDailyLoss = 5.0% (moderate)")) passed++; else failed++;
   if(AssertTrue(ValidateMaxDailyLoss(10.0), "MaxDailyLoss = 10.0% (aggressive)")) passed++; else failed++;
   if(AssertFalse(ValidateMaxDailyLoss(0.0), "MaxDailyLoss = 0.0% (invalid)")) passed++; else failed++;
   if(AssertFalse(ValidateMaxDailyLoss(25.0), "MaxDailyLoss = 25.0% (too high)")) passed++; else failed++;

   Print("");

   // === Test Category 2: Position Limits ===
   Print("─────────────────────────────────────────────────────────────");
   Print("📊 Test Category: POSITION LIMITS");
   Print("─────────────────────────────────────────────────────────────");

   if(AssertTrue(ValidateMaxOpenPositions(1), "MaxOpenPositions = 1 (min)")) passed++; else failed++;
   if(AssertTrue(ValidateMaxOpenPositions(5), "MaxOpenPositions = 5 (moderate)")) passed++; else failed++;
   if(AssertTrue(ValidateMaxOpenPositions(20), "MaxOpenPositions = 20 (high)")) passed++; else failed++;
   if(AssertFalse(ValidateMaxOpenPositions(0), "MaxOpenPositions = 0 (invalid)")) passed++; else failed++;
   if(AssertFalse(ValidateMaxOpenPositions(100), "MaxOpenPositions = 100 (too high)")) passed++; else failed++;

   if(AssertTrue(ValidateMaxPositionsPerSymbol(1), "MaxPositionsPerSymbol = 1 (min)")) passed++; else failed++;
   if(AssertTrue(ValidateMaxPositionsPerSymbol(3), "MaxPositionsPerSymbol = 3 (moderate)")) passed++; else failed++;
   if(AssertFalse(ValidateMaxPositionsPerSymbol(0), "MaxPositionsPerSymbol = 0 (invalid)")) passed++; else failed++;
   if(AssertFalse(ValidateMaxPositionsPerSymbol(15), "MaxPositionsPerSymbol = 15 (too high)")) passed++; else failed++;

   // Cross-validation
   if(AssertTrue(ValidatePositionLimits(10, 3), "MaxOpen=10, PerSymbol=3 (valid)")) passed++; else failed++;
   if(AssertFalse(ValidatePositionLimits(5, 10), "MaxOpen=5, PerSymbol=10 (invalid)")) passed++; else failed++;

   Print("");

   // === Test Category 3: Scalping Parameters ===
   Print("─────────────────────────────────────────────────────────────");
   Print("📊 Test Category: SCALPING PARAMETERS");
   Print("─────────────────────────────────────────────────────────────");

   // Take Profit
   if(AssertTrue(ValidateScalpTPPips(5.0), "ScalpTP_Pips = 5.0 (tight)")) passed++; else failed++;
   if(AssertTrue(ValidateScalpTPPips(10.0), "ScalpTP_Pips = 10.0 (standard)")) passed++; else failed++;
   if(AssertTrue(ValidateScalpTPPips(20.0), "ScalpTP_Pips = 20.0 (wide)")) passed++; else failed++;
   if(AssertFalse(ValidateScalpTPPips(0.5), "ScalpTP_Pips = 0.5 (too small)")) passed++; else failed++;
   if(AssertFalse(ValidateScalpTPPips(150.0), "ScalpTP_Pips = 150.0 (not scalping)")) passed++; else failed++;

   // Stop Loss
   if(AssertTrue(ValidateScalpSLPips(10.0), "ScalpSL_Pips = 10.0 (tight)")) passed++; else failed++;
   if(AssertTrue(ValidateScalpSLPips(20.0), "ScalpSL_Pips = 20.0 (standard)")) passed++; else failed++;
   if(AssertTrue(ValidateScalpSLPips(50.0), "ScalpSL_Pips = 50.0 (wide)")) passed++; else failed++;
   if(AssertFalse(ValidateScalpSLPips(1.0), "ScalpSL_Pips = 1.0 (too small)")) passed++; else failed++;
   if(AssertFalse(ValidateScalpSLPips(250.0), "ScalpSL_Pips = 250.0 (too large)")) passed++; else failed++;

   // Risk/Reward ratio validation
   if(AssertTrue(ValidateRiskRewardRatio(10.0, 20.0), "TP=10, SL=20 (RR=0.5)")) passed++; else failed++;
   if(AssertTrue(ValidateRiskRewardRatio(15.0, 15.0), "TP=15, SL=15 (RR=1.0)")) passed++; else failed++;
   if(AssertTrue(ValidateRiskRewardRatio(20.0, 10.0), "TP=20, SL=10 (RR=2.0)")) passed++; else failed++;
   if(AssertFalse(ValidateRiskRewardRatio(5.0, 50.0), "TP=5, SL=50 (RR=0.1 too low)")) passed++; else failed++;
   if(AssertFalse(ValidateRiskRewardRatio(100.0, 10.0), "TP=100, SL=10 (RR=10 too high)")) passed++; else failed++;

   // Trailing Stop
   if(AssertTrue(ValidateTrailingStopPips(0.0), "TrailingStop = 0.0 (disabled)")) passed++; else failed++;
   if(AssertTrue(ValidateTrailingStopPips(5.0), "TrailingStop = 5.0 (standard)")) passed++; else failed++;
   if(AssertTrue(ValidateTrailingStopPips(15.0), "TrailingStop = 15.0 (wide)")) passed++; else failed++;
   if(AssertFalse(ValidateTrailingStopPips(-5.0), "TrailingStop = -5.0 (negative)")) passed++; else failed++;
   if(AssertFalse(ValidateTrailingStopPips(120.0), "TrailingStop = 120.0 (excessive)")) passed++; else failed++;

   // Break Even
   if(AssertTrue(ValidateBreakEvenPips(0.0), "BreakEven = 0.0 (disabled)")) passed++; else failed++;
   if(AssertTrue(ValidateBreakEvenPips(5.0), "BreakEven = 5.0 (standard)")) passed++; else failed++;
   if(AssertTrue(ValidateBreakEvenPips(10.0), "BreakEven = 10.0 (conservative)")) passed++; else failed++;
   if(AssertFalse(ValidateBreakEvenPips(-3.0), "BreakEven = -3.0 (negative)")) passed++; else failed++;
   if(AssertFalse(ValidateBreakEvenPips(60.0), "BreakEven = 60.0 (may never trigger)")) passed++; else failed++;

   // Cross-validation
   if(AssertTrue(ValidateTrailingStopVsTP(5.0, 10.0), "Trailing=5, TP=10 (valid)")) passed++; else failed++;
   if(AssertFalse(ValidateTrailingStopVsTP(15.0, 10.0), "Trailing=15, TP=10 (invalid)")) passed++; else failed++;
   if(AssertTrue(ValidateBreakEvenVsTP(5.0, 10.0), "BE=5, TP=10 (valid)")) passed++; else failed++;
   if(AssertFalse(ValidateBreakEvenVsTP(15.0, 10.0), "BE=15, TP=10 (invalid)")) passed++; else failed++;

   Print("");

   // === Test Category 4: Spread & Trading Conditions ===
   Print("─────────────────────────────────────────────────────────────");
   Print("📊 Test Category: SPREAD & TRADING CONDITIONS");
   Print("─────────────────────────────────────────────────────────────");

   if(AssertTrue(ValidateMaxSpreadPoints(10), "MaxSpread = 10 points (tight)")) passed++; else failed++;
   if(AssertTrue(ValidateMaxSpreadPoints(20), "MaxSpread = 20 points (standard)")) passed++; else failed++;
   if(AssertTrue(ValidateMaxSpreadPoints(50), "MaxSpread = 50 points (wide)")) passed++; else failed++;
   if(AssertFalse(ValidateMaxSpreadPoints(0), "MaxSpread = 0 points (invalid)")) passed++; else failed++;
   if(AssertFalse(ValidateMaxSpreadPoints(300), "MaxSpread = 300 points (too wide)")) passed++; else failed++;

   if(AssertTrue(ValidateMaxTradesPerDay(10), "MaxTradesPerDay = 10 (conservative)")) passed++; else failed++;
   if(AssertTrue(ValidateMaxTradesPerDay(50), "MaxTradesPerDay = 50 (moderate)")) passed++; else failed++;
   if(AssertTrue(ValidateMaxTradesPerDay(200), "MaxTradesPerDay = 200 (aggressive)")) passed++; else failed++;
   if(AssertFalse(ValidateMaxTradesPerDay(0), "MaxTradesPerDay = 0 (invalid)")) passed++; else failed++;
   if(AssertFalse(ValidateMaxTradesPerDay(2000), "MaxTradesPerDay = 2000 (unrealistic)")) passed++; else failed++;

   Print("");

   // === Test Category 5: News Filter ===
   Print("─────────────────────────────────────────────────────────────");
   Print("📊 Test Category: NEWS FILTER");
   Print("─────────────────────────────────────────────────────────────");

   if(AssertTrue(ValidateMinutesBeforeNews(15), "MinutesBeforeNews = 15")) passed++; else failed++;
   if(AssertTrue(ValidateMinutesBeforeNews(30), "MinutesBeforeNews = 30")) passed++; else failed++;
   if(AssertTrue(ValidateMinutesBeforeNews(60), "MinutesBeforeNews = 60")) passed++; else failed++;
   if(AssertTrue(ValidateMinutesBeforeNews(0), "MinutesBeforeNews = 0 (disabled)")) passed++; else failed++;
   if(AssertFalse(ValidateMinutesBeforeNews(-10), "MinutesBeforeNews = -10 (invalid)")) passed++; else failed++;
   if(AssertFalse(ValidateMinutesBeforeNews(300), "MinutesBeforeNews = 300 (too long)")) passed++; else failed++;

   if(AssertTrue(ValidateMinutesAfterNews(10), "MinutesAfterNews = 10")) passed++; else failed++;
   if(AssertTrue(ValidateMinutesAfterNews(30), "MinutesAfterNews = 30")) passed++; else failed++;
   if(AssertTrue(ValidateMinutesAfterNews(0), "MinutesAfterNews = 0 (disabled)")) passed++; else failed++;
   if(AssertFalse(ValidateMinutesAfterNews(-5), "MinutesAfterNews = -5 (invalid)")) passed++; else failed++;
   if(AssertFalse(ValidateMinutesAfterNews(360), "MinutesAfterNews = 360 (too long)")) passed++; else failed++;

   Print("");

   // === Test Category 6: Technical Indicators ===
   Print("─────────────────────────────────────────────────────────────");
   Print("📊 Test Category: TECHNICAL INDICATORS");
   Print("─────────────────────────────────────────────────────────────");

   if(AssertTrue(ValidateEMAPeriods(8, 21), "EMA: Fast=8, Slow=21 (standard)")) passed++; else failed++;
   if(AssertTrue(ValidateEMAPeriods(5, 20), "EMA: Fast=5, Slow=20 (fast)")) passed++; else failed++;
   if(AssertTrue(ValidateEMAPeriods(12, 26), "EMA: Fast=12, Slow=26 (slow)")) passed++; else failed++;
   if(AssertFalse(ValidateEMAPeriods(1, 21), "EMA: Fast=1 (too small)")) passed++; else failed++;
   if(AssertFalse(ValidateEMAPeriods(21, 8), "EMA: Fast=21, Slow=8 (reversed)")) passed++; else failed++;
   if(AssertFalse(ValidateEMAPeriods(10, 10), "EMA: Fast=10, Slow=10 (equal)")) passed++; else failed++;

   if(AssertTrue(ValidateRSIPeriod(9), "RSI_Period = 9 (fast)")) passed++; else failed++;
   if(AssertTrue(ValidateRSIPeriod(14), "RSI_Period = 14 (standard)")) passed++; else failed++;
   if(AssertTrue(ValidateRSIPeriod(21), "RSI_Period = 21 (slow)")) passed++; else failed++;
   if(AssertFalse(ValidateRSIPeriod(1), "RSI_Period = 1 (too small)")) passed++; else failed++;
   if(AssertFalse(ValidateRSIPeriod(150), "RSI_Period = 150 (too slow)")) passed++; else failed++;

   if(AssertTrue(ValidateATRPeriod(14), "ATR_Period = 14 (standard)")) passed++; else failed++;
   if(AssertTrue(ValidateATRPeriod(10), "ATR_Period = 10 (fast)")) passed++; else failed++;
   if(AssertTrue(ValidateATRPeriod(20), "ATR_Period = 20 (slow)")) passed++; else failed++;
   if(AssertFalse(ValidateATRPeriod(1), "ATR_Period = 1 (too small)")) passed++; else failed++;
   if(AssertFalse(ValidateATRPeriod(120), "ATR_Period = 120 (too slow)")) passed++; else failed++;

   if(AssertTrue(ValidateATRFilter(1.0), "ATR_Filter = 1.0 (standard)")) passed++; else failed++;
   if(AssertTrue(ValidateATRFilter(1.5), "ATR_Filter = 1.5 (moderate)")) passed++; else failed++;
   if(AssertTrue(ValidateATRFilter(2.0), "ATR_Filter = 2.0 (strict)")) passed++; else failed++;
   if(AssertFalse(ValidateATRFilter(-1.0), "ATR_Filter = -1.0 (negative)")) passed++; else failed++;
   if(AssertFalse(ValidateATRFilter(15.0), "ATR_Filter = 15.0 (too restrictive)")) passed++; else failed++;

   Print("");

   // === Test Category 7: AI/ONNX ===
   Print("─────────────────────────────────────────────────────────────");
   Print("📊 Test Category: AI/ONNX");
   Print("─────────────────────────────────────────────────────────────");

   if(AssertTrue(ValidateMinConfidence(0.5), "MinConfidence = 0.5 (moderate)")) passed++; else failed++;
   if(AssertTrue(ValidateMinConfidence(0.75), "MinConfidence = 0.75 (high)")) passed++; else failed++;
   if(AssertTrue(ValidateMinConfidence(0.9), "MinConfidence = 0.9 (very high)")) passed++; else failed++;
   if(AssertTrue(ValidateMinConfidence(0.0), "MinConfidence = 0.0 (edge case)")) passed++; else failed++;
   if(AssertTrue(ValidateMinConfidence(1.0), "MinConfidence = 1.0 (edge case)")) passed++; else failed++;
   if(AssertFalse(ValidateMinConfidence(-0.1), "MinConfidence = -0.1 (invalid)")) passed++; else failed++;
   if(AssertFalse(ValidateMinConfidence(1.5), "MinConfidence = 1.5 (invalid)")) passed++; else failed++;

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
      Print("║  ✅ ALL TESTS PASSED - VALIDATION SUITE COMPLETE          ║");
      Print("╚════════════════════════════════════════════════════════════╝");
   } else {
      Print("╔════════════════════════════════════════════════════════════╗");
      Print("║  ❌ SOME TESTS FAILED - REVIEW VALIDATION LOGIC           ║");
      Print("╚════════════════════════════════════════════════════════════╝");
   }
}
