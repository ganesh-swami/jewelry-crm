// CHALLENGE 1: TypeScript types for the update_customer_company function
// This file contains complete TypeScript type definitions for the function and its responses

/**
 * Parameters for the update_customer_company RPC function
 */
export interface UpdateCustomerCompanyParams {
  /** The new company name to set for the customer */
  company_name: string;
  /** The UUID of the customer to update */
  customer_id: string;
}

/**
 * Data returned on successful update
 */
export interface UpdateCustomerCompanyData {
  /** The customer ID that was updated */
  customer_id: string;
  /** The previous company name (may be null) */
  old_company: string | null;
  /** The new company name */
  new_company: string;
  /** Timestamp when the update occurred */
  updated_at: string;
}

/**
 * Success response from the update_customer_company function
 */
export interface UpdateCustomerCompanySuccessResponse {
  /** Indicates the operation was successful */
  success: true;
  /** Success message */
  message: string;
  /** The updated customer data */
  data: UpdateCustomerCompanyData;
}

/**
 * Error response from the update_customer_company function
 */
export interface UpdateCustomerCompanyErrorResponse {
  /** Indicates the operation failed */
  success: false;
  /** Short error identifier */
  error: string;
  /** Detailed error message */
  message: string;
}

/**
 * Combined response type (can be either success or error)
 */
export type UpdateCustomerCompanyResponse = 
  | UpdateCustomerCompanySuccessResponse 
  | UpdateCustomerCompanyErrorResponse;

/**
 * Type guard to check if response is an error
 */
export function isUpdateCustomerCompanyError(
  response: UpdateCustomerCompanyResponse
): response is UpdateCustomerCompanyErrorResponse {
  return response.success === false;
}

/**
 * Type guard to check if response is successful
 */
export function isUpdateCustomerCompanySuccess(
  response: UpdateCustomerCompanyResponse
): response is UpdateCustomerCompanySuccessResponse {
  return response.success === true;
}

/**
 * Common error types that can be returned
 */
export enum UpdateCustomerCompanyErrorType {
  CUSTOMER_NOT_FOUND = 'Customer not found',
  COMPANY_NAME_REQUIRED = 'Company name is required',
  COMPANY_NAME_TOO_LONG = 'Company name too long',
  DATABASE_ERROR = 'Database error',
}

/**
 * Customer record type (for reference)
 */
export interface Customer {
  id: string;
  name: string;
  email: string;
  company: string | null;
  created_at: string;
  updated_at: string;
}

/**
 * Audit log entry type (for reference)
 */
export interface AuditLog {
  id: string;
  table_name: string;
  record_id: string;
  action: string;
  old_value: string | null;
  new_value: string;
  changed_by: string;
  created_at: string;
}
