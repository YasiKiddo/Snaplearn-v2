require('dotenv').config();
const mongoose = require('mongoose');
const crypto = require('crypto');
const User = require('./models/User');

function hashPassword(password, salt = crypto.randomBytes(16).toString('hex')) {
  const hash = crypto.scryptSync(password, salt, 64).toString('hex');
  return `${salt}:${hash}`;
}

async function createAdmin() {
  const mongodbUri = process.env.MONGODB_URI;
  if (!mongodbUri) {
    console.error('No MONGODB_URI found in .env');
    process.exit(1);
  }

  try {
    await mongoose.connect(mongodbUri);
    console.log('Connected to MongoDB.');

    const email = 'admin@gmail.com';
    const existingUser = await User.findOne({ email });
    
    if (existingUser) {
      existingUser.role = 'admin';
      existingUser.passwordHash = hashPassword('1234567');
      existingUser.displayName = 'Admin';
      await existingUser.save();
      console.log('Existing user updated to Admin successfully!');
    } else {
      await User.create({
        displayName: 'Admin',
        email: email,
        passwordHash: hashPassword('1234567'),
        role: 'admin'
      });
      console.log('New Admin user created successfully!');
    }
  } catch (err) {
    console.error('Error creating admin:', err);
  } finally {
    mongoose.disconnect();
    process.exit(0);
  }
}

createAdmin();
