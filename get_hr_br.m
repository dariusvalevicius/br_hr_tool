function [hr_hz, hr_bpm, br_hz, br_bpm] = get_hr_br(physlogfile, varargin)
%% Parse inputs
p = inputParser;
addRequired(p, 'physlogfile', @isfile);
addOptional(p, 'sampling_rate', 500);
parse(p, physlogfile, varargin{:});
physlogfile = p.Results.physlogfile;
sampling_rate = p.Results.sampling_rate;

%% Load physlogfile

% Load physiological logfile and get relevant data
logfile = read_physio_orig(physlogfile);

phys_data = table(logfile.ppu, logfile.resp, logfile.mark, ...
    'VariableNames', {'ppu', 'resp', 'mark'});

%% Subset data to mark start and mark end

% Get end marker and find start marker from scanning parameters
% No start marker in the logfile apparently. This is the same procedure as
% new_analyse_resp_HR_ketamine.m

mark_end = max(int64(find(phys_data.mark == 20)));
disp(mark_end);
mark_start = int64(mark_end - (190*2.2*500));
disp(mark_start);

phys_data_subset = phys_data(mark_start:mark_end,:);

%%

resp_wave = phys_data_subset.resp;

br_hz = get_max_freq(resp_wave, sampling_rate);
br_bpm = br_hz * 60;
%disp(resp_max);
%%
cardiac_wave = phys_data_subset.ppu;

hr_hz = get_max_freq(cardiac_wave, sampling_rate);
hr_bpm = hr_hz * 60;
%disp(cardiac_max);


end


function [max_freq] = get_max_freq(waveform, sampling_rate)

% Gets the highest-powered frequency of the fourrier transform.
% Frequency, amplitudue, and sampling rate are halved to avoid
% spikes at high frequencies (peaks at ~sampling rate Hz).

spectral_amplitude = fft(waveform);
spectral_amplitude = spectral_amplitude(1:round(0.5*length(spectral_amplitude)));

frequency = (0:length(spectral_amplitude)-1)*(0.5*sampling_rate)/length(spectral_amplitude);

%plot(frequency, abs(spectral_amplitude));

[~, i] = max(spectral_amplitude);
max_freq = frequency(i);
%disp(dominant_freq);
end