import express from 'express';
import { upload } from '../config/cloudinary.js';
import {
  uploadSingleImage,
  uploadMultipleImages,
} from '../controllers/uploadController.js';

const router = express.Router();

// POST /api/upload/single - Upload single image
router.post('/single', upload.single('image'), uploadSingleImage);

// POST /api/upload/multiple - Upload multiple images (max 5)
router.post('/multiple', upload.array('images', 5), uploadMultipleImages);

export default router;
