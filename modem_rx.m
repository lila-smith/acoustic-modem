
load long_modem_rx.mat

% The received signal includes a bunch of samples from before the
% transmission started so we need discard these samples that occurred 
% before the transmission started. 

start_idx = find_start_of_signal(y_r,x_sync);
% start_idx now contains the location in y_r where x_sync begins
% we need to offset by the length of x_sync to only include the signal
% we are interested in
y_t = y_r(start_idx+length(x_sync):end); % y_t is the signal which starts 
                                    % at the beginning of the transmission

% Multiply with the same cosine function to recenter original function
% We multiply because we want to convolve in the frequency domain
t = 0:(1/Fs):(length(y_t)-1)/Fs;
c = cos(2*pi*f_c*t);
y_c = c .* y_t';

% Use a lowpass filter to filter high frequencies created with cosine
% We convolve because we want to multiply in frequency domain
W = f_c/Fs;
h_lowpass = (W/pi)*sinc(W/pi*t);
y_l = conv(y_c, h_lowpass);

% Find average highs and lows per symbol period for message length
x_d = zeros([msg_length*8, 1]);
for i=1:length(x_d)
    average = mean(y_c((i-1)*100+1:i*100));
    x_d(i) = average > 0; % Write a 1 if co
end


% convert to a string assuming that x_d is a vector of 1s and 0s
% representing the decoded bits
BitsToString(x_d)

