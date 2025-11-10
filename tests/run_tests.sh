#!/bin/bash
#==============================================================================
# Script d'exécution des tests - EA Scalping Pro
# Usage: ./run_tests.sh
#==============================================================================

set -e

# Couleurs
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }

# Banner
echo ""
echo "╔════════════════════════════════════════════╗"
echo "║   🧪 EA Scalping Pro - Test Suite       ║"
echo "╚════════════════════════════════════════════╝"
echo ""

# Find MetaEditor
METAEDITOR=""
if command -v metaeditor64.exe &> /dev/null; then
    METAEDITOR="metaeditor64.exe"
elif [ -f "/c/Program Files/MetaTrader 5/metaeditor64.exe" ]; then
    METAEDITOR="/c/Program Files/MetaTrader 5/metaeditor64.exe"
elif [ -f "$HOME/.wine/drive_c/Program Files/MetaTrader 5/metaeditor64.exe" ]; then
    METAEDITOR="wine $HOME/.wine/drive_c/Program Files/MetaTrader 5/metaeditor64.exe"
else
    print_error "MetaEditor not found"
    echo "Please install MetaTrader 5 or set METAEDITOR environment variable"
    exit 1
fi

print_info "Using MetaEditor: $METAEDITOR"
echo ""

# Compile and run tests
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Function to run a test
run_test() {
    local test_file=$1
    local test_name=$(basename "$test_file" .mq5)

    print_info "Running: $test_name"

    # Compile
    if $METAEDITOR /compile:"$test_file" /log:"test_compile.log" 2>&1 | grep -q "0 error"; then
        print_success "Compiled: $test_name"

        # Check if .ex5 created
        local ex5_file="${test_file/.mq5/.ex5}"
        if [ -f "$ex5_file" ]; then
            print_success "Test executable created"
            ((PASSED_TESTS++))
        else
            print_error "Compilation succeeded but .ex5 not found"
            ((FAILED_TESTS++))
        fi
    else
        print_error "Compilation failed: $test_name"
        if [ -f "test_compile.log" ]; then
            cat test_compile.log
        fi
        ((FAILED_TESTS++))
    fi

    ((TOTAL_TESTS++))
    echo ""
}

# Run unit tests
print_info "=== Unit Tests ==="
echo ""

if [ -d "unit" ]; then
    for test_file in unit/test_*.mq5; do
        if [ -f "$test_file" ]; then
            run_test "$test_file"
        fi
    done
else
    print_error "Unit tests directory not found"
fi

# Summary
echo ""
echo "════════════════════════════════════════════"
echo "📊 TEST SUITE RESULTS"
echo "════════════════════════════════════════════"
echo "Total Tests: $TOTAL_TESTS"
echo "Passed: $PASSED_TESTS ✅"
echo "Failed: $FAILED_TESTS ❌"

if [ $TOTAL_TESTS -gt 0 ]; then
    SUCCESS_RATE=$(awk "BEGIN {printf \"%.1f\", ($PASSED_TESTS * 100.0 / $TOTAL_TESTS)}")
    echo "Success Rate: $SUCCESS_RATE%"
fi

echo "════════════════════════════════════════════"

if [ $FAILED_TESTS -eq 0 ] && [ $TOTAL_TESTS -gt 0 ]; then
    print_success "ALL TESTS PASSED"
    exit 0
else
    if [ $TOTAL_TESTS -eq 0 ]; then
        print_error "NO TESTS FOUND"
    else
        print_error "SOME TESTS FAILED"
    fi
    exit 1
fi
