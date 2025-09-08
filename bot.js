require('dotenv').config();

const { Telegraf, Scenes, session, Markup } = require('telegraf');
const supabase = require('./lib/supabase');

// Replace this with your actual bot token from BotFather
const BOT_TOKEN = process.env.BOT_TOKEN || '8273174391:AAH4MMskCIfaxqz6B7_eRXBwU_lA0H6fR78';

// Check if bot token is provided
if (BOT_TOKEN === 'YOUR_BOT_TOKEN_HERE' || !BOT_TOKEN) {
    console.error('❌ Error: Please set your bot token!');
    console.error('📝 Instructions:');
    console.error('   1. Get a token from @BotFather on Telegram');
    console.error('   2. Set BOT_TOKEN environment variable: export BOT_TOKEN=your_token_here');
    console.error('   3. Or replace YOUR_BOT_TOKEN_HERE in bot.js with your actual token');
    process.exit(1);
}

// Initialize bot
const bot = new Telegraf(BOT_TOKEN);

// Helper function to find user by phone in database
const findUserByPhone = async (phone) => {
    try {
        const { data, error } = await supabase
            .from('users')
            .select('*')
            .eq('phone', phone)
            .single();
        
        if (error && error.code !== 'PGRST116') { // PGRST116 is "not found" error
            console.error('Database error:', error);
            return null;
        }
        
        return data;
    } catch (err) {
        console.error('Error finding user:', err);
        return null;
    }
};

// Helper function to create user in database
const createUser = async (userData) => {
    try {
        console.log('Attempting to create user:', { ...userData, password: '[HIDDEN]' });
        
        const { data, error } = await supabase
            .from('users')
            .insert([userData])
            .select()
            .single();
        
        if (error) {
            console.error('Database error details:', {
                code: error.code,
                message: error.message,
                details: error.details,
                hint: error.hint
            });
            return null;
        }
        
        console.log('User created successfully:', { ...data, password: '[HIDDEN]' });
        return data;
    } catch (err) {
        console.error('Error creating user:', err);
        return null;
    }
};

// Helper function to create main menu
const createMainMenu = () => {
    return Markup.keyboard([
        ['📝 Register', '🔑 Login']
    ]).resize();
};

// Helper function to create inline buttons
const createInlineMenu = () => {
    return Markup.inlineKeyboard([
        [Markup.button.callback('📝 Register', 'register')],
        [Markup.button.callback('🔑 Login', 'login')]
    ]);
};

// Registration Scene
const registrationScene = new Scenes.WizardScene('registration',
    // Step 1: Ask for phone number
    async (ctx) => {
        ctx.reply('📱 Please enter your phone number:', Markup.removeKeyboard());
        return ctx.wizard.next();
    },
    // Step 2: Store phone and ask for password
    async (ctx) => {
        const phone = ctx.message?.text?.trim();
        
        if (!phone) {
            ctx.reply('❌ Please enter a valid phone number.');
            return;
        }

        // Check if phone already exists
        if (await findUserByPhone(phone)) {
            ctx.reply('❌ The mobile has already been taken', createMainMenu());
            return ctx.scene.leave();
        }

        ctx.wizard.state.phone = phone;
        ctx.reply('🔒 Please enter your password:');
        return ctx.wizard.next();
    },
    // Step 3: Store password and ask for confirmation
    async (ctx) => {
        const password = ctx.message?.text?.trim();
        
        if (!password) {
            ctx.reply('❌ Please enter a valid password.');
            return;
        }

        ctx.wizard.state.password = password;
        ctx.reply('🔒 Please confirm your password:');
        return ctx.wizard.next();
    },
    // Step 4: Verify passwords match and complete registration
    async (ctx) => {
        const confirmPassword = ctx.message?.text?.trim();
        
        if (!confirmPassword) {
            ctx.reply('❌ Please enter the password confirmation.');
            return;
        }

        if (ctx.wizard.state.password !== confirmPassword) {
            ctx.reply('❌ Passwords do not match', createMainMenu());
            return ctx.scene.leave();
        }

        // Get user's name (first name from Telegram)
        const name = ctx.from.first_name || 'User';

        // Save user data
        const newUser = {
            phone: ctx.wizard.state.phone,
            password: ctx.wizard.state.password
        };

        const savedUser = await createUser(newUser);
        
        if (!savedUser) {
            ctx.reply('❌ Registration failed. There was a database error. Please contact support or try again later.', createMainMenu());
            return ctx.scene.leave();
        }

        console.log('✅ User registered:', savedUser.phone);
        ctx.reply(`✅ Registration successful! Welcome ${name}!`, createMainMenu());
        return ctx.scene.leave();
    }
);

