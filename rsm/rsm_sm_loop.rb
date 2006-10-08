require 'logreader'
require 'benchmark'

def scan_matching(klass,scan_list,input,output,params)
	include MathUtils
	
	laser_ref = LogReader.shift_laser(input)
	laser_ref.estimate = Vector[0,0,0].col
	output.puts laser_ref.to_carmen
	
	results = []
	count = 0
	until input.eof?
		
		laser_sens = LogReader.shift_laser(input)
		min_step = -0
		min_theta_step_deg = -5;

		u =  pose_diff(laser_sens.odometry, laser_ref.odometry)
		
		if (u[0,1]).nrm2 <= min_step && (u[2].abs <deg2rad(min_theta_step_deg))
			
			# todo: merge readings
			#puts "Skipping (same odometry)"
			next
		end

		puts "Ref: #{pv(laser_ref.odometry)}"
#		puts "New: #{pv(laser_sens.odometry)}"

		if (not scan_list.empty?) && (not scan_list.include? count)
			break if count > scan_list.max
			puts "NEXT!"
			count+=1
			laser_ref = laser_sens;
			next
		end
		
		sm = klass.new
		# Write log of the icp operation
	
		if scan_list.include? count
			sm.journal_open("rsm_sm.#{sm.name}.#{count}.txt")
		end
		
		sm.params = params 
		sm.params[:laser_ref] = laser_ref;
		sm.params[:laser_sens] = laser_sens;
		sm.params[:firstGuess] = u

		#		sm.params[:laser_sens] = laser_ref;
		#		sm.params[:firstGuess] = GSL::Vector.alloc(0.2,0.2,deg2rad(30))
		
		res = nil
		realtime = Benchmark.realtime do
			res = sm.scan_matching
		end
		res[:time] = realtime
		results.push res
		
		x = res[:x]
		error = res[:error]
		iterations = res[:iterations]
		
		puts "rsm_sm.rb: #{count} time=#{realtime} error = #{error} it = #{iterations} x = #{pv(x)} u = #{pv(u)}"
		
		laser_sens.estimate = oplus(laser_ref.estimate,x)
		output.puts laser_sens.to_carmen

		
		laser_ref = laser_sens;
		count += 1
	end
	results
end
