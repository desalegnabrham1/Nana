# Telegram Registration Bot

A Node.js Telegram bot built with Telegraf that handles user registration and login flows.

## Features

- **Main Menu**: Interactive buttons for Register and Login
- **Registration Flow**: Collects phone number, password, and confirmation
- **Login Flow**: Validates credentials against stored data
- **Data Validation**: Checks for duplicate phones and password matching
- **In-Memory Storage**: Stores user data during bot session
- **Error Handling**: Proper error messages and flow control

## Setup Instructions

1. **Create a Telegram Bot**:
   - Open Telegram and search for `@BotFather`
   - Send `/newbot` and follow the instructions
   - Copy the bot token provided

2. **Configure the Bot**:
   - Open `bot.js`
   - Replace `YOUR_BOT_TOKEN_HERE` with your actual bot token

3. **Install Dependencies**:
   ```bash
   npm install
   ```

4. **Run the Bot**:
   ```bash
   node bot.js
   ```

## Bot Commands

- `/start` - Show the main menu
- `/menu` - Display main menu anytime
- `/users` - Show registered users (for testing)

## Usage Flow

### Registration:
1. User clicks "📝 Register"
2. Bot asks for phone number
3. Bot asks for password
4. Bot asks to confirm password
5. System validates and saves user data

### Login:
1. User clicks "🔑 Login"
2. Bot asks for phone number
3. Bot asks for password
4. System validates credentials

## Data Structure

Users are stored in memory as objects with:
```javascript
{
  phone: "user_phone_number",
  name: "user_telegram_name", 
  password: "user_password",
  telegramId: telegram_user_id
}
```

## Error Handling

- Duplicate phone numbers during registration
- Password mismatch during registration
- Invalid credentials during login
- Invalid input validation

## Notes

- Data is stored in memory and will be lost when the bot restarts
- For production use, consider implementing persistent storage (database)
- Passwords are stored in plain text - implement encryption for production use"# Nana" 
