function [ dig_ch1, dig_ch2, dig_ch3 ] = ArbGaussianPulseGenerator( PulseSequence, AmplitudeSequence, DragAmp )
%UNTITLED ch1 and ch2 are spec pulses, ch3 is RF pulse
%   Generates gaussian spec and std RF pulses of arbitrary sigma and
%   amplitude. Used by a parent function, which writes each output to a AWG
%   pulse file.
%   PulseSequence should be a 2 element vector. '0' means rotation along X,
%   '1' means rotation along Y.
%   AmplitudeSequence should be a 2 element vector. Each element can take
%   value of '.5' or '1'

%   MARKED FOR DELETION 12/7/12

GaussianSigma = 10e-9;
t_init_wait = 15e-6; %wait time at the start of the pulse
t_end_wait = 15e-6; %wait time at the end of each sequence
sample_rate = 1e9; %tek sampling rate
t_blank_window= 30e-9; %time blanking marker starts/ends before/after pulse
t_trig_marker = 100e-9; %card trigger maker window
t_measure = 4e-6; %measurement pulse window
t_waitb4measure = 10e-9; %time to wait before pulsing measurement after spec
t_waitbwspecpulses = 5e-9; %time to wait between successive qubit rotations

int_t_init_wait = int32(t_init_wait*sample_rate);
int_t_end_wait = int32(t_end_wait*sample_rate);
int_t_blank_window = int32(t_blank_window*sample_rate);
int_t_trig_marker = int32(t_trig_marker*sample_rate);
int_t_measure = int32(t_measure*sample_rate);
int_t_waitb4measure = int32(t_waitb4measure*sample_rate);
int_t_waitbwspecpulses = int32(t_waitbwspecpulses*sample_rate);

% cavity measurement pulse
measure_domain = linspace(0,t_measure,int_t_measure);
half_point = int32(length(measure_domain)/2);
measure_pulse(1:half_point) = atan(1e8*measure_domain(1:half_point));
measure_pulse(half_point+1:length(measure_domain)) = fliplr(measure_pulse(1:half_point));

% Gaussian defined over 4 sigma, as in Jerry paper
int_GaussianSigma = int32(GaussianSigma*sample_rate);
QubitPulseDomain = linspace(-3*GaussianSigma,3*GaussianSigma,6*int_GaussianSigma);

pulse_ch3 = [zeros(1,int_t_init_wait + 12*int_GaussianSigma + int_t_waitbwspecpulses) measure_pulse];
mylength = length(pulse_ch3);
pulse_ch3 = [pulse_ch3 zeros(1,int_t_end_wait)];
dig_ch3 = floor(pulse_ch3*1023/max(pulse_ch3));

%ch3 marker
dig_ch3(mylength-length(measure_pulse)-int_t_blank_window:mylength+int_t_blank_window) = dig_ch3(mylength-length(measure_pulse)-int_t_blank_window:mylength+int_t_blank_window)+2048;

% First rotation in the sequence
QubitPulseVector = AmplitudeSequence(1)*exp(-(QubitPulseDomain.^2/(2*GaussianSigma^2)));
if PulseSequence(1) == 0,
    % X Rotation
    % Quadrature drive is in Ch1, Drag drive is in Ch2
    pulse_ch1 = [zeros(1,int_t_init_wait-6*int_GaussianSigma-int_t_waitb4measure) QubitPulseVector];
    pulse_ch2 = DragAmp*[0 diff(pulse_ch1)];

    % Assuming only pi and pi/2 pulses are generated from this file
    if AmplitudeSequence(1) == 1
        dig_ch1 = floor(pulse_ch1*511/(max(pulse_ch1)))+512;
        dig_ch2 = floor(pulse_ch2*511/(max(pulse_ch1)))+512;
    elseif AmplitudeSequence(1) == -1
        dig_ch1 = floor(pulse_ch1*511/abs(min(pulse_ch1))) + 512;
        dig_ch2 = floor(pulse_ch2*511/(max(pulse_ch1)))+512;
    elseif AmplitudeSequence(1) == .5
        dig_ch1 = floor(pulse_ch1*511/(2*max(pulse_ch1)))+512;
        dig_ch2 = floor(pulse_ch2*511/(max(pulse_ch1)))+512;
    elseif AmplitudeSequence(1) == -.5
        dig_ch1 = floor(pulse_ch1*511/abs(2*min(pulse_ch1)))+512;
        dig_ch2 = floor(pulse_ch2*511/(max(pulse_ch1)))+512;
    else
        dig_ch1 = zeros(1,length(pulse_ch1)) + 512;
        dig_ch2 = zeros(1,length(pulse_ch1)) + 512;
    end
else
    % Y Rotation
    % Quadrature drive is in Ch2, Drag drive is in Ch1
    pulse_ch2 = [zeros(1,int_t_init_wait-6*int_GaussianSigma-int_t_waitb4measure) QubitPulseVector];
    pulse_ch1 = DragAmp*[0 diff(pulse_ch2)];

    if AmplitudeSequence(1) == 1
        dig_ch2 = floor(pulse_ch2*511/(max(pulse_ch2)))+512;
        dig_ch1 = floor(pulse_ch1*511/(max(pulse_ch2)))+512;
    elseif AmplitudeSequence(1) == -1
        dig_ch2 = floor(pulse_ch2*511/abs(min(pulse_ch2)))+512;
        dig_ch1 = floor(pulse_ch1*511/(max(pulse_ch2)))+512;
    elseif AmplitudeSequence(1) == .5
        dig_ch2 = floor(pulse_ch2*511/(2*max(pulse_ch2)))+512;
        dig_ch1 = floor(pulse_ch1*511/(max(pulse_ch2)))+512;
    elseif AmplitudeSequence(1) == -.5
        dig_ch2 = floor(pulse_ch2*511/abs(2*min(pulse_ch2)))+512;
        dig_ch1 = floor(pulse_ch1*511/(max(pulse_ch2)))+512;
    else
        dig_ch2 = zeros(1,length(pulse_ch2)) + 512;
        dig_ch1 = zeros(1,length(pulse_ch2)) + 512;
    end
