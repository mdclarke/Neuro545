%This script generates a signal (10 sources x 100 timepoints) consisting of
%3 components (cosine waves at different frequencies). 

% Noise can be added to the signal by selecting one of the below:
%      1 = none
%      2 = uncorrelated between signals
%      3 = correlated (r = 1) between signal

noise = 3

% generate a mixed signal (ns signals, each having nt timepoints)
ns = 10;
nt = 100;
mixedsig = zeros(ns,nt);

% add cosine waves to the mixed signal
freqs = [2 4 6]; % frequencies of cosine waves
for i = 1:ns
 ifreq = mod(i-1,3)+1;
 mixedsig(i,:) = cos(2*pi*freqs(ifreq)*linspace(0,1,nt));
end

% add noise to the mixed signal
noise_std = .10*range(mixedsig(:));  % standard deviation of the nose (1% of the peak-to-peak signal range)
if noise == 1  % no noise
 noise_values = zeros(size(mixedsig));
elseif noise == 2  % uncorrelated (between signals) noise
 noise_values = noise_std*randn(size(mixedsig)); 
elseif noise == 3  % correlated (between signals) noise
 noise_values = noise_std*randn(1,nt);
 noise_values = repmat(noise_values,ns,1);
end
 mixedsig = mixedsig + noise_values;

% plot the mixed signal
figure();
subplot(3,1,1)
plot(mixedsig.');
title('input signals');

% compute the ica of the mixed signal 
[icasig,A,W] = fastica(mixedsig);
nc = size(icasig,1);  % number of independent components

% plot the independent components of the mixed signal 
subplot(3,1,2)
plot(icasig.');
title('independent components');

% reconstruct the mixed signal from the independent components and the 
% mixing matrix (A)
% check A has size ns x nc
  if(~all(size(A)==[ns nc]))
     error('sizes do not match');
  end
% A(1,:) tells you the weighting of each component required to make signal 1 `
  reconsig = A*icasig;

% check the reconstructed signal matches the mixed signal
diff = 100*range(reconsig(:)-mixedsig(:))/range(mixedsig(:));  % compute percent difference (of ranges)
if(diff > 1)
  fprintf('\nreconstructed signal DIFFERS FROM mixed signal by %g %%\n\n', diff);
end

% plot the reconstructed signal
subplot(3,1,3)
plot(reconsig.');
title('reconstructed signals');
