% Define a function to generate random numbers within a range
genRandom = @(l, r, n) l + rand(1, n) * (r - l);

% Set parameters
modulation_orders = [2, 4, 8]; % Modulation orders to randomly select from
nsamp = 8;          % Samples per symbol
Fs = 200e3;         % Sample rate (Hz)
num_symbols = 1000; % Number of symbols
num_samples = 3000;   % Number of samples to generate

% Create directories for the dataset
mkdir dataset
mkdir dataset/signal
mkdir dataset/noise

% Loop to generate data samples
for i = 1:num_samples
    isSignal = rand() > 0.4; % Randomly decide whether it's a signal or noise
    if isSignal
        % Randomly select modulation order
        M = modulation_orders(randi([1, length(modulation_orders)]));
        
        % Generate random binary symbols (0 or 1)
        freqsep = genRandom(12.5e3, 25e3, 1); % Ensure freqsep <= Fs / (2 * M)
        SNR_dB = genRandom(-10, 20, 1);
        binary_symbols = randi([0 M-1], num_symbols, 1);

        % Apply FSK modulation
        fsk_modulated_signal = fskmod(binary_symbols, M, freqsep, nsamp, Fs);

        % Add white Gaussian noise
        fsk_modulated_signal_with_noise = awgn(fsk_modulated_signal, SNR_dB, 'measured');

        % Plot the spectrogram
        figure;
        spectrogram(fsk_modulated_signal_with_noise, hann(256), 128, 256, 2*Fs, 'yaxis');
        set(gca, 'Visible', 'off');
        colorbar('off');
        
        % Save the spectrogram with appropriate labels
        filename = sprintf('dataset/signal/signal_%d_M%d_freq%.2fHz_snr%.2fdB.png', i, M, freqsep, SNR_dB);
        saveas(gcf, filename);
        close(gcf); % Close the figure to avoid cluttering
    else
        % Generate spectrogram for only noise
        noise_only = randn(num_symbols * nsamp, 1); % Generate white Gaussian noise
        
        % Plot the spectrogram
        figure;
        spectrogram(noise_only, hann(256), 128, 256, 2*Fs, 'yaxis');
        set(gca, 'Visible', 'off');
        colorbar('off');
        
        % Save the spectrogram with appropriate labels
        filename = sprintf('dataset/noise/noise_%d.png', i);
        saveas(gcf, filename);
        close(gcf); % Close the figure to avoid cluttering
    end
end