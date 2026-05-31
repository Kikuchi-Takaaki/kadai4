#!/bin/bash

# テストが失敗した数をカウントする変数
errors=0

# --- テスト関数定義 ---
run_test() {
    local test_name="$1"
    local cmd="$2"
    local expected_exit="$3"
    local expected_out="$4"

    local out
    out=$(eval "$cmd" 2>/dev/null)
    local actual_exit=$?

    # 1. 終了ステータスのチェック
    if [ "$actual_exit" -ne "$expected_exit" ]; then
        echo "[FAIL] $test_name (終了コードが違います。期待: $expected_exit, 実際: $actual_exit)"
        errors=$((errors + 1))
        return 1
    fi

    # 2. 出力値のチェック（正常系のみ）
    if [ "$expected_exit" -eq 0 ] && [ "$out" != "$expected_out" ]; then
        echo "[FAIL] $test_name (出力が違います。期待: $expected_out, 実際: $out)"
        errors=$((errors + 1))
        return 1
    fi

    echo "[PASS] $test_name"
    return 0
}

# --- ここからテストケース実行 ---

echo "=== テストを開始します ==="

# 【正常系のテスト】
run_test "正常系: 2 と 4"   "./gcd.sh 2 4"   0 "2"
run_test "正常系: 5 と 21"  "./gcd.sh 5 21"  0 "1"
run_test "正常系: 12 と 18" "./gcd.sh 12 18" 0 "6"

# 【異常系のテスト】
run_test "異常系: 引数が1つ"    "./gcd.sh 2"      1
run_test "異常系: 引数が3つ"    "./gcd.sh 2 4 6"  1
run_test "異常系: 文字が混入"   "./gcd.sh a 4"    1
run_test "異常系: 負の数"       "./gcd.sh -2 4"   1
run_test "異常系: 小数"         "./gcd.sh 2.5 4"  1

echo "=== テスト終了 ==="

if [ "$errors" -ne 0 ]; then
    echo "警告: いくつかテストが失敗しています (合計: $errors 件)"
    exit 1
else
    echo "すべてのテストを通過しました。"
    exit 0
fi
