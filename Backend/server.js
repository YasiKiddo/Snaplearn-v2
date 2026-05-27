require('dotenv').config();
const dns = require('dns');
const crypto = require('crypto');
// Force public DNS resolvers to handle SRV querySrv lookup correctly in Node.js on Windows
dns.setServers(['1.1.1.1', '1.0.0.1', '8.8.8.8', '8.8.4.4']);

const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');

// Import Models
const User = require('./models/User');
const Course = require('./models/Course');
const Lesson = require('./models/Lesson');

const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
app.use(cors());
app.use(express.json());

function hashPassword(password, salt = crypto.randomBytes(16).toString('hex')) {
  const hash = crypto.scryptSync(password, salt, 64).toString('hex');
  return `${salt}:${hash}`;
}

function verifyPassword(password, savedHash) {
  if (!savedHash || !savedHash.includes(':')) return false;
  const [salt, hash] = savedHash.split(':');
  const expected = Buffer.from(hash, 'hex');
  const actual = crypto.scryptSync(password, salt, 64);
  return expected.length === actual.length && crypto.timingSafeEqual(expected, actual);
}

function publicUser(user) {
  const data = user.toObject();
  delete data.passwordHash;
  return { ...data, id: data._id.toString() };
}

// MongoDB Connection
const mongodbUri = process.env.MONGODB_URI;

if (!mongodbUri || mongodbUri.includes('<db_password>')) {
  console.warn('WARNING: MongoDB connection URI is not fully configured. Please update MONGODB_URI in the .env file with your actual password.');
}

console.log('Attempting to connect to MongoDB...');
mongoose
  .connect(mongodbUri)
  .then(() => {
    console.log('Connected to MongoDB successfully.');
  })
  .catch((err) => {
    console.error('MongoDB connection error:', err.message);
  });

// Event Listeners for MongoDB Connection States
mongoose.connection.on('disconnected', () => {
  console.log('MongoDB disconnected.');
});

mongoose.connection.on('error', (err) => {
  console.error('MongoDB error during connection:', err);
});

// API Routes
// 1. Health & Connection Status
app.get('/api/health', (req, res) => {
  const dbStatus = mongoose.connection.readyState;
  const statusMap = {
    0: 'Disconnected',
    1: 'Connected',
    2: 'Connecting',
    3: 'Disconnecting',
  };

  res.json({
    status: 'UP',
    serverTime: new Date(),
    database: {
      status: statusMap[dbStatus] || 'Unknown',
      readyState: dbStatus,
    },
  });
});

// 2. Authentication
app.post('/api/auth/register', async (req, res) => {
  try {
    const displayName = String(req.body.displayName || '').trim();
    const email = String(req.body.email || '').trim().toLowerCase();
    const password = String(req.body.password || '');
    const interests = Array.isArray(req.body.interests) ? req.body.interests : [];

    if (!displayName || !email || password.length < 6) {
      return res.status(400).json({
        message: 'Name, email, and a password of at least 6 characters are required.',
      });
    }

    if (await User.exists({ email })) {
      return res.status(409).json({ message: 'An account with this email already exists.' });
    }

    const user = await User.create({
      displayName,
      email,
      passwordHash: hashPassword(password),
      interests,
    });

    return res.status(201).json({ user: publicUser(user) });
  } catch (err) {
    return res.status(500).json({ message: 'Unable to create account.' });
  }
});

app.post('/api/auth/login', async (req, res) => {
  try {
    const email = String(req.body.email || '').trim().toLowerCase();
    const password = String(req.body.password || '');
    const user = await User.findOne({ email }).select('+passwordHash');

    if (!user || !verifyPassword(password, user.passwordHash)) {
      return res.status(401).json({ message: 'Invalid email or password.' });
    }

    if (user.isBlocked || user.isDeleted) {
      return res.status(403).json({ message: 'This account has been deactivated.' });
    }

    return res.json({ user: publicUser(user) });
  } catch (err) {
    return res.status(500).json({ message: 'Unable to sign in.' });
  }
});

// 3. Sample routes to check models functionality
app.get('/api/status', async (req, res) => {
  try {
    const userCount = await User.countDocuments();
    const courseCount = await Course.countDocuments();
    const lessonCount = await Lesson.countDocuments();

    res.json({
      success: true,
      message: 'MongoDB counts retrieved successfully.',
      counts: {
        users: userCount,
        courses: courseCount,
        lessons: lessonCount,
      },
    });
  } catch (err) {
    res.status(500).json({
      success: false,
      message: 'Failed to query database collections.',
      error: err.message,
    });
  }
});

// Start Server
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
  console.log(`Health check available at http://localhost:${PORT}/api/health`);
});
