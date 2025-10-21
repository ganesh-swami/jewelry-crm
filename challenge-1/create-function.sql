-- CHALLENGE 1: Create the missing update_customer_company function
-- This file contains the complete SQL function definition with validation and audit logging

-- First, create the audit_logs table if it doesn't exist
CREATE TABLE IF NOT EXISTS audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    table_name VARCHAR(255) NOT NULL,
    record_id UUID NOT NULL,
    action VARCHAR(50) NOT NULL,
    old_value TEXT,
    new_value TEXT,
    changed_by VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create the update_customer_company function
CREATE OR REPLACE FUNCTION update_customer_company(
    company_name VARCHAR(255),
    customer_id UUID
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    v_customer_exists BOOLEAN;
    v_old_company VARCHAR(255);
    v_updated_at TIMESTAMP WITH TIME ZONE;
    v_result JSON;
BEGIN
    -- Validate company_name is not NULL or empty
    IF company_name IS NULL OR TRIM(company_name) = '' THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Company name is required',
            'message', 'Company name cannot be empty or NULL'
        );
    END IF;
    
    -- Validate company_name length (reasonable limit)
    IF LENGTH(company_name) > 255 THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Company name too long',
            'message', 'Company name must be less than 255 characters'
        );
    END IF;
    
    -- Check if customer exists and get old company value
    SELECT EXISTS(SELECT 1 FROM customers WHERE id = customer_id),
           company
    INTO v_customer_exists, v_old_company
    FROM customers
    WHERE id = customer_id;
    
    -- If customer doesn't exist, return error
    IF NOT v_customer_exists THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Customer not found',
            'message', 'No customer found with the provided ID'
        );
    END IF;
    
    -- Update the customer's company field
    UPDATE customers
    SET company = company_name,
        updated_at = NOW()
    WHERE id = customer_id
    RETURNING updated_at INTO v_updated_at;
    
    -- Create audit log entry
    INSERT INTO audit_logs (
        table_name,
        record_id,
        action,
        old_value,
        new_value,
        changed_by
    ) VALUES (
        'customers',
        customer_id,
        'UPDATE',
        v_old_company,
        company_name,
        current_user
    );
    
    -- Return success response
    v_result := json_build_object(
        'success', true,
        'message', 'Company updated successfully',
        'data', json_build_object(
            'customer_id', customer_id,
            'old_company', v_old_company,
            'new_company', company_name,
            'updated_at', v_updated_at
        )
    );
    
    RETURN v_result;
    
EXCEPTION
    WHEN OTHERS THEN
        -- Handle any unexpected errors
        RETURN json_build_object(
            'success', false,
            'error', 'Database error',
            'message', SQLERRM
        );
END;
$$;

-- Add helpful comment to the function
COMMENT ON FUNCTION update_customer_company(VARCHAR, UUID) IS 
'Updates the company field for a customer with validation and audit logging. 
Returns JSON with success status, error messages, and updated data.';
