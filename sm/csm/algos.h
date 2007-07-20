#ifndef H_SCAN_MATCHING_LIB
#define H_SCAN_MATCHING_LIB

#include "laser_data.h"

#include <gsl/gsl_vector.h>
#include <gsl/gsl_matrix.h>

struct sm_params {
	/** First scan (/ref/erence scan) */
	LDP laser_ref;
	/** Second scan */
	LDP laser_sens;

	/** Where to start */
 	double first_guess[3]; 

	/** Maximum angular displacement between scans (deg)*/
	double max_angular_correction_deg;
	/** Maximum translation between scans (m) */
	double max_linear_correction;

	/** When to stop */
	int max_iterations;
	/** A threshold for stopping. */
	double epsilon_xy;
	/** A threshold for stopping. */
	double epsilon_theta;
	
	/** dubious parameter */
	double max_correspondence_dist;
	
	/** Noise in the scan */
	double sigma;
	
	/** Use smart tricks for finding correspondences. */
	int use_corr_tricks;
	
	/** Restart if error under threshold */
	int restart;
		/** Threshold for restarting */
		double restart_threshold_mean_error;
		/** Displacement for restarting */
		double restart_dt;
		/** Displacement for restarting */
		double restart_dtheta;
	

	/** For now, a very simple max-distance clustering algorithm is used */
	double clustering_threshold;
	/** Number of neighbour rays used to estimate the orientation.*/
	int orientation_neighbourhood;

	/** Discard correspondences based on the angles */
	int do_alpha_test;
	double do_alpha_test_thresholdDeg;

	/** Percentage of correspondences to consider */
	double outliers_maxPerc;

	double outliers_adaptive_order; /* 0.7 */
	double outliers_adaptive_mult; /* 2 */

	int do_visibility_test;

	int use_point_to_line_distance;
	int do_compute_covariance;

	/** Checks that find_correspondences_tricks give the right answer */
	int debug_verify_tricks;
	
	double gpm_theta_bin_size_deg;
	double gpm_extend_range_deg; 
	int gpm_interval;

	/** Pose of sensor with respect to robot */
	double laser[3]; 

	/** mark as invalid ( = don't use ) rays outside of this interval */
	double min_reading, max_reading;
	
};

struct sm_result {
	int valid;
	
	double x[3];
	
	int iterations;
	int nvalid;
	double error;
	
	#ifndef RUBY
		gsl_matrix *cov_x_m;	
		gsl_matrix *dx_dy1_m;
		gsl_matrix *dx_dy2_m;
	#endif
};


void sm_icp(struct sm_params*input, struct sm_result*output);
void sm_gpm(struct sm_params*input, struct sm_result*output);

void sm_journal_open(const char* file);

#endif
