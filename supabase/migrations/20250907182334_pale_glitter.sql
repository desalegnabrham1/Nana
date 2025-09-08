/*
  # Enable anonymous user registration

  1. Security Changes
    - Drop existing restrictive INSERT policies for users table
    - Add new policy allowing anonymous users to register
    - Maintain existing SELECT and UPDATE policies for authenticated users

  2. Changes Made
    - Remove any existing INSERT policies that might be blocking registration
    - Create new policy "Enable user registration" for anon role
    - Allow INSERT operations for anonymous users during registration
*/

-- Drop any existing INSERT policies that might be blocking registration
DROP POLICY IF EXISTS "Allow anonymous user registration" ON users;
DROP POLICY IF EXISTS "Allow user registration" ON users;
DROP POLICY IF EXISTS "Users can insert own data" ON users;

-- Create a new policy that allows anonymous users to register
CREATE POLICY "Enable user registration"
  ON users
  FOR INSERT
  TO anon
  WITH CHECK (true);