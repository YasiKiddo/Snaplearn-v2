const mongoose = require('mongoose');

const courseSchema = new mongoose.Schema(
  {
    title: {
      type: String,
      required: true,
      trim: true,
    },
    description: {
      type: String,
      required: true,
    },
    instructorId: {
      type: String, // Instructor user identifier
      required: true,
    },
    instructorName: {
      type: String,
      required: true,
      default: 'Unknown Instructor',
    },
    thumbnailUrl: {
      type: String,
      default: '',
    },
    thumbnailPath: {
      type: String,
      default: null,
    },
    category: {
      type: String,
      required: true,
      default: 'General',
    },
    lessonIds: [
      {
        type: String, // Array of lesson IDs
      },
    ],
    enrolledCount: {
      type: Number,
      default: 0,
    },
    rating: {
      type: Number,
      default: 0.0,
    },
    status: {
      type: String,
      default: 'published',
    },
    isFeatured: {
      type: Boolean,
      default: false,
    },
    price: {
      type: Number,
      default: 0.0,
    },
    learningObjectives: [
      {
        type: String,
      },
    ],
    requirements: [
      {
        type: String,
      },
    ],
    isFree: {
      type: Boolean,
      default: false,
    },
  },
  {
    timestamps: true,
  }
);

// Pre-save middleware to set isFree based on price
courseSchema.pre('save', function (next) {
  if (this.price === 0.0) {
    this.isFree = true;
  }
  next();
});

module.exports = mongoose.model('Course', courseSchema);
