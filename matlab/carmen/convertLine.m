function laserData = convertLine(lineCells)
	if 0==strcmp(lineCells(1),'FLASER')
		error('Not a FLASER line');
	end
	
	laserData.nrays      = str2double( lineCells(2) );
	laserData.readings   = str2double( lineCells(3:3+laserData.nrays-1) );
	laserData.odometry   = str2double( lineCells(laserData.nrays+2+1: laserData.nrays+2+3));
	laserData.estimate   = str2double( lineCells(laserData.nrays+2+4: laserData.nrays+2+6));
	laserData.timestamp1 = lineCells(laserData.nrays+2+7);
	laserData.hostname   = lineCells(laserData.nrays+2+8);
	laserData.timestamp2 = lineCells(laserData.nrays+2+9);
	
	% Theta array
	for i=1:laserData.nrays
		% Maybe this is not so precise
		laserData.theta(i) = (i - laserData.nrays/2) * pi / laserData.nrays;
	end
	
	% Cartesian points corrisponding to readings
	for i=1:laserData.nrays
		theta = laserData.theta(i);
		rho   = laserData.readings(i);
		laserData.points(:,i) =  [cos(theta); sin(theta)] * rho;
	end
	
%	laserData = computeSurfaceNormals(laserData, 0.3);

	% compute normalized errors (0-1) for regression
	%valids = find(laserData.alpha_valid);
	%errors = laserData.alpha_error(valids);
	%emin = min(errors);
	%emax = max(errors);
	
	%laserData.alpha_weight = zeros(1, laserData.nrays)
	%for i=valids
	%	w = (1-(laserData.alpha_error(i)-emin)/(emax-emin));
	%	laserData.alpha_weight(i) = w;
	%end
	
