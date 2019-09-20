% This will use ICA to remove ECG artifacts from a sample MEG dataset. 
% It is assumed the data set has a channel where ECG was recodred 
% from, or there is a particular MEG channel showing a large heart
% artifact.

% download example dataset and define trials
cfg = [];
cfg.dataset = 'ArtifactRemoval.ds'; 
cfg.trialdef.eventtype = 'trial';
cfg = ft_definetrial(cfg);

% remove trials with sensor artifacts
cfg = ft_artifact_jump(cfg);
% remove trials with muscle artifacts
cfg = ft_rejectartifact(cfg);

% define ECG channel
cfg.channel = {'MEG', 'EEG058'};
cfg.continuous = 'yes';
data = ft_preprocessing(cfg);

% split ECG channel from MEG channels, to perform ICA on MEG data
% ECG data
cfg = [];
cfg.channel = {'EEG'};
ecg = ft_selectdata(cfg, data); 
ecg.label{:} = 'ECG'; % rename ECG channel
% MEG data
cfg = [];
cfg.channel = {'MEG'};
data = ft_selectdata(cfg, data); 

% downsample data for faster computation
data_orig = data; % save non-downsampled data
cfg            = [];
cfg.resamplefs = 150;
cfg.detrend    = 'no';
data           = ft_resampledata(cfg, data);

% read preprocessed MEG data
load datfile.mat data

% run ICA
cfg            = [];
cfg.method     = 'runica';
comp           = ft_componentanalysis(cfg, data);

% visualize componant topographies
cfg           = [];
cfg.component = [1:20];       % specify the components to plot
cfg.layout    = 'CTF275.lay'; % specify the layout
cfg.comment   = 'no';
ft_topoplotIC(cfg, comp)

% check time courses of componants
cfg          = [];
cfg.channel  = [2:5 15:18]; % specify the componants to plot
cfg.viewmode = 'component';
cfg.layout   = 'CTF275.lay'; % specify the layout
ft_databrowser(cfg, comp)

% decompose the original data as it was prior to downsampling
cfg           = [];
cfg.unmixing  = comp.unmixing;
cfg.topolabel = comp.topolabel;
comp_orig     = ft_componentanalysis(cfg, data_orig);

% reconstruct original data, without the ECG components
cfg           = [];
cfg.component = [3 15];
data_clean    = ft_rejectcomponent(cfg, comp_orig,data_orig);
