import Report from '../models/Report.js';
import User from '../models/User.js';
import { sendNotificationToUser } from '../services/notificationService.js';

// Submit a report
export const submitReport = async (req, res) => {
  try {
    const { firebaseUid, reportedContentType, reportedContentId, reason, description } = req.body;

    const user = await User.findOne({ firebaseUid });
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    // Check if user already reported this content
    const existingReport = await Report.findOne({
      reporterId: user._id,
      reportedContentId
    });

    if (existingReport) {
      return res.status(400).json({
        success: false,
        message: 'You have already reported this content'
      });
    }

    const report = await Report.create({
      reporterId: user._id,
      reportedContentType,
      reportedContentId,
      reason,
      description
    });

    res.status(201).json({
      success: true,
      message: 'Report submitted successfully. Our team will review it.',
      data: report
    });
  } catch (error) {
    console.error('Error in submitReport:', error);
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to submit report'
    });
  }
};

// Get all reports (admin)
export const getAllReports = async (req, res) => {
  try {
    const { status, limit = 50, page = 1 } = req.query;

    const query = {};
    if (status) query.status = status;

    const reports = await Report.find(query)
      .populate('reporterId', 'username email profileImage')
      .populate('reviewedBy', 'username email')
      .sort({ createdAt: -1 })
      .limit(parseInt(limit))
      .skip((parseInt(page) - 1) * parseInt(limit));

    const total = await Report.countDocuments(query);

    res.status(200).json({
      success: true,
      count: reports.length,
      total,
      page: parseInt(page),
      pages: Math.ceil(total / parseInt(limit)),
      data: reports
    });
  } catch (error) {
    console.error('Error in getAllReports:', error);
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to get reports'
    });
  }
};

// Verify report (admin/moderator)
export const verifyReport = async (req, res) => {
  try {
    const { id } = req.params;
    const { firebaseUid, isVerified } = req.body;

    const reviewer = await User.findOne({ firebaseUid });
    if (!reviewer) {
      return res.status(404).json({
        success: false,
        message: 'Reviewer not found'
      });
    }

    const report = await Report.findById(id);
    if (!report) {
      return res.status(404).json({
        success: false,
        message: 'Report not found'
      });
    }

    report.status = isVerified ? 'Verified' : 'Rejected';
    report.reviewedBy = reviewer._id;
    report.reviewedAt = Date.now();

    // Award +3 karma points if report is verified and not already awarded
    if (isVerified && !report.karmaAwarded) {
      await User.findByIdAndUpdate(report.reporterId, {
        $inc: { karma: 3 }
      });
      report.karmaAwarded = true;

      // Notify reporter
      const reporter = await User.findById(report.reporterId);
      if (reporter && reporter.firebaseUid) {
        sendNotificationToUser(
          reporter.firebaseUid,
          '✅ Report Verified!',
          'Your report was verified. You earned +3 karma points!',
          {
            type: 'report_verified',
            karmaEarned: 3,
            reportId: report._id.toString()
          }
        ).catch(err => console.error('Notification error:', err));
      }
    }

    await report.save();

    res.status(200).json({
      success: true,
      message: `Report ${isVerified ? 'verified' : 'rejected'} successfully`,
      data: report
    });
  } catch (error) {
    console.error('Error in verifyReport:', error);
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to verify report'
    });
  }
};
