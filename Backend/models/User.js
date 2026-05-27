const mongoose = require('mongoose');

const userSchema = new mongoose.Schema(
  {
    displayName: {
      type: String,
      required: true,
      trim: true,
    },
    email: {
      type: String,
      required: true,
      unique: true,
      trim: true,
      lowercase: true,
    },
    passwordHash: {
      type: String,
      required: true,
      select: false,
    },
    profileImageUrl: {
      type: String,
      default: null,
    },
    role: {
      type: String,
      enum: ['student', 'instructor', 'admin'],
      default: 'student',
    },
    // Student Specific Fields
    enrolledCourseIds: [
      {
        type: String, // Course identifier
      },
    ],
    completedLessonIds: [
      {
        type: String,
      },
    ],
    interests: [
      {
        type: String,
      },
    ],
    followingIds: [
      {
        type: String, // Instructor user IDs
      },
    ],
    savedLessonIds: [
      {
        type: String,
      },
    ],
    likedLessonIds: [
      {
        type: String,
      },
    ],
    // Admin/Moderation Fields
    isBlocked: {
      type: Boolean,
      default: false,
    },
    isDeleted: {
      type: Boolean,
      default: false,
    },
    isVerified: {
      type: Boolean,
      default: false,
    },
    subscriptionType: {
      type: String,
      default: 'free',
    },
    // Instructor Specific Fields
    instructorApplicationStatus: {
      type: String,
      enum: ['none', 'pending', 'approved', 'rejected'],
      default: 'none',
    },
    totalEarnings: {
      type: Number,
      default: 0.0,
    },
    streakCount: {
      type: Number,
      default: 0,
    },
    lastLoginDate: {
      type: Date,
      default: null,
    },
    bio: {
      type: String,
      default: null,
    },
    experience: {
      type: String,
      default: null,
    },
    skills: [
      {
        type: String,
      },
    ],
  },
  {
    timestamps: true, // Automatically adds createdAt and updatedAt
  }
);

module.exports = mongoose.model('User', userSchema);
