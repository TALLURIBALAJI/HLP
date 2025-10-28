import express from 'express';
import * as donationController from '../controllers/donationController.js';

const router = express.Router();

// Create donation
router.post('/', donationController.createDonation);

// Get all donations
router.get('/', donationController.getAllDonations);

// Claim donation
router.post('/:id/claim', donationController.claimDonation);

// Complete donation
router.put('/:id/complete', donationController.completeDonation);

export default router;
