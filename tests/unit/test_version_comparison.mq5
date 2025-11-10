//+------------------------------------------------------------------+
//| Test: CompareVersions() Function                                  |
//| Tests semantic version comparison logic                           |
//+------------------------------------------------------------------+
#property copyright "fred-selest"
#property link      "https://github.com/fred-selest/ea-scalping-pro"
#property version   "1.00"
#property script_show_inputs
#property description "Unit tests for CompareVersions() function"

//+------------------------------------------------------------------+
//| Assert Helper                                                     |
//+------------------------------------------------------------------+
bool AssertEquals(int expected, int actual, string test_name)
{
   if(expected == actual) {
      Print("✅ ", test_name, ": PASSED");
      return true;
   } else {
      Print("❌ ", test_name, ": FAILED");
      Print("   Expected: ", expected);
      Print("   Actual: ", actual);
      return false;
   }
}

//+------------------------------------------------------------------+
//| CompareVersions() - Copy from EA                                  |
//+------------------------------------------------------------------+
int CompareVersions(string v1, string v2)
{
   string parts1[], parts2[];
   StringSplit(v1, '.', parts1);
   StringSplit(v2, '.', parts2);

   int major1 = (int)StringToInteger(parts1[0]);
   int minor1 = ArraySize(parts1) > 1 ? (int)StringToInteger(parts1[1]) : 0;

   int major2 = (int)StringToInteger(parts2[0]);
   int minor2 = ArraySize(parts2) > 1 ? (int)StringToInteger(parts2[1]) : 0;

   int num1 = major1 * 1000 + minor1;
   int num2 = major2 * 1000 + minor2;

   if(num1 > num2) return 1;
   if(num1 < num2) return -1;
   return 0;
}

//+------------------------------------------------------------------+
//| Test Main Function                                                |
//+------------------------------------------------------------------+
void OnStart()
{
   Print("");
   Print("╔════════════════════════════════════════════╗");
   Print("║  Test: CompareVersions()                 ║");
   Print("╚════════════════════════════════════════════╝");
   Print("");

   int passed = 0;
   int failed = 0;

   // Test Case 1: Newer version (minor)
   if(AssertEquals(1, CompareVersions("27.52", "27.51"), "v27.52 > v27.51")) {
      passed++;
   } else {
      failed++;
   }

   // Test Case 2: Older version (minor)
   if(AssertEquals(-1, CompareVersions("27.51", "27.52"), "v27.51 < v27.52")) {
      passed++;
   } else {
      failed++;
   }

   // Test Case 3: Equal versions
   if(AssertEquals(0, CompareVersions("27.52", "27.52"), "v27.52 == v27.52")) {
      passed++;
   } else {
      failed++;
   }

   // Test Case 4: Newer version (major)
   if(AssertEquals(1, CompareVersions("28.0", "27.99"), "v28.0 > v27.99")) {
      passed++;
   } else {
      failed++;
   }

   // Test Case 5: Older version (major)
   if(AssertEquals(-1, CompareVersions("26.0", "27.0"), "v26.0 < v27.0")) {
      passed++;
   } else {
      failed++;
   }

   // Test Case 6: Single digit vs double digit
   if(AssertEquals(-1, CompareVersions("27.5", "27.50"), "v27.5 < v27.50")) {
      passed++;
   } else {
      failed++;
   }

   // Test Case 7: Major version dominates
   if(AssertEquals(1, CompareVersions("28.1", "27.99"), "v28.1 > v27.99")) {
      passed++;
   } else {
      failed++;
   }

   // Test Case 8: Zero minor version
   if(AssertEquals(1, CompareVersions("28.0", "27.52"), "v28.0 > v27.52")) {
      passed++;
   } else {
      failed++;
   }

   // Results Summary
   Print("");
   Print("════════════════════════════════════════════");
   Print("📊 TEST RESULTS");
   Print("════════════════════════════════════════════");
   Print("Total Tests: ", passed + failed);
   Print("Passed: ", passed, " ✅");
   Print("Failed: ", failed, " ❌");
   Print("Success Rate: ", DoubleToString((passed * 100.0 / (passed + failed)), 1), "%");
   Print("════════════════════════════════════════════");

   if(failed == 0) {
      Print("✅ ALL TESTS PASSED");
   } else {
      Print("❌ SOME TESTS FAILED");
   }
   Print("");
}
