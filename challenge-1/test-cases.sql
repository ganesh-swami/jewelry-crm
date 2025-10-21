-- CHALLENGE 1: Test cases for the update_customer_company function
-- This file contains comprehensive test cases for all scenarios

-- ============================================================================
-- SETUP: Insert test data
-- ============================================================================
-- Note: These IDs should match the sample data, or create new test customers
DO $$
BEGIN
    -- Insert test customers if they don't exist
    INSERT INTO customers (id, name, email, company) 
    VALUES 
        ('550e8400-e29b-41d4-a716-446655440001', 'John Doe', 'john@example.com', 'Acme Corp'),
        ('550e8400-e29b-41d4-a716-446655440002', 'Jane Smith', 'jane@example.com', 'Tech Solutions'),
        ('550e8400-e29b-41d4-a716-446655440003', 'Bob Johnson', 'bob@example.com', 'Design Studio')
    ON CONFLICT (id) DO NOTHING;
END $$;

-- ============================================================================
-- TEST 1: Valid Update - Should succeed
-- ============================================================================
-- Expected: success = true, company updated
SELECT 'TEST 1: Valid Update' AS test_name;
SELECT update_customer_company('New Innovative Company', '550e8400-e29b-41d4-a716-446655440001') AS result;

-- Verify the update in the customers table
SELECT id, name, company, updated_at 
FROM customers 
WHERE id = '550e8400-e29b-41d4-a716-446655440001';

-- Verify audit log was created
SELECT table_name, action, old_value, new_value, changed_by 
FROM audit_logs 
WHERE record_id = '550e8400-e29b-41d4-a716-446655440001' 
ORDER BY created_at DESC 
LIMIT 1;

-- ============================================================================
-- TEST 2: Invalid Customer ID - Should fail with "Customer not found"
-- ============================================================================
SELECT 'TEST 2: Invalid Customer ID' AS test_name;
SELECT update_customer_company('Some Company', '00000000-0000-0000-0000-000000000000') AS result;

-- ============================================================================
-- TEST 3: Empty Company Name - Should fail with "Company name is required"
-- ============================================================================
SELECT 'TEST 3: Empty Company Name' AS test_name;
SELECT update_customer_company('', '550e8400-e29b-41d4-a716-446655440002') AS result;

-- ============================================================================
-- TEST 4: NULL Company Name - Should fail with "Company name is required"
-- ============================================================================
SELECT 'TEST 4: NULL Company Name' AS test_name;
SELECT update_customer_company(NULL, '550e8400-e29b-41d4-a716-446655440002') AS result;

-- ============================================================================
-- TEST 5: Whitespace-Only Company Name - Should fail
-- ============================================================================
SELECT 'TEST 5: Whitespace-Only Company Name' AS test_name;
SELECT update_customer_company('   ', '550e8400-e29b-41d4-a716-446655440002') AS result;

-- ============================================================================
-- TEST 6: Company Name Too Long - Should fail
-- ============================================================================
SELECT 'TEST 6: Company Name Too Long (>255 chars)' AS test_name;
SELECT update_customer_company(
    REPEAT('A', 256), -- 256 characters
    '550e8400-e29b-41d4-a716-446655440002'
) AS result;

-- ============================================================================
-- TEST 7: Valid Update with Special Characters
-- ============================================================================
SELECT 'TEST 7: Valid Update with Special Characters' AS test_name;
SELECT update_customer_company('Johnson & Sons, Inc.', '550e8400-e29b-41d4-a716-446655440003') AS result;

-- ============================================================================
-- TEST 8: Valid Update with Unicode Characters
-- ============================================================================
SELECT 'TEST 8: Valid Update with Unicode Characters' AS test_name;
SELECT update_customer_company('Café Société™', '550e8400-e29b-41d4-a716-446655440003') AS result;

-- ============================================================================
-- TEST 9: Update Same Company Name Twice (Idempotency Test)
-- ============================================================================
SELECT 'TEST 9: Update Same Company Name Twice' AS test_name;
SELECT update_customer_company('Consistent Company', '550e8400-e29b-41d4-a716-446655440001') AS result_1;
SELECT update_customer_company('Consistent Company', '550e8400-e29b-41d4-a716-446655440001') AS result_2;

-- ============================================================================
-- TEST 10: Update with Maximum Valid Length (255 chars)
-- ============================================================================
SELECT 'TEST 10: Update with Maximum Valid Length (255 chars)' AS test_name;
SELECT update_customer_company(
    REPEAT('B', 255), -- Exactly 255 characters
    '550e8400-e29b-41d4-a716-446655440002'
) AS result;

-- ============================================================================
-- TEST 11: Verify Multiple Updates Create Multiple Audit Logs
-- ============================================================================
SELECT 'TEST 11: Multiple Updates and Audit Logs' AS test_name;
SELECT update_customer_company('Company Version 1', '550e8400-e29b-41d4-a716-446655440001');
SELECT update_customer_company('Company Version 2', '550e8400-e29b-41d4-a716-446655440001');
SELECT update_customer_company('Company Version 3', '550e8400-e29b-41d4-a716-446655440001');

-- Check all audit logs for this customer
SELECT COUNT(*) AS audit_log_count, 
       array_agg(new_value ORDER BY created_at) AS company_history
FROM audit_logs 
WHERE record_id = '550e8400-e29b-41d4-a716-446655440001';

-- ============================================================================
-- SUMMARY: Display all test results
-- ============================================================================
SELECT 'TEST SUMMARY' AS summary;
SELECT 
    COUNT(*) AS total_customers,
    COUNT(CASE WHEN company IS NOT NULL THEN 1 END) AS customers_with_company
FROM customers;

SELECT 
    COUNT(*) AS total_audit_logs,
    COUNT(DISTINCT record_id) AS unique_customers_updated
FROM audit_logs;

-- ============================================================================
-- CLEANUP (Optional - uncomment to reset test data)
-- ============================================================================
/*
DELETE FROM audit_logs WHERE record_id IN (
    '550e8400-e29b-41d4-a716-446655440001',
    '550e8400-e29b-41d4-a716-446655440002',
    '550e8400-e29b-41d4-a716-446655440003'
);

DELETE FROM customers WHERE id IN (
    '550e8400-e29b-41d4-a716-446655440001',
    '550e8400-e29b-41d4-a716-446655440002',
    '550e8400-e29b-41d4-a716-446655440003'
);
*/
