% EXPLORE_EDF - Script to explore the contents of an EDF file
% This script uses EDF reading functions to display information about the file
% and allows viewing signal data.

clear;
clc;

% Ask user to select an EDF file
[file, path] = uigetfile('*.edf', 'Select an EDF file');
if isequal(file, 0)
    disp('No file selected');
    return;
end

full_path = fullfile(path, file);
disp(['Selected file: ', full_path]);

% Add PUP code directory to path if needed
if ~exist('readedfrev3', 'file') && ~exist('blockEdfLoad', 'file')
    % Try to find and add the EDFread directory to path
    current_dir = pwd;
    
    % Check if we're in the PUP workspace
    if exist('PUPbeta', 'dir')
        addpath(genpath('PUPbeta/EDFread'));
        disp('Added PUPbeta/EDFread to path');
    else
        warning('EDF reading functions not found. Loading basic functionality only.');
    end
end

% Try to load the EDF header
disp('Reading EDF header...');
try
    % First try blockEdfLoad if available (from PUP toolkit)
    if exist('blockEdfLoad', 'file')
        [header, signalHeader] = blockEdfLoad(full_path);
        
        % Display basic information
        disp('File Header Information:');
        
        % Safely display field values if they exist
        if isfield(header, 'patient_id')
            disp(['Patient ID: ', header.patient_id]);
        end
        
        % Try various possible field names for recording ID
        if isfield(header, 'recordingID')
            disp(['Recording ID: ', header.recordingID]);
        elseif isfield(header, 'recording_id')
            disp(['Recording ID: ', header.recording_id]);
        elseif isfield(header, 'local_recording_id')
            disp(['Recording ID: ', header.local_recording_id]);
        end
        
        % Try various possible field names for dates
        if isfield(header, 'startDate')
            disp(['Start Date: ', header.startDate]);
        elseif isfield(header, 'start_date')
            disp(['Start Date: ', header.start_date]);
        end
        
        if isfield(header, 'startTime')
            disp(['Start Time: ', header.startTime]);
        elseif isfield(header, 'start_time')
            disp(['Start Time: ', header.start_time]);
        end
        
        if isfield(header, 'numRecords')
            disp(['Number of Records: ', num2str(header.numRecords)]);
        elseif isfield(header, 'num_records')
            disp(['Number of Records: ', num2str(header.num_records)]);
        end
        
        if isfield(header, 'recordDuration')
            disp(['Duration of Records: ', num2str(header.recordDuration), ' seconds']);
        elseif isfield(header, 'data_record_duration')
            disp(['Duration of Records: ', num2str(header.data_record_duration), ' seconds']);
        elseif isfield(header, 'record_duration')
            disp(['Duration of Records: ', num2str(header.record_duration), ' seconds']);
        end
        
        if isfield(header, 'numSignals')
            disp(['Number of Signals: ', num2str(header.numSignals)]);
        elseif isfield(header, 'num_signals')
            disp(['Number of Signals: ', num2str(header.num_signals)]);
        end
        
        % Display all available header fields for debugging
        disp(' ');
        disp('All header fields:');
        disp(fieldnames(header));
        
        % Display channel information
        signalHeader = struct2table(signalHeader);
        disp(' ');
        disp('Signal Information:');
        disp(signalHeader(:, {'signal_labels', 'samples_in_record', 'physical_min', 'physical_max', 'prefiltering'}));
        
        % Store channel names and sampling rates
        channel_names = signalHeader.signal_labels;
        
        % Handle different field names for record duration
        if isfield(header, 'recordDuration')
            record_duration = header.recordDuration;
        elseif isfield(header, 'data_record_duration')
            record_duration = header.data_record_duration;
        elseif isfield(header, 'record_duration')
            record_duration = header.record_duration;
        else
            record_duration = 1; % Default to 1 second if not found
            warning('Record duration not found, assuming 1 second records');
        end
        
        channel_fs = signalHeader.samples_in_record / record_duration;
        
    elseif exist('readedfrev3', 'file')
        % Try using the alternative EDF reader from PUP toolkit
        % First get the number of channels
        [temp, ~, ~, ~, ~, ~, ~, ~, num_chans, ~] = readedfrev3(full_path, 0, 0, 1);
        
        disp(['Number of Channels: ', num2str(num_chans)]);
        
        % Initialize arrays
        channel_names = cell(num_chans, 1);
        channel_fs = zeros(num_chans, 1);
        channel_dimensions = cell(num_chans, 1);
        channel_filters = cell(num_chans, 1);
        
        % Read metadata for each channel
        for i = 0:num_chans-1
            [~, fs, ~, ~, label, dimension, filt, ~, ~, ~] = readedfrev3(full_path, i, 0, 1);
            channel_names{i+1} = label;
            channel_fs(i+1) = fs;
            channel_dimensions{i+1} = dimension;
            channel_filters{i+1} = filt;
        end
        
        % Display all channel information after collecting it
        disp(' ');
        disp('Channel Information:');
        for i = 0:num_chans-1
            disp(['Channel ', num2str(i), ': ', channel_names{i+1}, ' (', num2str(channel_fs(i+1)), ' Hz) [', channel_dimensions{i+1}, '] Filter: ', channel_filters{i+1}]);
        end
    else
        % Try using MATLAB's edfread if available (R2022a or newer)
        if exist('edfread', 'file')
            [hdr, ~] = edfread(full_path);
            disp('File Header Information:');
            disp(hdr);
            
            % Extract channel names from header
            channel_names = hdr.Labels;
            % Estimate sampling rates (might not be accurate)
            channel_fs = hdr.NumSamples ./ hdr.Duration;
        else
            error('No EDF reading function available');
        end
    end
    
    % ============== NEW SECTION: PUP CHANNEL MAPPING ==============
    disp(' ');
    disp('=== PUP CHANNEL MAPPING ===');
    disp('Searching for required PUP analysis channels...');
    disp(' ');
    
    % Define the target signals for PUP analysis
    target_signals = {'Pnasal', 'Thorax', 'Abdomen', 'SpO2', 'EEG1', 'EEG2', 'EEG3', 'EEG4', ...
                     'EEG5', 'EEG6', 'EEG7', 'EEG8', 'EEG9', 'EEG10', 'EEG11', 'EEG12', ...
                     'Position', 'Pmask', 'EKG', 'EKG2', 'LOC', 'ROC'};
    
    % Define search patterns for each target signal
    search_patterns = {
        'Pnasal',   {'flow', 'pnasal', 'nasal', 'patient flow', 'airflow', 'cannula'};
        'Thorax',   {'thorax', 'thor', 'chest', 'rib', 'thoracic'};
        'Abdomen',  {'abdomen', 'abdo', 'abdominal', 'belly', 'abd'};
        'SpO2',     {'spo2', 'sat', 'oxygen saturation', 'pulse ox', 'oximetry'};
        'EEG1',     {'eeg1', 'c3-m2', 'c3m2', 'c3'};
        'EEG2',     {'eeg2', 'c4-m1', 'c4m1', 'c4'};
        'EEG3',     {'eeg3', 'f3-m2', 'f3m2', 'f3'};
        'EEG4',     {'eeg4', 'f4-m1', 'f4m1', 'f4'};
        'EEG5',     {'eeg5', 'o1-m2', 'o1m2', 'o1'};
        'EEG6',     {'eeg6', 'o2-m1', 'o2m1', 'o2'};
        'EEG7',     {'eeg7', 'p3', 'parietal'};
        'EEG8',     {'eeg8', 'p4', 'parietal'};
        'EEG9',     {'eeg9', 't3', 'temporal'};
        'EEG10',    {'eeg10', 't4', 'temporal'};
        'EEG11',    {'eeg11', 'fz', 'frontal'};
        'EEG12',    {'eeg12', 'cz', 'central'};
        'Position', {'position', 'pos', 'positionsensor', 'positionsens', 'body position'};
        'Pmask',    {'pmask', 'mask pressure', 'cpap', 'pressure', 'paw'};
        'EKG',      {'ekg', 'ecg', 'ecg1-ecg2', 'heart', 'cardiac'};
        'EKG2',     {'ekg2', 'ecg2', 'cardiac2', 'heart2'};
        'LOC',      {'loc', 'e1-m2', 'e1m2', 'e1', 'left eog', 'eog1', 'left eye'};
        'ROC',      {'roc', 'e2-m2', 'e2m2', 'e2', 'right eog', 'eog2', 'right eye'}
    };
    
    % Initialize results
    found_channels = struct();
    used_channels = zeros(1, length(target_signals)); % Preallocate for performance
    used_channels_count = 0; % Track how many channels have been assigned
    
    % Search for each target signal
    for i = 1:size(search_patterns, 1)
        target = search_patterns{i, 1};
        patterns = search_patterns{i, 2};
        found_idx = [];
        best_match_score = 0;
        
        % Search through all channel names
        for ch = 1:length(channel_names)
            % Skip if this channel is already used
            if ismember(ch, used_channels(1:used_channels_count))
                continue;
            end
            
            channel_name_lower = lower(strtrim(channel_names{ch}));
            
            % Check each pattern for exact or best match
            for p = 1:length(patterns)
                pattern_lower = lower(patterns{p});
                
                % Calculate match score (exact match gets highest score)
                if strcmp(channel_name_lower, pattern_lower)
                    match_score = 100; % Exact match
                elseif startsWith(channel_name_lower, pattern_lower)
                    match_score = 80; % Starts with pattern
                elseif contains(channel_name_lower, pattern_lower)
                    match_score = 60; % Contains pattern
                else
                    match_score = 0; % No match
                end
                
                % Keep the best match for this target
                if match_score > best_match_score
                    best_match_score = match_score;
                    found_idx = ch;
                end
            end
        end
        
        % Store result and mark channel as used
        if ~isempty(found_idx) && best_match_score > 0
            found_channels.(target) = found_idx;
            used_channels_count = used_channels_count + 1;
            used_channels(used_channels_count) = found_idx;
            disp(['✓ ', target, ': Channel ', num2str(found_idx), ' (', strtrim(channel_names{found_idx}), ')']);
        else
            found_channels.(target) = NaN;
            disp(['✗ ', target, ': Not found']);
        end
    end
    
    % Display summary for AMasterSpreadsheet mapping
    disp(' ');
    disp('=== AMasterSpreadsheet COLUMN MAPPING ===');
    disp('Copy these values to your AMasterSpreadsheet.xlsx:');
    disp(' ');
    
    % Define the column mapping
    columns = {'AJ', 'AK', 'AL', 'AM', 'AN', 'AO', 'AP', 'AQ', 'AR', 'AS', 'AT', 'AU', 'AV', 'AW', 'AX', 'AY', 'AZ', 'BA', 'BB', 'BC', 'BD', 'BE'};
    
    for i = 1:length(target_signals)
        if i <= length(columns)
            target = target_signals{i};
            if isfield(found_channels, target) && ~isnan(found_channels.(target))
                disp(['Column ', columns{i}, ' (', target, '): ', num2str(found_channels.(target))]);
            else
                disp(['Column ', columns{i}, ' (', target, '): 0 (not found)']);
            end
        end
    end
    
    % Generate MATLAB command for easy copying
    disp(' ');
    disp('=== MATLAB VARIABLE FOR EASY ACCESS ===');
    disp('channel_mapping = [');
    for i = 1:length(target_signals)
        target = target_signals{i};
        if isfield(found_channels, target) && ~isnan(found_channels.(target))
            value = found_channels.(target);
        else
            value = 0;
        end
        if i < length(target_signals)
            disp(['    ', num2str(value), '; % ', target]);
        else
            disp(['    ', num2str(value), ']; % ', target]);
        end
    end
    disp(' ');
    
    % ============== END NEW SECTION ==============
    
    % ============== SAVE ANALYSIS TO FILE ==============
    disp(' ');
    disp('=== SAVING ANALYSIS TO FILE ===');
    
    % Generate output filename based on EDF filename
    [~, edf_name, ~] = fileparts(file);
    output_filename = [edf_name, '_analysis.txt'];
    
    try
        % Open file for writing
        fid = fopen(output_filename, 'w');
        if fid == -1
            error('Could not create output file');
        end
        
        % Write header information
        fprintf(fid, 'EDF ANALYSIS REPORT\n');
        fprintf(fid, '==================\n\n');
        fprintf(fid, 'File: %s\n', full_path);
        fprintf(fid, 'Analysis Date: %s\n\n', datestr(now));
        
        % Write basic file information
        fprintf(fid, 'FILE HEADER INFORMATION:\n');
        fprintf(fid, '------------------------\n');
        
        if exist('header', 'var')
            % Write header fields if available
            if isfield(header, 'patient_id')
                fprintf(fid, 'Patient ID: %s\n', header.patient_id);
            end
            
            if isfield(header, 'recordingID')
                fprintf(fid, 'Recording ID: %s\n', header.recordingID);
            elseif isfield(header, 'recording_id')
                fprintf(fid, 'Recording ID: %s\n', header.recording_id);
            elseif isfield(header, 'local_recording_id')
                fprintf(fid, 'Recording ID: %s\n', header.local_recording_id);
            end
            
            if isfield(header, 'startDate')
                fprintf(fid, 'Start Date: %s\n', header.startDate);
            elseif isfield(header, 'start_date')
                fprintf(fid, 'Start Date: %s\n', header.start_date);
            end
            
            if isfield(header, 'startTime')
                fprintf(fid, 'Start Time: %s\n', header.startTime);
            elseif isfield(header, 'start_time')
                fprintf(fid, 'Start Time: %s\n', header.start_time);
            end
            
            if isfield(header, 'numRecords')
                fprintf(fid, 'Number of Records: %d\n', header.numRecords);
            elseif isfield(header, 'num_records')
                fprintf(fid, 'Number of Records: %d\n', header.num_records);
            end
            
            if isfield(header, 'recordDuration')
                fprintf(fid, 'Duration of Records: %.2f seconds\n', header.recordDuration);
            elseif isfield(header, 'data_record_duration')
                fprintf(fid, 'Duration of Records: %.2f seconds\n', header.data_record_duration);
            elseif isfield(header, 'record_duration')
                fprintf(fid, 'Duration of Records: %.2f seconds\n', header.record_duration);
            end
            
            if isfield(header, 'numSignals')
                fprintf(fid, 'Number of Signals: %d\n', header.numSignals);
            elseif isfield(header, 'num_signals')
                fprintf(fid, 'Number of Signals: %d\n', header.num_signals);
            end
        elseif exist('num_chans', 'var')
            fprintf(fid, 'Number of Channels: %d\n', num_chans);
        end
        
        % Write channel information
        fprintf(fid, '\nCHANNEL INFORMATION:\n');
        fprintf(fid, '-------------------\n');
        
        for i = 1:length(channel_names)
            if exist('channel_fs', 'var') && length(channel_fs) >= i
                fs_info = sprintf(' (%.1f Hz)', channel_fs(i));
            else
                fs_info = '';
            end
            
            if exist('channel_dimensions', 'var') && length(channel_dimensions) >= i && ~isempty(channel_dimensions{i})
                dim_info = sprintf(' [%s]', channel_dimensions{i});
            else
                dim_info = '';
            end
            
            if exist('channel_filters', 'var') && length(channel_filters) >= i && ~isempty(channel_filters{i})
                filter_info = sprintf(' Filter: %s', channel_filters{i});
            else
                filter_info = '';
            end
            
            fprintf(fid, 'Channel %d: %s%s%s%s\n', i, strtrim(channel_names{i}), fs_info, dim_info, filter_info);
        end
        
        % Write PUP channel mapping results
        fprintf(fid, '\nPUP CHANNEL MAPPING:\n');
        fprintf(fid, '-------------------\n');
        
        for i = 1:length(target_signals)
            target = target_signals{i};
            if isfield(found_channels, target) && ~isnan(found_channels.(target))
                fprintf(fid, '%s: Channel %d (%s)\n', target, found_channels.(target), strtrim(channel_names{found_channels.(target)}));
            else
                fprintf(fid, '%s: Not found\n', target);
            end
        end
        
        % Write AMasterSpreadsheet mapping
        fprintf(fid, '\nAMASTERSPREADSHEET COLUMN MAPPING:\n');
        fprintf(fid, '---------------------------------\n');
        fprintf(fid, 'Copy these values to your AMasterSpreadsheet.xlsx:\n\n');
        
        for i = 1:length(target_signals)
            if i <= length(columns)
                target = target_signals{i};
                if isfield(found_channels, target) && ~isnan(found_channels.(target))
                    fprintf(fid, 'Column %s (%s): %d\n', columns{i}, target, found_channels.(target));
                else
                    fprintf(fid, 'Column %s (%s): 0 (not found)\n', columns{i}, target);
                end
            end
        end
        
        % Write MATLAB variable for easy access
        fprintf(fid, '\nMATLAB VARIABLE FOR EASY ACCESS:\n');
        fprintf(fid, '-------------------------------\n');
        fprintf(fid, 'channel_mapping = [\n');
        for i = 1:length(target_signals)
            target = target_signals{i};
            if isfield(found_channels, target) && ~isnan(found_channels.(target))
                value = found_channels.(target);
            else
                value = 0;
            end
            if i < length(target_signals)
                fprintf(fid, '    %d; %% %s\n', value, target);
            else
                fprintf(fid, '    %d]; %% %s\n', value, target);
            end
        end
        
        % Write summary statistics
        fprintf(fid, '\nSUMMARY STATISTICS:\n');
        fprintf(fid, '------------------\n');
        found_count = sum(~isnan(struct2array(found_channels)));
        total_targets = length(target_signals);
        fprintf(fid, 'Channels found: %d out of %d (%.1f%%)\n', found_count, total_targets, (found_count/total_targets)*100);
        fprintf(fid, 'Total channels in file: %d\n', length(channel_names));
        fprintf(fid, 'Channels mapped for PUP: %d\n', found_count);
        fprintf(fid, 'Unmapped channels: %d\n', length(channel_names) - used_channels_count);
        
        % Close file
        fclose(fid);
        
        disp(['✓ Analysis saved to: ', output_filename]);
        disp(['  File location: ', fullfile(pwd, output_filename)]);
        
    catch ME
        disp(['✗ Error saving analysis file: ', ME.message]);
        if exist('fid', 'var') && fid ~= -1
            fclose(fid);
        end
    end
    
    % ============== END SAVE SECTION ==============
    
    % Allow user to select a channel to plot
    disp(' ');
    disp('Available channels:');
    for i = 1:length(channel_names)
        disp([num2str(i), ': ', strtrim(channel_names{i})]);
    end
    
    channel_idx = input('Enter channel number to plot (0 to exit): ');
    
    while channel_idx > 0 && channel_idx <= length(channel_names)
        % Read the selected channel data
        disp(['Loading channel: ', channel_names{channel_idx}]);
        
        try
            if exist('blockEdfLoad', 'file')
                % Use blockEdfLoad - try different approaches
                clean_channel_name = strtrim(channel_names{channel_idx});
                disp(['Attempting to load channel: "', clean_channel_name, '"']);
                
                % Try approach 1: Load specific channel
                try
                    [~, ~, signalCell] = blockEdfLoad(full_path, clean_channel_name);
                    signal_data = signalCell{1};
                    fs = channel_fs(channel_idx);
                    disp('Successfully loaded with blockEdfLoad method 1');
                catch ME1
                    disp(['blockEdfLoad method 1 failed: ', ME1.message]);
                    
                    % Try approach 2: Load all channels and select one
                    try
                        disp('Trying to load all channels...');
                        [~, ~, signalCell] = blockEdfLoad(full_path);
                        signal_data = signalCell{channel_idx};
                        fs = channel_fs(channel_idx);
                        disp('Successfully loaded with blockEdfLoad method 2');
                    catch ME2
                        disp(['blockEdfLoad method 2 failed: ', ME2.message]);
                        error('Both blockEdfLoad methods failed');
                    end
                end
                
            elseif exist('readedfrev3', 'file')
                % Use readedfrev3
                disp('Using readedfrev3...');
                [signal_data, fs] = readedfrev3(full_path, channel_idx-1, 0, Inf);
                disp('Successfully loaded with readedfrev3');
            else
                % Use MATLAB's edfread
                disp('Using MATLAB edfread...');
                clean_channel_name = strtrim(channel_names{channel_idx});
                data = edfread(full_path, 'SelectedSignals', {clean_channel_name});
                signal_data = data.(matlab.lang.makeValidName(clean_channel_name));
                fs = channel_fs(channel_idx);
                disp('Successfully loaded with MATLAB edfread');
            end
            
            % Plot the data
            duration_sec = length(signal_data) / fs;
            time_axis = linspace(0, duration_sec, length(signal_data));
            
            figure;
            if duration_sec > 300
                % If signal is long, plot a 5-minute segment
                segment_length = 5 * 60 * fs;
                plot(time_axis(1:segment_length), signal_data(1:segment_length));
                title([channel_names{channel_idx}, ' (first 5 minutes)']);
            else
                plot(time_axis, signal_data);
                title(channel_names{channel_idx});
            end
            
            xlabel('Time (seconds)');
            ylabel('Amplitude');
            grid on;
            
            % Add option to save the figure
            save_fig = input('Save figure? (1=yes, 0=no): ');
            if save_fig == 1
                fig_name = ['Channel_', num2str(channel_idx), '_', strrep(channel_names{channel_idx}, ' ', '_'), '.png'];
                saveas(gcf, fig_name);
                disp(['Figure saved as: ', fig_name]);
            end
            
            % Option to plot spectrogram for EEG channels
            if contains(lower(channel_names{channel_idx}), {'eeg', 'eog', 'emg'})
                show_spectrogram = input('Show spectrogram? (1=yes, 0=no): ');
                if show_spectrogram == 1
                    figure;
                    spectrogram(signal_data, hamming(fs*2), fs, fs, fs, 'yaxis');
                    title(['Spectrogram: ', channel_names{channel_idx}]);
                    
                    save_spec = input('Save spectrogram? (1=yes, 0=no): ');
                    if save_spec == 1
                        spec_name = ['Spectrogram_', num2str(channel_idx), '_', strrep(channel_names{channel_idx}, ' ', '_'), '.png'];
                        saveas(gcf, spec_name);
                        disp(['Spectrogram saved as: ', spec_name]);
                    end
                end
            end
            
        catch ME
            disp(['Error reading channel data: ', ME.message]);
        end
        
        % Ask for next channel
        channel_idx = input('Enter channel number to plot (0 to exit): ');
    end
    
catch ME
    disp(['Error reading EDF file: ', ME.message]);
    disp(getReport(ME));
end

disp('EDF exploration complete'); 