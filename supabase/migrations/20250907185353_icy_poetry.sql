/*
  # Disable RLS policies for users table

  1. Changes
    - Disable Row Level Security on users table
    - Drop all existing RLS policies
    - Allow unrestricted access to the table

  2. Security
    - RLS is completely disabled
    - All operations allowed without restrictions
*/

-- Disable RLS on users table
ALTER TABLE users DISABLE ROW LEVEL SECURITY;

-- Drop all existing policies (if any exist)
DROP POLICY IF EXISTS "Allow anonymous registration" ON users;
DROP POLICY IF EXISTS "Service role full access" ON users;
DROP POLICY IF EXISTS "Users can read own data" ON users;

-- Also disable RLS on user_credentials table if it exists
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'user_credentials') THEN
        ALTER TABLE user_credentials DISABLE ROW LEVEL SECURITY;
        DROP POLICY IF EXISTS "Allow anonymous registration" ON user_credentials;
        DROP POLICY IF EXISTS "Service role full access" ON user_credentials;
        DROP POLICY IF EXISTS "Users can read own credentials" ON user_credentials;
    END IF;
END $$;