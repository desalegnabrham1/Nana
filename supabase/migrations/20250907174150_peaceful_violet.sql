/*
  # Create users table for Telegram bot

  1. New Tables
    - `users`
      - `id` (uuid, primary key)
      - `phone` (text, unique) - User's phone number
      - `name` (text) - User's name from Telegram
      - `password` (text) - User's password (consider encryption for production)
      - `telegram_id` (bigint, unique) - Telegram user ID
      - `created_at` (timestamp) - Registration timestamp
      - `updated_at` (timestamp) - Last update timestamp

  2. Security
    - Enable RLS on `users` table
    - Add policy for authenticated users to read their own data
    - Add policy for authenticated users to update their own data

  3. Indexes
    - Index on phone for fast lookups
    - Index on telegram_id for fast lookups
*/

CREATE TABLE IF NOT EXISTS users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  phone text UNIQUE NOT NULL,
  name text NOT NULL DEFAULT '',
  password text NOT NULL,
  telegram_id bigint UNIQUE NOT NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Enable Row Level Security
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_users_phone ON users(phone);
CREATE INDEX IF NOT EXISTS idx_users_telegram_id ON users(telegram_id);

-- RLS Policies
CREATE POLICY "Users can read own data"
  ON users
  FOR SELECT
  TO authenticated
  USING (auth.uid()::text = id::text);

CREATE POLICY "Users can update own data"
  ON users
  FOR UPDATE
  TO authenticated
  USING (auth.uid()::text = id::text);

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger to automatically update updated_at
CREATE TRIGGER update_users_updated_at
  BEFORE UPDATE ON users
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();