// Login Scene
const loginScene = new Scenes.WizardScene('login',
    // Step 1: Ask for phone number
    async (ctx) => {
        ctx.reply('📱 Please enter your phone number:', Markup.removeKeyboard());
        return ctx.wizard.next();
    },
    // Step 2: Store phone and ask for password
    async (ctx) => {
        const phone = ctx.message?.text?.trim();
        
        if (!phone) {
            ctx.reply('❌ Please enter a valid phone number.');
            return;
        }

        ctx.wizard.state.phone = phone;
        ctx.reply('🔒 Please enter your password:');
        return ctx.wizard.next();
    },
    // Step 3: Validate credentials
    async (ctx) => {
        const password = ctx.message?.text?.trim();
        
        if (!password) {
            ctx.reply('❌ Please enter a valid password.');
            return;
        }

        const user = await findUserByPhone(ctx.wizard.state.phone);
        
        if (!user || user.password !== password) {
            ctx.reply('❌ Invalid credentials', createMainMenu());
            return ctx.scene.leave();
        }

        console.log('✅ User logged in:', user.phone);
        ctx.reply(`✅ Login successful! Welcome back!`, createMainMenu());
        return ctx.scene.leave();
    }
);

// Create stage and register scenes
const stage = new Scenes.Stage([registrationScene, loginScene]);

// Session middleware
bot.use(session());
bot.use(stage.middleware());

// Start command
bot.start((ctx) => {
    const welcomeMessage = `
🤖 Welcome to the Registration Bot!

👋 Hello ${ctx.from.first_name}!

Please choose an option from the menu below:
    `;
    
    ctx.reply(welcomeMessage, createInlineMenu());
});

// Handle inline button callbacks
bot.action('register', (ctx) => {
    ctx.answerCbQuery();
    ctx.scene.enter('registration');
});

bot.action('login', (ctx) => {
    ctx.answerCbQuery();
    ctx.scene.enter('login');
});

// Handle keyboard buttons
bot.hears('📝 Register', (ctx) => {
    ctx.scene.enter('registration');
});

bot.hears('🔑 Login', (ctx) => {
    ctx.scene.enter('login');
});

// Handle /menu command to show main menu anytime
bot.command('menu', (ctx) => {
    ctx.reply('📋 Main Menu:', createInlineMenu());
});

// Handle /users command to show registered users (for testing)
bot.command('users', async (ctx) => {
    try {
        const { data: users, error } = await supabase
            .from('users')
            .select('phone, created_at')
            .order('created_at', { ascending: false });
        
        if (error) {
            console.error('Database error:', error);
            ctx.reply('❌ Error fetching users from database.');
            return;
        }
        
        if (!users || users.length === 0) {
        ctx.reply('📭 No users registered yet.');
        return;
    }

    let usersList = '👥 Registered Users:\n\n';
    users.forEach((user, index) => {
            const date = new Date(user.created_at).toLocaleDateString();
            usersList += `${index + 1}. 📱 Phone: ${user.phone}\n📅 Registered: ${date}\n\n`;
    });

    ctx.reply(usersList);
    } catch (err) {
        console.error('Error fetching users:', err);
        ctx.reply('❌ Error fetching users from database.');
    }
});

// Handle unknown commands
bot.on('text', (ctx) => {
    ctx.reply('❓ I don\'t understand that command. Use /start to see the main menu.');
});

// Error handling
bot.catch((err, ctx) => {
    console.error('Bot error:', err);
    ctx.reply('❌ An error occurred. Please try again or contact support.');
});

// Start the bot
console.log('🚀 Starting Telegram Bot...');
bot.launch().then(() => {
    console.log('✅ Bot is running successfully!');
    console.log('📱 Send /start to your bot to begin');
});

// Enable graceful stop
process.once('SIGINT', () => bot.stop('SIGINT'));
process.once('SIGTERM', () => bot.stop('SIGTERM'));