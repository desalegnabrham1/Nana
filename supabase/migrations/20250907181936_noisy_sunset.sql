/*
  # Fix user registration RLS policy

  1. Security Updates
    - Add policy for anonymous users to insert new registrations
    - Allow public registration while maintaining data security
    - Keep existing policies for authenticated user access

  2. Changes
    - Add "Allow user registration" policy for INSERT operations
    - Permits anonymous users to create new accounts
    - Maintains security for read/update operations
*/

-- Add policy to allow anonymous users to register (INSERT)
CREATE POLICY "Allow user registration"
  ON users
  FOR INSERT
  TO anon
  WITH CHECK (true);