end

% Second rotation in the sequence
QubitPulseVector = AmplitudeSequence(2)*exp(-(QubitPulseDomain.^2/(2*GaussianSigma^2)));
if PulseSequence(2) == 0,
    % X Rotation
    % Quadrature drive is in Ch1, Drag drive is in Ch2
    temp_pulse_ch1 = [zeros(1,int_t_waitbwspecpulses) QubitPulseVector];
    temp_pulse_ch2 = DragAmp*[0 diff(temp_pulse_ch1)];

    if AmplitudeSequence(2) == 1,
        temp_dig_ch1 = floor(temp_pulse_ch1*511/(max(temp_pulse_ch1)))+512;
    elseif AmplitudeSequence(2) == -1,
        temp_dig_ch1 = floor(temp_pulse_ch1*511/abs(min(temp_pulse_ch1)))+512;
    elseif AmplitudeSequence(2) == .5
        temp_dig_ch1 = floor(temp_pulse_ch1*511/(2*max(temp_pulse_ch1)))+512;
    elseif AmplitudeSequence(2) == -.5
        temp_dig_ch1 = floor(temp_pulse_ch1*511/abs(2*min(temp_pulse_ch1)))+512;
    else
        temp_dig_ch1 = zeros(1,length(temp_pulse_ch1))+512;
    end
    temp_dig_ch2 = floor(temp_pulse_ch2*511/max(temp_pulse_ch1)) + 512;
else
    % Y Rotation
    % Quadrature drive is in Ch2, Drag drive is in Ch1
    temp_pulse_ch2 = [zeros(1,int_t_waitbwspecpulses) QubitPulseVector];
    temp_pulse_ch1 = DragAmp*[0 diff(temp_pulse_ch2)];

    if AmplitudeSequence(2) == 1,
        temp_dig_ch2 = floor(temp_pulse_ch2*511/(max(temp_pulse_ch2)))+512;
    elseif AmplitudeSequence(2) == -1,
        temp_dig_ch2 = floor(temp_pulse_ch2*511/abs(min(temp_pulse_ch2)))+512;
    elseif AmplitudeSequence(2) == .5
        temp_dig_ch2 = floor(temp_pulse_ch2*511/(2*max(temp_pulse_ch2)))+512;
    elseif AmplitudeSequence(2) == -.5
        temp_dig_ch2 = floor(temp_pulse_ch2*511/abs(2*min(temp_pulse_ch2)))+512;
    else
        temp_dig_ch2 = zeros(1,length(temp_pulse_ch2))+512;
    end
    temp_dig_ch1 = floor(temp_pulse_ch1*511/max(temp_pulse_ch2)) + 512;
end

dig_ch1 = [dig_ch1 temp_dig_ch1];
dig_ch2 = [dig_ch2 temp_dig_ch2];
BeginSpecMarker = int_t_init_wait - 6*int_GaussianSigma - int_t_waitbwspecpulses - int_t_waitb4measure - int_t_blank_window;
EndSpecMarker = length(dig_ch1) + int_t_blank_window;
diff_length = length(dig_ch3)-length(dig_ch1);
dig_ch1 = [dig_ch1 (zeros(1,diff_length)+512)];
dig_ch2 = [dig_ch2 (zeros(1,diff_length)+512)];


% card trigger
dig_ch1(int_t_trig_marker:2*int_t_trig_marker) = dig_ch1(int_t_trig_marker:2*int_t_trig_marker) + 1024;
dig_ch1(BeginSpecMarker:EndSpecMarker) = dig_ch1(BeginSpecMarker:EndSpecMarker) + 2048;

% blanking pulses
% for counter2 = 1:length(dig_ch1)
%     if dig_ch1(counter2)>512 && dig_ch1(counter2)<1024, % true when dig_ch1 contains QubitPulse. && statement is required to distinguish from previously assigned marker pules, such as 1024 and 2048
%         if dig_ch1(counter2-1)==512 % true when dig_ch1(counter2) is the beginning of the QubitPulse
%             dig_ch1(counter2-int_t_blank_window:counter2) = dig_ch1(counter2-int_t_blank_window:counter2) + 2048;
%         elseif dig_ch1(counter2+1)==512 % true when dig_ch1(counter2) is the end of the QubitPulse
%             dig_ch1(counter2:counter2+int_t_blank_window) = dig_ch1(counter2:counter2+int_t_blank_window) + 2048;
%         else % true when dig_ch1(counter2) is the middle of the QubitPulse
%             dig_ch1(counter2) = dig_ch1(counter2) + 2048;
%         end
%     end
% 
%     if dig_ch3(counter2)>0 && dig_ch3(counter2)<1024, % true when dig_ch3 contains measure_pulse
%         if dig_ch3(counter2-1)==0 % true when dig_ch3(counter2) is the beginning of the measure_pulse
%             dig_ch3(counter2-int_t_blank_window:counter2) = dig_ch3(counter2-int_t_blank_window:counter2) + 2048;
%         elseif dig_ch3(counter2+1)==0 % true when dig_ch3(counter2) is the end of the measure_pulse
%             dig_ch3(counter2:counter2+int_t_blank_window) = dig_ch3(counter2:counter2+int_t_blank_window) + 2048;
%         else % true when dig_ch3(counter2) is the middle of the measure_pulse
%             dig_ch3(counter2) = dig_ch3(counter2) + 2048;
%         end
%     end
% end

end

