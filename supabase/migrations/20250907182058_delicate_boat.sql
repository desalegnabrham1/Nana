/*
  # Allow anonymous user registration

  1. Security Policy Changes
    - Add policy to allow anonymous users to register (INSERT into users table)
    - This enables the Telegram bot to create new user accounts
    - Maintains existing security for SELECT and UPDATE operations

  2. Important Notes
    - Only allows INSERT operations for anonymous users during registration
    - Does not affect existing policies for reading/updating user data
*/

-- Allow anonymous users to register (insert new users)
CREATE POLICY "Allow anonymous user registration"
  ON users
  FOR INSERT
  TO anon
  WITH CHECK (true);