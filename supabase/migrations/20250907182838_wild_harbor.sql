/*
  # Fix users table RLS policies for registration

  1. Security Changes
    - Drop existing restrictive policies
    - Add policy to allow anonymous registration
    - Add policy to allow service role full access
    - Keep existing authenticated user policies

  This migration ensures the Telegram bot can register users while maintaining security.
*/

-- Drop existing policies that might be blocking registration
DROP POLICY IF EXISTS "Enable user registration" ON users;
DROP POLICY IF EXISTS "Users can read own data" ON users;
DROP POLICY IF EXISTS "Users can update own data" ON users;

-- Allow anonymous users to register (insert new users)
CREATE POLICY "Allow anonymous registration"
  ON users
  FOR INSERT
  TO anon
  WITH CHECK (true);

-- Allow service role full access (for bot operations)
CREATE POLICY "Service role full access"
  ON users
  FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);

-- Allow authenticated users to read their own data
CREATE POLICY "Users can read own data"
  ON users
  FOR SELECT
  TO authenticated
  USING (auth.uid()::text = id::text);

-- Allow authenticated users to update their own data
CREATE POLICY "Users can update own data"
  ON users
  FOR UPDATE
  TO authenticated
  USING (auth.uid()::text = id::text)
  WITH CHECK (auth.uid()::text = id::text);