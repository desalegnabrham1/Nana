/*
  # Fix RLS policy for user registration

  1. Security Changes
    - Drop existing conflicting INSERT policy for anonymous users
    - Create new permissive INSERT policy for anonymous registration
    - Ensure service role maintains full access
  
  2. Policy Details
    - Allow anonymous users to insert new user records during registration
    - Use permissive WITH CHECK to allow all valid inserts
    - Maintain existing security for SELECT and UPDATE operations
*/

-- Drop any existing INSERT policy that might be conflicting
DROP POLICY IF EXISTS "Allow anonymous registration" ON users;
DROP POLICY IF EXISTS "Enable insert for anon users" ON users;

-- Create a new INSERT policy that allows anonymous users to register
CREATE POLICY "Allow user registration" 
  ON users 
  FOR INSERT 
  TO anon 
  WITH CHECK (true);

-- Ensure service role has full access (this should already exist but let's be sure)
DROP POLICY IF EXISTS "Service role full access" ON users;
CREATE POLICY "Service role full access" 
  ON users 
  FOR ALL 
  TO service_role 
  USING (true) 
  WITH CHECK (true);