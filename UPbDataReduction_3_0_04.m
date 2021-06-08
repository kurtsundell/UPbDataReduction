%% UPBDATAREDUCTION_3_0_04 MATLAB code for UPbDataReduction_3_0_04.fig %%
function varargout = UPbDataReduction_3_0_04(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @UPbDataReduction_3_0_04_OpeningFcn, ...
                   'gui_OutputFcn',  @UPbDataReduction_3_0_04_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
gui_State.gui_Callback = str2func(varargin{1});
end
if nargout
[varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
gui_mainfcn(gui_State, varargin{:});
end

%% SET HANDLE STRUCTURE %%
function UPbDataReduction_3_0_04_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
guidata(hObject, handles);

%% SET DEFAULT COMMAND LINE AND HANDLES STRUCTURE %%
function varargout = UPbDataReduction_3_0_04_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

%% PUSHBUTTON BROWSER %%
function browser_Callback(hObject, eventdata, handles)
[filename pathname] = uigetfile({'*'},'File Selector');
fullpathname = strcat(pathname, filename);
file_original = fileread(fullpathname);
set(handles.filepath, 'String', fullpathname); %show path name
handles.fullpathname = fullpathname;
guidata(hObject,handles);

%% PUSHBUTTON REDUCE DATA %%
function reduce_data_Callback(hObject, eventdata, handles)
%% READ IN USER INPUTS %%
cla(handles.axes_distribution,'reset'); 
set(handles.n_plotted,'String','?');
set(handles.optimize_text,'String','');
cla reset
set(gca,'xtick',[],'ytick',[],'Xcolor','w','Ycolor','w')

fullpathname = handles.fullpathname;
pleis_Pb206_U238_known = str2num(get(handles.known_p68,'String'));
pleis_Pb207_Pb206_known = str2num(get(handles.known_p76,'String'));
pleis_Pb207_U235_known = str2num(get(handles.known_p75,'String'));
pleis_Pb208_Th232_known = str2num(get(handles.known_p82,'String'));
pleis_Pb206_U238_known_err = str2num(get(handles.known_p68err,'String'));
pleis_Pb207_Pb206_known_err = str2num(get(handles.known_p76err,'String'));
pleis_Pb207_U235_known_err = str2num(get(handles.known_p75err,'String'));
pleis_Pb208_Th232_known_err = str2num(get(handles.known_p82err,'String'));
fc5z_Pb206_U238_known = str2num(get(handles.known_s68,'String'));
fc5z_Pb207_Pb206_known = str2num(get(handles.known_s76,'String'));
fc5z_Pb207_U235_known = str2num(get(handles.known_s75,'String'));
fc5z_Pb208_Th232_known = str2num(get(handles.known_s82,'String'));
fc5z_Pb206_U238_known_err = str2num(get(handles.known_s68err,'String'));
fc5z_Pb207_Pb206_known_err = str2num(get(handles.known_s76err,'String'));
fc5z_Pb207_U235_known_err = str2num(get(handles.known_s75err,'String'));
fc5z_Pb208_Th232_known_err = str2num(get(handles.known_s82err,'String'));

PLEIS = get(handles.ref_mat_primary,'String');
FC5Z = get(handles.ref_mat_secondary,'String');

reject_poly_order = str2num(get(handles.reject_poly_order,'String'));
reject_spline_breaks = str2num(get(handles.reject_spline_breaks,'String'));
pval = str2num(get(handles.pval,'String'));

outlier_cutoff_68 = str2num(get(handles.outlier_cutoff_68,'String'));
outlier_cutoff_76 = str2num(get(handles.outlier_cutoff_76,'String'));
outlier_cutoff_75 = str2num(get(handles.outlier_cutoff_75,'String'));
outlier_cutoff_82 = str2num(get(handles.outlier_cutoff_82,'String'));

replace_bad_rho = str2num(get(handles.replace_bad_rho,'String'));
poly_order = str2num(get(handles.poly_order,'String'));
breaks = str2num(get(handles.spline_breaks,'String'));
BL_xmin = str2num(get(handles.BL_min,'String'));
BL_xmax = str2num(get(handles.BL_max,'String'));
threshold_U238 = str2num(get(handles.threshold,'String'));
add_sec = str2num(get(handles.add_int,'String'));
int_time = str2num(get(handles.int_duration,'String'));

filter_unc_cutoff = str2num(get(handles.filter_unc_cutoff,'String'));
filter_transition_68_76 = str2num(get(handles.filter_transition_68_76,'String'));
filter_disc_transition = str2num(get(handles.filter_disc_transition,'String'));
filter_disc_young = str2num(get(handles.filter_disc_young,'String'));
filter_disc_old = str2num(get(handles.filter_disc_old,'String'));
filter_disc_rev = str2num(get(handles.filter_disc_rev,'String'));

%% FILE INPUT OPTION #1: READ AND PARSE .msws Iso FILE %%
rad_on=get(handles.uipanel_input_data,'selectedobject');
        switch rad_on
        case handles.radio_input_prn
            
file_copy = strcat(fullpathname, '_copy.csv');
copyfile(fullpathname, file_copy, 'f');
text = fileread(file_copy);
d1 = [file_copy];
[numbers text, data] = xlsread(d1);
            
numbers1 = numbers;
out = numbers1(all(~isnan(numbers1),2),:);

for i = 2:length(out(:,1))
if out(i,2) < out(i-1,2)
data_count(i,:) = 1;
else
data_count(i,:) = 0;
end
end

for i = 2:length(out(:,1))
if out(i,2) < out(i-1,2)
data_count(i-1,:) = -1;
else
data_count(i,:) = 0;
end
end

data_count(1,1) = 1;
data_count(length(out),1) = -1;

d = strcmp(text(:,1), 'Processed Time/Date');
d1 = double(d);
[row,col] = find(d1>0);

[tstart,col1] = find(data_count>0);
[tend,col2] = find(data_count<0);

for i = 1:length(row)
name(i,1) = {text(row(i,1)+1,1)};
end

for i=1:length(name)
name_char(i,1)=(name{i,1});
end

%%%%% DEAL WITH UNEVEN SAMPLE LENGTH %%%%%
for i=1:length(tstart)
samp_length(i,:) = tend(i,:)-tstart(i,:)+1;
end

samp_length_max = max(samp_length);
samp_length_min = min(samp_length);

for i=1:length(tstart)
samp_length_diff(i,:) = samp_length_max - samp_length(i,:);
end

samp_length_diff_max = max(samp_length_diff);
length_out = length(out(:,1));
data_length = length(data(1,:));

if samp_length_diff(length(samp_length_diff),1) > 0
	out(length_out+1:length_out+1+samp_length_diff_max,1:data_length) = 0;
else
	out = out;
end

for i=1:length(tstart)
samp_length_diff(i,:) = samp_length_max - samp_length(i,:);
end

for i=1:length(tstart)
if samp_length_diff(i,:) < 1
	data_ind(:,:,i) = out(tstart(i,1):tend(i,1),:); 
else
	data_ind(:,:,i) = out(tstart(i,1):tend(i,1)+samp_length_diff(i,:),:);
end
end

for i=1:length(tstart)
if samp_length_diff(i,1) > 0
	data_ind(samp_length(i,1)+1:samp_length(i,1)+samp_length_diff(i,1),:) = 0;
else
	data_ind = data_ind;
end
end

numsamples = length(data_ind(1,1,:));
global data_ind
%%%%% ASSIGN RAW MEASUREMENTS AND TIME TO VARIABLES AND REPLACE NaNs/INFs WITH 0 %%%%%
for i = 1:length(tstart)
Pb206_U238(:,i) = data_ind(:,6,i)./data_ind(:,10,i);
end

Pb206_U238(~isfinite(Pb206_U238))=0;

for i = 1:length(tstart)
Pb207_Pb206(:,i) = data_ind(:,7,i)./data_ind(:,6,i);
end

Pb207_Pb206(~isfinite(Pb207_Pb206))=0;

for i = 1:length(tstart)
Pb207_U235(:,i) = Pb207_Pb206(:,i).*Pb206_U238(:,i).*137.82;
end

Pb207_U235(~isfinite(Pb207_U235))=0;

for i = 1:length(tstart)
Pb208_Th232(:,i) = data_ind(:,8,i)./data_ind(:,9,i);
end

Pb208_Th232(~isfinite(Pb208_Th232))=0;

for i = 1:length(tstart)
Hg202(:,i) = data_ind(:,3,i);
end

Hg202(~isfinite(Hg202))=0;

for i = 1:length(tstart)
Hg201(:,i) = data_ind(:,4,i);
end

Hg201(~isfinite(Hg201))=0;

for i = 1:length(tstart)
Pb204(:,i) = data_ind(:,5,i);
end

Pb204(~isfinite(Pb204))=0;

for i = 1:length(tstart)
time(:,i) = data_ind(:,2,i);
end

time(~isfinite(time))=0;

for i=1:length(name)
t_all(:,i) = data_ind(:,2,i);
end

%%%%% CONCATENATE ALL RAW MEASUREMENTS %%%%%
values_all(:,:,1:length(name)) = data_ind(:,3:11,1:length(name));

%%%%% CALCULATE BASELINE FOR EACH SAMPLE %%%%%
for j = 1:length(name)
for i = 1:length(t_all(:,1))
if t_all(i,j) > BL_xmin && t_all(i,j) < BL_xmax
    t_BL_trim(i,j) = t_all(i,j);
else
    t_BL_trim(i,j) = 0;
end
end
end

for i=1:length(name)
t_BL_trim_length(:,i) = length(nonzeros(t_BL_trim(:,i)));
end

for i=1:numsamples
BL_trim_mean(i,:) = mean(values_all(1:t_BL_trim_length,:,i));
end

%%%%% standard error for each sample baseline %%%%%
for i=1:numsamples
BL_trim_SE(i,:) = std(values_all(1:t_BL_trim_length,:,i))/(sqrt(length(values_all(1:t_BL_trim_length,:,i))));
end

%%%%% convert to 3D matrix for baseline subtraction from all samples %%%%%
for j=1:numsamples
for i=1:length(values_all(:,1,1))
values_BL_trim_mean_expand(i,:,j) = BL_trim_mean(j,:);
end
end

for i=1:numsamples
values_all_baseline_subtract(:,:,i)=values_all(:,:,i)-values_BL_trim_mean_expand(:,:,i);
end

%%%%% assign baseline-subtracted values to variables %%%%%
for i=1:numsamples
BLS_all_Hg202(:,i) = values_all_baseline_subtract(:,1,i);
end

for i=1:numsamples
BLS_all_Hg201(:,i) = values_all_baseline_subtract(:,2,i);
end

for i=1:numsamples
BLS_all_Pb204(:,i) = values_all_baseline_subtract(:,3,i);
end

for i=1:numsamples
BLS_all_Pb206(:,i) = values_all_baseline_subtract(:,4,i);
end

for i=1:numsamples
BLS_all_Pb207(:,i) = values_all_baseline_subtract(:,5,i);
end

for i=1:numsamples
BLS_all_Pb208(:,i) = values_all_baseline_subtract(:,6,i);
end

for i=1:numsamples
BLS_all_Th232(:,i) = values_all_baseline_subtract(:,7,i);
end

for i=1:numsamples
BLS_all_U238(:,i) = values_all_baseline_subtract(:,8,i);
end

for i=1:numsamples
BLS_all_Hg204(:,i) = values_all_baseline_subtract(:,9,i);
end

for i=1:numsamples
max_BLS_U238(1,i) = max(BLS_all_U238(:,i));
end

%%%%% FIND TIME ZERO (t0) FOR EACH SAMPLE TO SET INTEGRATION WINDOW %%%%%
for i=1:numsamples
if max_BLS_U238(1,i) < threshold_U238
	t0_U238_idx_length(:,i) = 0;
else
	t0_U238_idx_length(:,i) = length(find(BLS_all_U238(:,i) > threshold_U238));
end
end

for i=1:numsamples
if length(find(BLS_all_U238(:,i) > threshold_U238, 21)) < 21
	t0_U238_idx(1:21,i) = 0;
else
	t0_U238_idx(:,i) = find(BLS_all_U238(:,i) > threshold_U238, 21);
end
end

t0_consec = diff(t0_U238_idx)==1;

for i=1:numsamples
if sum(t0_consec(:,i)) < 1
	t0_U238_idx2(:,i) = 1;
elseif sum(t0_consec(:,i)) > 19;
	t0_U238_idx2(:,i) = min(t0_U238_idx(:,i));
else
	t0_U238_idx2(:,i) = t0_U238_idx((max(find(t0_consec(:,i) < 1)) + 1),i);
end
end

%%%%% set time zero for each sample %%%%%
for i=1:numsamples
t0_U238(1,i) = t_all(t0_U238_idx2(1,i),i);
end

%%%%% SET INTEGRATION WINDOWS %%%%%
for i=1:numsamples
INT_xmin(1,i) = t0_U238(1,i) + add_sec;
end

for i=1:numsamples
INT_xmax(1,i) = INT_xmin(1,i) + int_time;
end

%%%%% if measurements fall within window then keep, otherwise set to zero %%%%%
for j = 1:length(name)
for i = 1:length(t_all(:,1))
if t_all(i,j) < INT_xmax(1,j) && t_all(i,j) > INT_xmin(1,j)
    t_INT_trim(i,j) = t_all(i,j);
else
    t_INT_trim(i,j) = 0;
end
end
end

%%%%% FIND TIME AND SET INDEXES FOR INTEGRATION WINDOWS FOR EACH SAMPLE %%%%%
[t_INT_trim_max t_INT_trim_max_idx] = max(t_INT_trim);

for i=1:length(name)
t_INT_trim_min_idx(:,i) = find(t_INT_trim(:,i)~=0, 1, 'first');
end

for i=1:length(name)
t_INT_trim_min(:,i) = t_INT_trim(t_INT_trim_min_idx(:,i),i);
end

%%%%% CALCULATE MEAN AND 2 STANDARD ERROR FOR ALL SAMPLES %%%%%
for i=1:numsamples
raw_Hg201(i,:) = mean(BLS_all_Hg201(t_INT_trim_min_idx(:,i):t_INT_trim_max_idx(:,i),i),1);
end
for i=1:numsamples
raw_Hg201_2SE(i,:) = std(BLS_all_Hg201(t_INT_trim_min_idx(:,i):t_INT_trim_max_idx(:,i),i),1)/(sqrt(length(BLS_all_Hg201(t_INT_trim_min_idx(:,i):t_INT_trim_max_idx(:,i),i))));
end

for i=1:numsamples
raw_Hg202(i,:) = mean(BLS_all_Hg202(t_INT_trim_min_idx(:,i):t_INT_trim_max_idx(:,i),i),1);
end
for i=1:numsamples
raw_Hg202_2SE(i,:) = std(BLS_all_Hg202(t_INT_trim_min_idx(:,i):t_INT_trim_max_idx(:,i),i),1)/(sqrt(length(BLS_all_Hg202(t_INT_trim_min_idx(:,i):t_INT_trim_max_idx(:,i),i))));
end

for i=1:numsamples
raw_Pb204(i,:) = mean(BLS_all_Pb204(t_INT_trim_min_idx(:,i):t_INT_trim_max_idx(:,i),i),1);
end
for i=1:numsamples
raw_Pb204_2SE(i,:) = std(BLS_all_Pb204(t_INT_trim_min_idx(:,i):t_INT_trim_max_idx(:,i),i),1)/(sqrt(length(BLS_all_Pb204(t_INT_trim_min_idx(:,i):t_INT_trim_max_idx(:,i),i))));
end

for i=1:numsamples
corr_Hg202(i,:) = mean(BLS_all_Hg202(t_INT_trim_min_idx(:,i):t_INT_trim_max_idx(:,i),i),1);
end
for i=1:numsamples
corr_Hg202_2SE_tmp(i,:) = std(BLS_all_Hg202(t_INT_trim_min_idx(:,i):t_INT_trim_max_idx(:,i),i),1)/(sqrt(length(BLS_all_Hg202(t_INT_trim_min_idx(:,i):t_INT_trim_max_idx(:,i),i))));
end
for i=1:numsamples
corr_Hg202_2SE(i,:) = 2*(sqrt(corr_Hg202_2SE_tmp(i,:).^2 + BL_trim_SE(i,1).^2));
end

for i=1:numsamples
corr_Pb204(i,:) = mean(BLS_all_Pb204(t_INT_trim_min_idx(:,i):t_INT_trim_max_idx(:,i),i),1);
end
for i=1:numsamples
corr_Pb204_2SE_tmp(i,:) = std(BLS_all_Pb204(t_INT_trim_min_idx(:,i):t_INT_trim_max_idx(:,i),i),1)/(sqrt(length(BLS_all_Pb204(t_INT_trim_min_idx(:,i):t_INT_trim_max_idx(:,i),i))));
end
for i=1:numsamples
corr_Pb204_2SE(i,:) = 2*(sqrt(corr_Pb204_2SE_tmp(i,:).^2 + BL_trim_SE(i,3).^2));
end

for i=1:numsamples
corr_Pb206(i,:) = mean(BLS_all_Pb206(t_INT_trim_min_idx(:,i):t_INT_trim_max_idx(:,i),i),1);
end
for i=1:numsamples
corr_Pb206_2SE_tmp(i,:) = std(BLS_all_Pb206(t_INT_trim_min_idx(:,i):t_INT_trim_max_idx(:,i),i),1)/(sqrt(length(BLS_all_Pb206(t_INT_trim_min_idx(:,i):t_INT_trim_max_idx(:,i),i))));
end
for i=1:numsamples
corr_Pb206_2SE(i,:) = 2*(sqrt(corr_Pb206_2SE_tmp(i,:).^2 + BL_trim_SE(i,4).^2));
end

for i=1:numsamples
corr_Pb207(i,:) = mean(BLS_all_Pb207(t_INT_trim_min_idx(:,i):t_INT_trim_max_idx(:,i),i),1);
end
for i=1:numsamples
corr_Pb207_2SE_tmp(i,:) = std(BLS_all_Pb207(t_INT_trim_min_idx(:,i):t_INT_trim_max_idx(:,i),i),1)/(sqrt(length(BLS_all_Pb207(t_INT_trim_min_idx(:,i):t_INT_trim_max_idx(:,i),i))));
end
for i=1:numsamples
corr_Pb207_2SE(i,:) = 2*(sqrt(corr_Pb207_2SE_tmp(i,:).^2 + BL_trim_SE(i,5).^2));
end

for i=1:numsamples
corr_Pb208(i,:) = mean(BLS_all_Pb208(t_INT_trim_min_idx(:,i):t_INT_trim_max_idx(:,i),i),1);
end
for i=1:numsamples
corr_Pb208_2SE_tmp(i,:) = std(BLS_all_Pb208(t_INT_trim_min_idx(:,i):t_INT_trim_max_idx(:,i),i),1)/(sqrt(length(BLS_all_Pb208(t_INT_trim_min_idx(:,i):t_INT_trim_max_idx(:,i),i))));
end
for i=1:numsamples
corr_Pb208_2SE(i,:) = 2*(sqrt(corr_Pb208_2SE_tmp(i,:).^2 + BL_trim_SE(i,6).^2));
end

for i=1:numsamples
corr_Th232(i,:) = mean(BLS_all_Th232(t_INT_trim_min_idx(:,i):t_INT_trim_max_idx(:,i),i),1);
end
for i=1:numsamples
corr_Th232_2SE_tmp(i,:) = std(BLS_all_Th232(t_INT_trim_min_idx(:,i):t_INT_trim_max_idx(:,i),i),1)/(sqrt(length(BLS_all_Th232(t_INT_trim_min_idx(:,i):t_INT_trim_max_idx(:,i),i))));
end
for i=1:numsamples
corr_Th232_2SE(i,:) = 2*(sqrt(corr_Th232_2SE_tmp(i,:).^2 + BL_trim_SE(i,7).^2));
end

for i=1:numsamples
corr_U238(i,:) = mean(BLS_all_U238(t_INT_trim_min_idx(:,i):t_INT_trim_max_idx(:,i),i),1);
end
for i=1:numsamples
corr_U238_2SE_tmp(i,:) = std(BLS_all_U238(t_INT_trim_min_idx(:,i):t_INT_trim_max_idx(:,i),i),1)/(sqrt(length(BLS_all_U238(t_INT_trim_min_idx(:,i):t_INT_trim_max_idx(:,i),i))));
end
for i=1:numsamples
corr_U238_2SE(i,:) = 2*(sqrt(corr_U238_2SE_tmp(i,:).^2 + BL_trim_SE(i,8).^2));
end

%%%%% CONVERT TIME TO DECIMAL TIME %%%%%
for i = 1:length(row)
sample_time_date(i,1) = {text(row(i,1)+1,2)};
end

for i=1:length(name)
sample_time_date(i,1)=(sample_time_date{i,1});
end

[token, remain] = strtok(sample_time_date);
[token, remain] = strtok(remain);
[token, remain] = strtok(remain);
[token, remain] = strtok(remain);

DateString = token;
formatIn = 'HH:MM:SS';
dvec = datevec(DateString,formatIn);

time = dvec(:,4)./24 + dvec(:,5)./(60*24) + dvec(:,6)./(60*60*24);

time_diff = diff(time);
[diff_min diff_min_idx] = min(time_diff);
if diff_min < 0
time(diff_min_idx+1:end,1) = time(diff_min_idx+1:end,1)+1;
else
time=time;
end








analysis_num = name_char;

%%%%% CONVERT INTEGRATIONS EQUAL TO ZERO TO 1 (in cps) AND CHANGE TO PERCENT ERROR %%%%%
for i = 1:length(raw_Hg201)
if raw_Hg201(i,1) == 0
    raw_Hg201(i,1) = 1;
else
    raw_Hg201(i,1) = raw_Hg201(i,1);
end
end
raw_Hg201_2SE = (raw_Hg201_2SE./raw_Hg201).*100;

for i = 1:length(raw_Hg202)
if raw_Hg202(i,1) == 0
    raw_Hg202(i,1) = 1;
else
    raw_Hg202(i,1) = raw_Hg202(i,1);
end
end
raw_Hg202_2SE = (raw_Hg202_2SE./raw_Hg202).*100;

for i = 1:length(raw_Pb204)
if raw_Pb204(i,1) == 0
    raw_Pb204(i,1) = 1;
else
    raw_Pb204(i,1) = raw_Pb204(i,1);
end
end
raw_Pb204_2SE = (raw_Pb204_2SE./raw_Pb204).*100;

raw_Hg202_Hg201 = raw_Hg202./raw_Hg201;
raw_Hg202_Hg201_2SE = sqrt(raw_Hg201_2SE.*raw_Hg201_2SE + raw_Hg202_2SE.*raw_Hg202_2SE);

for i = 1:length(corr_Hg202)
if corr_Hg202(i,1) == 0
    corr_Hg202(i,1) = 1;
else
    corr_Hg202(i,1) = corr_Hg202(i,1);
end
end
corr_Hg202_2SE = abs((corr_Hg202_2SE./corr_Hg202).*100);

for i = 1:length(corr_Pb204)
if corr_Pb204(i,1) == 0
    corr_Pb204(i,1) = 1;
else
    corr_Pb204(i,1) = corr_Pb204(i,1);
end
end    
corr_Pb204_2SE = abs((corr_Pb204_2SE./corr_Pb204).*100);

for i = 1:length(corr_Pb206)
if corr_Pb206(i,1) == 0
    corr_Pb206(i,1) = 1;
else
    corr_Pb206(i,1) = corr_Pb206(i,1);
end
end
corr_Pb206_2SE = (corr_Pb206_2SE./corr_Pb206).*100;

for i = 1:length(corr_Pb207)
if corr_Pb207(i,1) == 0
    corr_Pb207(i,1) = 1;
else
    corr_Pb207(i,1) = corr_Pb207(i,1);
end
end
corr_Pb207_2SE = (corr_Pb207_2SE./corr_Pb207).*100;

for i = 1:length(corr_Pb208)
if corr_Pb208(i,1) == 0
    corr_Pb208(i,1) = 1;
else
    corr_Pb208(i,1) = corr_Pb208(i,1);
end
end
corr_Pb208_2SE = (corr_Pb208_2SE./corr_Pb208).*100;

for i = 1:length(corr_Th232)
if corr_Th232(i,1) == 0
    corr_Th232(i,1) = 1;
else
    corr_Th232(i,1) = corr_Th232(i,1);
end
end
corr_Th232_2SE = (corr_Th232_2SE./corr_Th232).*100;

for i = 1:length(corr_U238)
if corr_U238(i,1) == 0
    corr_U238(i,1) = 1;
else
    corr_U238(i,1) = corr_U238(i,1);
end
end
corr_U238_2SE = (corr_U238_2SE./corr_U238).*100;

%%%%% CALCULATE RATIOS OF INTEREST %%%%%
corr_Pb207_Pb206 = corr_Pb207./corr_Pb206;
corr_Pb207_Pb206_err = sqrt(corr_Pb207_2SE.*corr_Pb207_2SE + corr_Pb206_2SE.*corr_Pb206_2SE);
corr_Pb206_U238 = corr_Pb206./corr_U238;
corr_Pb206_U238_err = sqrt(corr_Pb206_2SE.*corr_Pb206_2SE + corr_U238_2SE.*corr_U238_2SE);
corr_Pb208_Th232 = corr_Pb208./corr_Th232;
corr_Pb208_Th232_err = sqrt(corr_Pb208_2SE.*corr_Pb208_2SE + corr_Th232_2SE.*corr_Th232_2SE);
corr_Pb207_U235 = corr_Pb207_Pb206.*corr_Pb206_U238.*137.82;
corr_Pb207_U235_err = sqrt(corr_Pb207_Pb206_err.*corr_Pb207_Pb206_err + ...
	corr_Pb206_U238_err.*corr_Pb206_U238_err);

%% FILE INPUT OPTION #2: READ AND PARSE Iolite-export .csv file FILE. --Note, copy and paste Iolite text file into Excel and change column 'time' format to 'general'. This will convert it to decimal time. %%
        case handles.radio_input_csv

d1 = [fullpathname];
[numbers text, data] = xlsread(d1);

time = cell2mat(data(2:end,7));
analysis_num = data(2:end,4);

%%%%% CONVERT INTEGRATIONS EQUAL TO ZERO TO 1 (in cps) AND CHANGE TO PERCENT ERROR %%%%%
raw_Hg201 = cell2mat(data(2:end,12));
for i = 1:length(raw_Hg201)
if raw_Hg201(i,1) == 0
    raw_Hg201(i,1) = 1;
else
    raw_Hg201(i,1) = raw_Hg201(i,1);
end
end
raw_Hg201_2SE = cell2mat(data(2:end,13));
raw_Hg201_2SE = (raw_Hg201_2SE./raw_Hg201).*100;

raw_Hg202 = cell2mat(data(2:end,10));
for i = 1:length(raw_Hg202)
if raw_Hg202(i,1) == 0
    raw_Hg202(i,1) = 1;
else
    raw_Hg202(i,1) = raw_Hg202(i,1);
end
end
raw_Hg202_2SE = cell2mat(data(2:end,11));
raw_Hg202_2SE = (raw_Hg202_2SE./raw_Hg202).*100;

raw_Pb204 = cell2mat(data(2:end,14));
for i = 1:length(raw_Pb204)
if raw_Pb204(i,1) == 0
    raw_Pb204(i,1) = 1;
else
    raw_Pb204(i,1) = raw_Pb204(i,1);
end
end
raw_Pb204_2SE = cell2mat(data(2:end,15));
raw_Pb204_2SE = (raw_Pb204_2SE./raw_Pb204).*100;

raw_Hg202_Hg201 = raw_Hg202./raw_Hg201;
raw_Hg202_Hg201_2SE = sqrt(raw_Hg201_2SE.*raw_Hg201_2SE + raw_Hg202_2SE.*raw_Hg202_2SE);

corr_Hg202 = cell2mat(data(2:end,16));
for i = 1:length(corr_Hg202)
if corr_Hg202(i,1) == 0
    corr_Hg202(i,1) = 1;
else
    corr_Hg202(i,1) = corr_Hg202(i,1);
end
end
corr_Hg202_2SE = cell2mat(data(2:end,17));
corr_Hg202_2SE = abs((corr_Hg202_2SE./corr_Hg202).*100);

corr_Pb204 = cell2mat(data(2:end,20));
for i = 1:length(corr_Pb204)
if corr_Pb204(i,1) == 0
    corr_Pb204(i,1) = 1;
else
    corr_Pb204(i,1) = corr_Pb204(i,1);
end
end    
corr_Pb204_2SE = cell2mat(data(2:end,21));
corr_Pb204_2SE = abs((corr_Pb204_2SE./corr_Pb204).*100);

corr_Pb206 = cell2mat(data(2:end,22));
for i = 1:length(corr_Pb206)
if corr_Pb206(i,1) == 0
    corr_Pb206(i,1) = 1;
else
    corr_Pb206(i,1) = corr_Pb206(i,1);
end
end
corr_Pb206_2SE = cell2mat(data(2:end,23));
corr_Pb206_2SE = (corr_Pb206_2SE./corr_Pb206).*100;

corr_Pb207 = cell2mat(data(2:end,24));
for i = 1:length(corr_Pb207)
if corr_Pb207(i,1) == 0
    corr_Pb207(i,1) = 1;
else
    corr_Pb207(i,1) = corr_Pb207(i,1);
end
end
corr_Pb207_2SE = cell2mat(data(2:end,25));
corr_Pb207_2SE = (corr_Pb207_2SE./corr_Pb207).*100;

corr_Pb208 = cell2mat(data(2:end,26));
for i = 1:length(corr_Pb208)
if corr_Pb208(i,1) == 0
    corr_Pb208(i,1) = 1;
else
    corr_Pb208(i,1) = corr_Pb208(i,1);
end
end
corr_Pb208_2SE = cell2mat(data(2:end,27));
corr_Pb208_2SE = (corr_Pb208_2SE./corr_Pb208).*100;

corr_Th232 = cell2mat(data(2:end,28));
for i = 1:length(corr_Th232)
if corr_Th232(i,1) == 0
    corr_Th232(i,1) = 1;
else
    corr_Th232(i,1) = corr_Th232(i,1);
end
end
corr_Th232_2SE = cell2mat(data(2:end,29));
corr_Th232_2SE = (corr_Th232_2SE./corr_Th232).*100;

corr_U238 = cell2mat(data(2:end,30));
for i = 1:length(corr_U238)
if corr_U238(i,1) == 0
    corr_U238(i,1) = 1;
else
    corr_U238(i,1) = corr_U238(i,1);
end
end
corr_U238_2SE = cell2mat(data(2:end,31));
corr_U238_2SE = (corr_U238_2SE./corr_U238).*100;

%%%%% CALCULATE RATIOS OF INTEREST %%%%%
corr_Pb206_U238 = corr_Pb206./corr_U238;
corr_Pb206_U238_err = sqrt(corr_Pb206_2SE.*corr_Pb206_2SE + corr_U238_2SE.*corr_U238_2SE);
corr_Pb207_Pb206 = corr_Pb207./corr_Pb206;
corr_Pb207_Pb206_err = sqrt(corr_Pb207_2SE.*corr_Pb207_2SE + corr_Pb206_2SE.*corr_Pb206_2SE);
corr_Pb207_U235 = corr_Pb207_Pb206.*corr_Pb206_U238.*137.82;
corr_Pb207_U235_err = sqrt(corr_Pb207_Pb206_err.*corr_Pb207_Pb206_err + corr_Pb206_U238_err.*corr_Pb206_U238_err);
corr_Pb208_Th232 = corr_Pb208./corr_Th232;
corr_Pb208_Th232_err = sqrt(corr_Pb208_2SE.*corr_Pb208_2SE + corr_Th232_2SE.*corr_Th232_2SE);
end

%% FIND ALL INDICES, VALUES, AND TIMES OF STANDARDS %%
pleis_ind = strfind(analysis_num, PLEIS);
			if isempty(pleis_ind(~cellfun('isempty',pleis_ind))) == 1
			err_dlg=errordlg('Cound not find any reference material data. Double check the name (case sensitive).','Wait!');
			waitfor(err_dlg);
			else
			end
fc5z_ind = strfind(analysis_num, FC5Z);

pleis = abs(cellfun(@isempty,pleis_ind)-1);
fc5z = abs(cellfun(@isempty,fc5z_ind)-1);

pleis_time = nonzeros(pleis.*time);
fc5z_time = nonzeros(fc5z.*time);

time2 = time;
pleis_fc5z = pleis + fc5z;
samples = abs(pleis_fc5z-1);

%% FRACTIONATION FACTORS AND MEASURED RATIOS %%
frac_corr_pleis_Pb206_U238 = pleis.*(pleis_Pb206_U238_known./corr_Pb206_U238); %calculate fractionation factor
frac_corr_pleis_Pb206_U238_err = pleis.*(corr_Pb206_U238_err.*corr_Pb206_U238_err); % percent error
frac_corr_pleis_Pb206_U238_err = pleis.*(sqrt(frac_corr_pleis_Pb206_U238_err + pleis_Pb206_U238_known_err.*pleis_Pb206_U238_known_err));
frac_corr_pleis_Pb206_U238_nz = nonzeros(frac_corr_pleis_Pb206_U238); %fractionation factor nonzeros
frac_corr_pleis_Pb206_U238_nz_err = nonzeros(frac_corr_pleis_Pb206_U238_err);

frac_corr_pleis_Pb207_Pb206 = pleis.*(pleis_Pb207_Pb206_known./corr_Pb207_Pb206); %calculate fractionation factor
frac_corr_pleis_Pb207_Pb206_err = pleis.*(corr_Pb207_Pb206_err.*corr_Pb207_Pb206_err); % percent error
frac_corr_pleis_Pb207_Pb206_err = pleis.*(sqrt(frac_corr_pleis_Pb207_Pb206_err + pleis_Pb207_Pb206_known_err.*pleis_Pb207_Pb206_known_err));
frac_corr_pleis_Pb207_Pb206_nz = nonzeros(frac_corr_pleis_Pb207_Pb206); %fractionation factor nonzeros
frac_corr_pleis_Pb207_Pb206_nz_err = nonzeros(frac_corr_pleis_Pb207_Pb206_err);

frac_corr_pleis_Pb207_U235 = pleis.*(pleis_Pb207_U235_known./corr_Pb207_U235); %calculate fractionation factor
frac_corr_pleis_Pb207_U235_err = pleis.*(corr_Pb207_U235_err.*corr_Pb207_U235_err); % percent error
frac_corr_pleis_Pb207_U235_err = pleis.*(sqrt(frac_corr_pleis_Pb207_U235_err + pleis_Pb207_U235_known_err.*pleis_Pb207_U235_known_err));
frac_corr_pleis_Pb207_U235_nz = nonzeros(frac_corr_pleis_Pb207_U235); %fractionation factor nonzeros
frac_corr_pleis_Pb207_U235_nz_err = nonzeros(frac_corr_pleis_Pb207_U235_err);

frac_corr_pleis_Pb208_Th232 = pleis.*(pleis_Pb208_Th232_known./corr_Pb208_Th232); %calculate fractionation factor
frac_corr_pleis_Pb208_Th232_err = pleis.*(corr_Pb208_Th232_err.*corr_Pb208_Th232_err); % percent error
frac_corr_pleis_Pb208_Th232_err = pleis.*(sqrt(frac_corr_pleis_Pb208_Th232_err + pleis_Pb208_Th232_known_err.*pleis_Pb208_Th232_known_err));
frac_corr_pleis_Pb208_Th232_nz = nonzeros(frac_corr_pleis_Pb208_Th232); %fractionation factor nonzeros
frac_corr_pleis_Pb208_Th232_nz_err = nonzeros(frac_corr_pleis_Pb208_Th232_err);

fract_pleis_68_hi = frac_corr_pleis_Pb206_U238_nz + (frac_corr_pleis_Pb206_U238_nz.*(frac_corr_pleis_Pb206_U238_nz_err.*0.01));
fract_pleis_68_lo = frac_corr_pleis_Pb206_U238_nz - (frac_corr_pleis_Pb206_U238_nz.*(frac_corr_pleis_Pb206_U238_nz_err.*0.01));
fract_pleis_76_hi = frac_corr_pleis_Pb207_Pb206_nz + (frac_corr_pleis_Pb207_Pb206_nz.*(frac_corr_pleis_Pb207_Pb206_nz_err.*0.01));
fract_pleis_76_lo = frac_corr_pleis_Pb207_Pb206_nz - (frac_corr_pleis_Pb207_Pb206_nz.*(frac_corr_pleis_Pb207_Pb206_nz_err.*0.01));
fract_pleis_75_hi = frac_corr_pleis_Pb207_U235_nz + (frac_corr_pleis_Pb207_U235_nz.*(frac_corr_pleis_Pb207_U235_nz_err.*0.01));
fract_pleis_75_lo = frac_corr_pleis_Pb207_U235_nz - (frac_corr_pleis_Pb207_U235_nz.*(frac_corr_pleis_Pb207_U235_nz_err.*0.01));
fract_pleis_82_hi = frac_corr_pleis_Pb208_Th232_nz + (frac_corr_pleis_Pb208_Th232_nz.*(frac_corr_pleis_Pb208_Th232_nz_err.*0.01));
fract_pleis_82_lo = frac_corr_pleis_Pb208_Th232_nz - (frac_corr_pleis_Pb208_Th232_nz.*(frac_corr_pleis_Pb208_Th232_nz_err.*0.01));

%% REJECT REFERENCE MATERIAL OUTLIERS %%
		rad_on_outliers=get(handles.uipanel_outliers,'selectedobject');
        switch rad_on_outliers
        case handles.radio_none

fit_hi_decimate_68 = frac_corr_pleis_Pb206_U238_nz;
fit_lo_decimate_68 = frac_corr_pleis_Pb206_U238_nz;
fit_hi_decimate_76 = frac_corr_pleis_Pb207_Pb206_nz;
fit_lo_decimate_76 = frac_corr_pleis_Pb207_Pb206_nz;
fit_hi_decimate_75 = frac_corr_pleis_Pb207_U235_nz;
fit_lo_decimate_75 = frac_corr_pleis_Pb207_U235_nz;
fit_hi_decimate_82 = frac_corr_pleis_Pb208_Th232_nz;
fit_lo_decimate_82 = frac_corr_pleis_Pb208_Th232_nz;

        case handles.radio_reject_poly

model_68_pleis = polyfit(pleis_time,frac_corr_pleis_Pb206_U238_nz,reject_poly_order);
model_68 = polyval(model_68_pleis,time);
model_68_hi = model_68 + model_68.*outlier_cutoff_68.*.01;
model_68_lo = model_68 - model_68.*outlier_cutoff_68.*.01;

model_76_pleis = polyfit(pleis_time,frac_corr_pleis_Pb207_Pb206_nz,reject_poly_order);
model_76 = polyval(model_76_pleis,time);
model_76_hi = model_76 + model_76.*outlier_cutoff_76.*.01;
model_76_lo = model_76 - model_76.*outlier_cutoff_76.*.01;

model_75_pleis = polyfit(pleis_time,frac_corr_pleis_Pb207_U235_nz,reject_poly_order);
model_75 = polyval(model_75_pleis,time);
model_75_hi = model_75 + model_75.*outlier_cutoff_75.*.01;
model_75_lo = model_75 - model_75.*outlier_cutoff_75.*.01;

model_82_pleis = polyfit(pleis_time,frac_corr_pleis_Pb208_Th232_nz,reject_poly_order);
model_82 = polyval(model_82_pleis,time);
model_82_hi = model_82 + model_82.*outlier_cutoff_82.*.01;
model_82_lo = model_82 - model_82.*outlier_cutoff_82.*.01;

fit_hi_decimate_68 = interp1(time, model_68_hi, pleis_time);
fit_lo_decimate_68 = interp1(time, model_68_lo, pleis_time);
fit_hi_decimate_76 = interp1(time, model_76_hi, pleis_time);
fit_lo_decimate_76 = interp1(time, model_76_lo, pleis_time);
fit_hi_decimate_75 = interp1(time, model_75_hi, pleis_time);
fit_lo_decimate_75 = interp1(time, model_75_lo, pleis_time);
fit_hi_decimate_82 = interp1(time, model_82_hi, pleis_time);
fit_lo_decimate_82 = interp1(time, model_82_lo, pleis_time);

        case handles.radio_reject_spline

model_68_pleis = splinefit(pleis_time,frac_corr_pleis_Pb206_U238_nz,reject_spline_breaks);
model_68 = ppval(model_68_pleis,time);
model_68_hi = model_68 + model_68.*outlier_cutoff_68.*.01;
model_68_lo = model_68 - model_68.*outlier_cutoff_68.*.01;
model_76_pleis = splinefit(pleis_time,frac_corr_pleis_Pb207_Pb206_nz,reject_spline_breaks);
model_76 = ppval(model_76_pleis,time);
model_76_hi = model_76 + model_76.*outlier_cutoff_76.*.01;
model_76_lo = model_76 - model_76.*outlier_cutoff_76.*.01;

model_75_pleis = splinefit(pleis_time,frac_corr_pleis_Pb207_U235_nz,reject_spline_breaks);
model_75 = ppval(model_75_pleis,time);
model_75_hi = model_75 + model_75.*outlier_cutoff_75.*.01;
model_75_lo = model_75 - model_75.*outlier_cutoff_75.*.01;

model_82_pleis = splinefit(pleis_time,frac_corr_pleis_Pb208_Th232_nz,reject_spline_breaks);
model_82 = ppval(model_82_pleis,time);
model_82_hi = model_82 + model_82.*outlier_cutoff_82.*.01;
model_82_lo = model_82 - model_82.*outlier_cutoff_82.*.01;

fit_hi_decimate_68 = interp1(time, model_68_hi, pleis_time);
fit_lo_decimate_68 = interp1(time, model_68_lo, pleis_time);
fit_hi_decimate_76 = interp1(time, model_76_hi, pleis_time);
fit_lo_decimate_76 = interp1(time, model_76_lo, pleis_time);
fit_hi_decimate_75 = interp1(time, model_75_hi, pleis_time);
fit_lo_decimate_75 = interp1(time, model_75_lo, pleis_time);
fit_hi_decimate_82 = interp1(time, model_82_hi, pleis_time);
fit_lo_decimate_82 = interp1(time, model_82_lo, pleis_time);

		end

for i = 1:length(frac_corr_pleis_Pb206_U238_nz)
if frac_corr_pleis_Pb206_U238_nz(i,1) > fit_hi_decimate_68(i,1)
frac_corr_pleis_rej_68(i,1) = 1;
elseif frac_corr_pleis_Pb206_U238_nz(i,1) < fit_lo_decimate_68(i,1)
frac_corr_pleis_rej_68(i,1) = 1;
else
frac_corr_pleis_rej_68(i,1) = 0;
end
end
frac_corr_pleis_rej_68
for i = 1:length(frac_corr_pleis_Pb207_Pb206_nz)
if frac_corr_pleis_Pb207_Pb206_nz(i,1) > fit_hi_decimate_76(i,1)
frac_corr_pleis_rej_76(i,1) = 1;
elseif frac_corr_pleis_Pb207_Pb206_nz(i,1) < fit_lo_decimate_76(i,1)
frac_corr_pleis_rej_76(i,1) = 1;
else
frac_corr_pleis_rej_76(i,1) = 0;
end
end

for i = 1:length(frac_corr_pleis_Pb207_U235_nz)
if frac_corr_pleis_Pb207_U235_nz(i,1) > fit_hi_decimate_75(i,1)
frac_corr_pleis_rej_75(i,1) = 1;
elseif frac_corr_pleis_Pb207_U235_nz(i,1) < fit_lo_decimate_75(i,1)
frac_corr_pleis_rej_75(i,1) = 1;
else
frac_corr_pleis_rej_75(i,1) = 0;
end
end

for i = 1:length(frac_corr_pleis_Pb208_Th232_nz)
if frac_corr_pleis_Pb208_Th232_nz(i,1) > fit_hi_decimate_82(i,1)
frac_corr_pleis_rej_82(i,1) = 1;
elseif frac_corr_pleis_Pb208_Th232_nz(i,1) < fit_lo_decimate_82(i,1)
frac_corr_pleis_rej_82(i,1) = 1;
else
frac_corr_pleis_rej_82(i,1) = 0;
end
end

for i = 1:length(frac_corr_pleis_rej_68)
frac_corr_pleis_rej(i,1) = max([frac_corr_pleis_rej_68(i,1), frac_corr_pleis_rej_76(i,1), frac_corr_pleis_rej_75(i,1), frac_corr_pleis_rej_82(i,1)]);
end

num_rej = sum(frac_corr_pleis_rej);
set(handles.standards_rejected, 'String', num_rej);

frac_corr_pleis_acc_68 = nonzeros(abs(frac_corr_pleis_rej-1).*frac_corr_pleis_Pb206_U238_nz);
frac_corr_pleis_acc_76 = nonzeros(abs(frac_corr_pleis_rej-1).*frac_corr_pleis_Pb207_Pb206_nz);
frac_corr_pleis_acc_75 = nonzeros(abs(frac_corr_pleis_rej-1).*frac_corr_pleis_Pb207_U235_nz);
frac_corr_pleis_acc_82 = nonzeros(abs(frac_corr_pleis_rej-1).*frac_corr_pleis_Pb208_Th232_nz);

frac_corr_pleis_acc_68_hi = nonzeros(abs(frac_corr_pleis_rej-1).*fract_pleis_68_hi);
frac_corr_pleis_acc_68_lo = nonzeros(abs(frac_corr_pleis_rej-1).*fract_pleis_68_lo);
frac_corr_pleis_acc_76_hi = nonzeros(abs(frac_corr_pleis_rej-1).*fract_pleis_76_hi);
frac_corr_pleis_acc_76_lo = nonzeros(abs(frac_corr_pleis_rej-1).*fract_pleis_76_lo);
frac_corr_pleis_acc_75_hi = nonzeros(abs(frac_corr_pleis_rej-1).*fract_pleis_75_hi);
frac_corr_pleis_acc_75_lo = nonzeros(abs(frac_corr_pleis_rej-1).*fract_pleis_75_lo);
frac_corr_pleis_acc_82_hi = nonzeros(abs(frac_corr_pleis_rej-1).*fract_pleis_82_hi);
frac_corr_pleis_acc_82_lo = nonzeros(abs(frac_corr_pleis_rej-1).*fract_pleis_82_lo);

frac_corr_pleis_rej_68 = nonzeros(abs(frac_corr_pleis_rej).*frac_corr_pleis_Pb206_U238_nz);
frac_corr_pleis_rej_76 = nonzeros(abs(frac_corr_pleis_rej).*frac_corr_pleis_Pb207_Pb206_nz);
frac_corr_pleis_rej_75 = nonzeros(abs(frac_corr_pleis_rej).*frac_corr_pleis_Pb207_U235_nz);
frac_corr_pleis_rej_82 = nonzeros(abs(frac_corr_pleis_rej).*frac_corr_pleis_Pb208_Th232_nz);

frac_corr_pleis_rej_68_err = nonzeros(abs(frac_corr_pleis_rej).*frac_corr_pleis_Pb206_U238_nz_err);
frac_corr_pleis_rej_76_err = nonzeros(abs(frac_corr_pleis_rej).*frac_corr_pleis_Pb207_Pb206_nz_err);
frac_corr_pleis_rej_75_err = nonzeros(abs(frac_corr_pleis_rej).*frac_corr_pleis_Pb207_U235_nz_err);
frac_corr_pleis_rej_82_err = nonzeros(abs(frac_corr_pleis_rej).*frac_corr_pleis_Pb208_Th232_nz_err);

time_acc = nonzeros(abs(frac_corr_pleis_rej-1).*pleis_time);
time_rej = nonzeros(abs(frac_corr_pleis_rej).*pleis_time);

		rad_on_fit=get(handles.uipanel_fit_type,'selectedobject');
		switch rad_on_fit
        case handles.radio_mean

			fit_68(1:length(time),1) = mean(frac_corr_pleis_acc_68);
			fit_68_hi(1:length(time),1) = mean(frac_corr_pleis_acc_68_hi);
			fit_68_lo(1:length(time),1) = mean(frac_corr_pleis_acc_68_lo);
			fit_76(1:length(time),1) = mean(frac_corr_pleis_acc_76);
			fit_76_hi(1:length(time),1) = mean(frac_corr_pleis_acc_76_hi);
			fit_76_lo(1:length(time),1) = mean(frac_corr_pleis_acc_76_lo);
			fit_75(1:length(time),1) = mean(frac_corr_pleis_acc_75);
			fit_75_hi(1:length(time),1) = mean(frac_corr_pleis_acc_75_hi);
			fit_75_lo(1:length(time),1) = mean(frac_corr_pleis_acc_75_lo);
			fit_82(1:length(time),1) = mean(frac_corr_pleis_acc_82);
			fit_82_hi(1:length(time),1) = mean(frac_corr_pleis_acc_82_hi);
			fit_82_lo(1:length(time),1) = mean(frac_corr_pleis_acc_82_lo);

        case handles.radio_linear

			fract_fit_68 = polyfit(time_acc,frac_corr_pleis_acc_68,1);
            fit_68 = polyval(fract_fit_68,time);
            fract_fit_68_hi = polyfit(time_acc,frac_corr_pleis_acc_68_hi,1);
            fit_68_hi = polyval(fract_fit_68_hi,time);
            fract_fit_68_lo = polyfit(time_acc,frac_corr_pleis_acc_68_lo,1);
            fit_68_lo = polyval(fract_fit_68_lo,time);

			fract_fit_76 = polyfit(time_acc,frac_corr_pleis_acc_76,1);
            fit_76 = polyval(fract_fit_76,time);
            fract_fit_76_hi = polyfit(time_acc,frac_corr_pleis_acc_76_hi,1);
            fit_76_hi = polyval(fract_fit_76_hi,time);
            fract_fit_76_lo = polyfit(time_acc,frac_corr_pleis_acc_76_lo,1);
            fit_76_lo = polyval(fract_fit_76_lo,time);

			fract_fit_75 = polyfit(time_acc,frac_corr_pleis_acc_75,1);
            fit_75 = polyval(fract_fit_75,time);
            fract_fit_75_hi = polyfit(time_acc,frac_corr_pleis_acc_75_hi,1);
            fit_75_hi = polyval(fract_fit_75_hi,time);
            fract_fit_75_lo = polyfit(time_acc,frac_corr_pleis_acc_75_lo,1);
            fit_75_lo = polyval(fract_fit_75_lo,time);

			fract_fit_82 = polyfit(time_acc,frac_corr_pleis_acc_82,1);
            fit_82 = polyval(fract_fit_82,time);
            fract_fit_82_hi = polyfit(time_acc,frac_corr_pleis_acc_82_hi,1);
            fit_82_hi = polyval(fract_fit_82_hi,time);
            fract_fit_82_lo = polyfit(time_acc,frac_corr_pleis_acc_82_lo,1);
            fit_82_lo = polyval(fract_fit_82_lo,time);

        case handles.radio_polynomial

			fract_fit_68 = polyfit(time_acc,frac_corr_pleis_acc_68,poly_order);
            fit_68 = polyval(fract_fit_68,time);
            fract_fit_68_hi = polyfit(time_acc,frac_corr_pleis_acc_68_hi,poly_order);
            fit_68_hi = polyval(fract_fit_68_hi,time);
            fract_fit_68_lo = polyfit(time_acc,frac_corr_pleis_acc_68_lo,poly_order);
            fit_68_lo = polyval(fract_fit_68_lo,time);

			fract_fit_76 = polyfit(time_acc,frac_corr_pleis_acc_76,poly_order);
            fit_76 = polyval(fract_fit_76,time);
            fract_fit_76_hi = polyfit(time_acc,frac_corr_pleis_acc_76_hi,poly_order);
            fit_76_hi = polyval(fract_fit_76_hi,time);
            fract_fit_76_lo = polyfit(time_acc,frac_corr_pleis_acc_76_lo,poly_order);
            fit_76_lo = polyval(fract_fit_76_lo,time);

			fract_fit_75 = polyfit(time_acc,frac_corr_pleis_acc_75,poly_order);
            fit_75 = polyval(fract_fit_75,time);
            fract_fit_75_hi = polyfit(time_acc,frac_corr_pleis_acc_75_hi,poly_order);
            fit_75_hi = polyval(fract_fit_75_hi,time);
            fract_fit_75_lo = polyfit(time_acc,frac_corr_pleis_acc_75_lo,poly_order);
            fit_75_lo = polyval(fract_fit_75_lo,time);

			fract_fit_82 = polyfit(time_acc,frac_corr_pleis_acc_82,poly_order);
            fit_82 = polyval(fract_fit_82,time);
            fract_fit_82_hi = polyfit(time_acc,frac_corr_pleis_acc_82_hi,poly_order);
            fit_82_hi = polyval(fract_fit_82_hi,time);
            fract_fit_82_lo = polyfit(time_acc,frac_corr_pleis_acc_82_lo,poly_order);
            fit_82_lo = polyval(fract_fit_82_lo,time);

        case handles.radio_cubicspline 

			fract_fit_68 = splinefit(time_acc,frac_corr_pleis_acc_68,breaks);
            fit_68 = ppval(fract_fit_68,time);
            fract_fit_68_hi = splinefit(time_acc,frac_corr_pleis_acc_68_hi,breaks);
            fit_68_hi = ppval(fract_fit_68_hi,time);
            fract_fit_68_lo = splinefit(time_acc,frac_corr_pleis_acc_68_lo,breaks);
            fit_68_lo = ppval(fract_fit_68_lo,time);

			fract_fit_76 = splinefit(time_acc,frac_corr_pleis_acc_76,breaks);
            fit_76 = ppval(fract_fit_76,time);
            fract_fit_76_hi = splinefit(time_acc,frac_corr_pleis_acc_76_hi,breaks);
            fit_76_hi = ppval(fract_fit_76_hi,time);
            fract_fit_76_lo = splinefit(time_acc,frac_corr_pleis_acc_76_lo,breaks);
            fit_76_lo = ppval(fract_fit_76_lo,time);

			fract_fit_75 = splinefit(time_acc,frac_corr_pleis_acc_75,breaks);
            fit_75 = ppval(fract_fit_75,time);
            fract_fit_75_hi = splinefit(time_acc,frac_corr_pleis_acc_75_hi,breaks);
            fit_75_hi = ppval(fract_fit_75_hi,time);
            fract_fit_75_lo = splinefit(time_acc,frac_corr_pleis_acc_75_lo,breaks);
            fit_75_lo = ppval(fract_fit_75_lo,time);

			fract_fit_82 = splinefit(time_acc,frac_corr_pleis_acc_82,breaks);
            fit_82 = ppval(fract_fit_82,time);
            fract_fit_82_hi = splinefit(time_acc,frac_corr_pleis_acc_82_hi,breaks);
            fit_82_hi = ppval(fract_fit_82_hi,time);
            fract_fit_82_lo = splinefit(time_acc,frac_corr_pleis_acc_82_lo,breaks);
            fit_82_lo = ppval(fract_fit_82_lo,time);

        case handles.radio_smoothingspline   

			fract_fit_68 = fit(time_acc,frac_corr_pleis_acc_68, 'smoothingspline', 'SmoothingParam', pval);
			fit_68 = fract_fit_68(time);
            fract_fit_68_hi = fit(time_acc,frac_corr_pleis_acc_68_hi, 'smoothingspline', 'SmoothingParam', pval);
            fit_68_hi = fract_fit_68_hi(time);
            fract_fit_68_lo = fit(time_acc,frac_corr_pleis_acc_68_lo, 'smoothingspline', 'SmoothingParam', pval);
            fit_68_lo = fract_fit_68_lo(time);

			fract_fit_76 = fit(time_acc,frac_corr_pleis_acc_76, 'smoothingspline', 'SmoothingParam', pval);
			fit_76 = fract_fit_76(time);
            fract_fit_76_hi = fit(time_acc,frac_corr_pleis_acc_76_hi, 'smoothingspline', 'SmoothingParam', pval);
            fit_76_hi = fract_fit_76_hi(time);
            fract_fit_76_lo = fit(time_acc,frac_corr_pleis_acc_76_lo, 'smoothingspline', 'SmoothingParam', pval);
            fit_76_lo = fract_fit_76_lo(time);

			fract_fit_75 = fit(time_acc,frac_corr_pleis_acc_75, 'smoothingspline', 'SmoothingParam', pval);
			fit_75 = fract_fit_75(time);
            fract_fit_75_hi = fit(time_acc,frac_corr_pleis_acc_75_hi, 'smoothingspline', 'SmoothingParam', pval);
            fit_75_hi = fract_fit_75_hi(time);
            fract_fit_75_lo = fit(time_acc,frac_corr_pleis_acc_75_lo, 'smoothingspline', 'SmoothingParam', pval);
            fit_75_lo = fract_fit_75_lo(time);

			fract_fit_82 = fit(time_acc,frac_corr_pleis_acc_82, 'smoothingspline', 'SmoothingParam', pval);
			fit_82 = fract_fit_82(time);
            fract_fit_82_hi = fit(time_acc,frac_corr_pleis_acc_82_hi, 'smoothingspline', 'SmoothingParam', pval);
            fit_82_hi = fract_fit_82_hi(time);
            fract_fit_82_lo = fit(time_acc,frac_corr_pleis_acc_82_lo, 'smoothingspline', 'SmoothingParam', pval);
            fit_82_lo = fract_fit_82_lo(time);

 		end

%% CALCULATE FINAL BIAS-CORRECTED RATIOS %%%%%
bias_corr_pleis_Pb206_U238 = pleis.*fit_68.*corr_Pb206_U238;
bias_corr_samples_Pb206_U238 = samples.*corr_Pb206_U238.*fit_68;
bias_corr_fc5z_Pb206_U238 = fc5z.*corr_Pb206_U238.*fit_68;
bias_corr_All_Pb206_U238 = bias_corr_pleis_Pb206_U238 + bias_corr_samples_Pb206_U238 + bias_corr_fc5z_Pb206_U238;

bias_corr_pleis_Pb207_Pb206 = pleis.*fit_76.*corr_Pb207_Pb206;
bias_corr_samples_Pb207_Pb206 = samples.*corr_Pb207_Pb206.*fit_76;
bias_corr_fc5z_Pb207_Pb206 = fc5z.*corr_Pb207_Pb206.*fit_76;
bias_corr_All_Pb207_Pb206 = bias_corr_pleis_Pb207_Pb206 + bias_corr_samples_Pb207_Pb206 + bias_corr_fc5z_Pb207_Pb206;

bias_corr_pleis_Pb207_U235 = pleis.*fit_75.*corr_Pb207_U235;
bias_corr_samples_Pb207_U235 = samples.*corr_Pb207_U235.*fit_75;
bias_corr_fc5z_Pb207_U235 = fc5z.*corr_Pb207_U235.*fit_75;
bias_corr_All_Pb207_U235 = bias_corr_pleis_Pb207_U235 + bias_corr_samples_Pb207_U235 + bias_corr_fc5z_Pb207_U235;

bias_corr_pleis_Pb208_Th232 = pleis.*fit_82.*corr_Pb208_Th232;
bias_corr_samples_Pb208_Th232 = samples.*corr_Pb208_Th232.*fit_82;
bias_corr_fc5z_Pb208_Th232 = fc5z.*corr_Pb208_Th232.*fit_82;
bias_corr_All_Pb208_Th232 = bias_corr_pleis_Pb208_Th232 + bias_corr_samples_Pb208_Th232 + bias_corr_fc5z_Pb208_Th232;

%% filter out zero age, future ages, and Pb/Pb ages older than Earth %%
for i = 1:length(bias_corr_All_Pb206_U238)
if bias_corr_All_Pb206_U238(i,1) < 0
bias_corr_All_Pb206_U238(i,1) = 0.000000001;
end
end

for i = 1:length(bias_corr_All_Pb207_Pb206)
if bias_corr_All_Pb207_Pb206(i,1) < 0.04604552
bias_corr_All_Pb207_Pb206(i,1) = 0.04604552;
elseif bias_corr_All_Pb207_Pb206(i,1) > 13.5
bias_corr_All_Pb207_Pb206(i,1) = 13.5;
else
bias_corr_All_Pb207_Pb206(i,1) = bias_corr_All_Pb207_Pb206(i,1);
end
end

for i = 1:length(bias_corr_All_Pb207_U235)
if bias_corr_All_Pb207_U235(i,1) < 0
bias_corr_All_Pb207_U235(i,1) = 0.000000001;
end
end

for i = 1:length(bias_corr_All_Pb208_Th232)
if bias_corr_All_Pb208_Th232(i,1) < 0
bias_corr_All_Pb208_Th232(i,1) = 0.000000001;
end
end

%% PROPAGATE ERROR FROM SESSSION DRIFT OPTIONS %%
		rad_on_error=get(handles.uipanel_error_prop_type,'selectedobject');
%% OPTION #1: FITTED ENVELOPE APPROACH %%
		switch rad_on_error
        case handles.radio_errorprop_envelope 

pleis_fract_Pb206_U238_err = (sqrt((corr_Pb206_U238_err.*corr_Pb206_U238_err) + (pleis_Pb206_U238_known_err.*pleis_Pb206_U238_known_err)));
drift_err_68_env = ((fit_68_hi - fit_68)./fit_68).*100;
bias_corr_pleis_Pb206_U238_err = pleis.*(sqrt((drift_err_68_env.*drift_err_68_env)+(pleis_fract_Pb206_U238_err.*pleis_fract_Pb206_U238_err)));
bias_corr_fc5z_Pb206_U238_err = fc5z.*(sqrt((drift_err_68_env.*drift_err_68_env)+(pleis_fract_Pb206_U238_err.*pleis_fract_Pb206_U238_err)));
bias_corr_samples_Pb206_U238_err = samples.*(sqrt((drift_err_68_env.*drift_err_68_env)+(pleis_fract_Pb206_U238_err.*pleis_fract_Pb206_U238_err)));
bias_corr_All_Pb206_U238_err = bias_corr_pleis_Pb206_U238_err + bias_corr_fc5z_Pb206_U238_err + bias_corr_samples_Pb206_U238_err;

pleis_fract_Pb207_Pb206_err = (sqrt((corr_Pb207_Pb206_err.*corr_Pb207_Pb206_err) + (pleis_Pb207_Pb206_known_err.*pleis_Pb207_Pb206_known_err)));
drift_err_76_env = ((fit_76_hi - fit_76)./fit_76).*100;
bias_corr_pleis_Pb207_Pb206_err = pleis.*(sqrt((drift_err_76_env.*drift_err_76_env)+(pleis_fract_Pb207_Pb206_err.*pleis_fract_Pb207_Pb206_err)));
bias_corr_fc5z_Pb207_Pb206_err = fc5z.*(sqrt((drift_err_76_env.*drift_err_76_env)+(pleis_fract_Pb207_Pb206_err.*pleis_fract_Pb207_Pb206_err)));
bias_corr_samples_Pb207_Pb206_err = samples.*(sqrt((drift_err_76_env.*drift_err_76_env)+(pleis_fract_Pb207_Pb206_err.*pleis_fract_Pb207_Pb206_err)));
bias_corr_All_Pb207_Pb206_err = bias_corr_pleis_Pb207_Pb206_err + bias_corr_fc5z_Pb207_Pb206_err + bias_corr_samples_Pb207_Pb206_err;

pleis_fract_Pb207_U235_err = (sqrt((corr_Pb207_U235_err.*corr_Pb207_U235_err) + (pleis_Pb207_U235_known_err.*pleis_Pb207_U235_known_err)));
drift_err_75_env = ((fit_75_hi - fit_75)./fit_75).*100;
bias_corr_pleis_Pb207_U235_err = pleis.*(sqrt((drift_err_75_env.*drift_err_75_env)+(pleis_fract_Pb207_U235_err.*pleis_fract_Pb207_U235_err)));
bias_corr_fc5z_Pb207_U235_err = fc5z.*(sqrt((drift_err_75_env.*drift_err_75_env)+(pleis_fract_Pb207_U235_err.*pleis_fract_Pb207_U235_err)));
bias_corr_samples_Pb207_U235_err = samples.*(sqrt((drift_err_75_env.*drift_err_75_env)+(pleis_fract_Pb207_U235_err.*pleis_fract_Pb207_U235_err)));
bias_corr_All_Pb207_U235_err = bias_corr_pleis_Pb207_U235_err + bias_corr_fc5z_Pb207_U235_err + bias_corr_samples_Pb207_U235_err;

pleis_fract_Pb208_Th232_err = (sqrt((corr_Pb208_Th232_err.*corr_Pb208_Th232_err) + (pleis_Pb208_Th232_known_err.*pleis_Pb208_Th232_known_err)));
drift_err_82_env = ((fit_82_hi - fit_82)./fit_82).*100;
bias_corr_pleis_Pb208_Th232_err = pleis.*(sqrt((drift_err_82_env.*drift_err_82_env)+(pleis_fract_Pb208_Th232_err.*pleis_fract_Pb208_Th232_err)));
bias_corr_fc5z_Pb208_Th232_err = fc5z.*(sqrt((drift_err_82_env.*drift_err_82_env)+(pleis_fract_Pb208_Th232_err.*pleis_fract_Pb208_Th232_err)));
bias_corr_samples_Pb208_Th232_err = samples.*(sqrt((drift_err_82_env.*drift_err_82_env)+(pleis_fract_Pb208_Th232_err.*pleis_fract_Pb208_Th232_err)));
bias_corr_All_Pb208_Th232_err = bias_corr_pleis_Pb208_Th232_err + bias_corr_fc5z_Pb208_Th232_err + bias_corr_samples_Pb208_Th232_err;

%% OPTION #2: SLIDING WINDOW APPROACH %%
        case handles.radio_errorprop_sliding  

			rad_on_outliers=get(handles.uipanel_outliers,'selectedobject');
			switch rad_on_outliers
			case handles.radio_none

			for i = 1:length(frac_corr_pleis_Pb206_U238)
			bias_avg_Pb206_U238(i,1) = frac_corr_pleis_Pb206_U238(i,1);
			bias_avg_Pb207_Pb206(i,1) = frac_corr_pleis_Pb207_Pb206(i,1);
			bias_avg_Pb207_U235(i,1) = frac_corr_pleis_Pb207_U235(i,1);
			bias_avg_Pb208_Th232(i,1) = frac_corr_pleis_Pb208_Th232(i,1);
			end

			case {handles.radio_reject_poly, handles.radio_reject_spline}
			
for i = 1:length(frac_corr_pleis_Pb206_U238)
if frac_corr_pleis_Pb206_U238(i,1) > 0 && frac_corr_pleis_Pb206_U238(i,1) > model_68_hi(i,1)
bias_avg_Pb206_U238(i,1) = 0;
bias_avg_Pb207_Pb206(i,1) = 0;
bias_avg_Pb207_U235(i,1) = 0;
bias_avg_Pb208_Th232(i,1) = 0;
elseif frac_corr_pleis_Pb206_U238(i,1) > 0 && frac_corr_pleis_Pb206_U238(i,1) < model_68_lo(i,1)
bias_avg_Pb206_U238(i,1) = 0;
bias_avg_Pb207_Pb206(i,1) = 0;
bias_avg_Pb207_U235(i,1) = 0;
bias_avg_Pb208_Th232(i,1) = 0;
elseif frac_corr_pleis_Pb207_Pb206(i,1) > 0 && frac_corr_pleis_Pb207_Pb206(i,1) > model_76_hi(i,1)
bias_avg_Pb206_U238(i,1) = 0;
bias_avg_Pb207_Pb206(i,1) = 0;
bias_avg_Pb207_U235(i,1) = 0;
bias_avg_Pb208_Th232(i,1) = 0;
elseif frac_corr_pleis_Pb207_Pb206(i,1) > 0 && frac_corr_pleis_Pb207_Pb206(i,1) < model_76_lo(i,1)
bias_avg_Pb206_U238(i,1) = 0;
bias_avg_Pb207_Pb206(i,1) = 0;
bias_avg_Pb207_U235(i,1) = 0;
bias_avg_Pb208_Th232(i,1) = 0;
elseif frac_corr_pleis_Pb207_U235(i,1) > 0 && frac_corr_pleis_Pb207_U235(i,1) > model_75_hi(i,1)
bias_avg_Pb206_U238(i,1) = 0;
bias_avg_Pb207_Pb206(i,1) = 0;
bias_avg_Pb207_U235(i,1) = 0;
bias_avg_Pb208_Th232(i,1) = 0;
elseif frac_corr_pleis_Pb207_U235(i,1) > 0 && frac_corr_pleis_Pb207_U235(i,1) < model_75_lo(i,1)
bias_avg_Pb206_U238(i,1) = 0;
bias_avg_Pb207_Pb206(i,1) = 0;
bias_avg_Pb207_U235(i,1) = 0;
bias_avg_Pb208_Th232(i,1) = 0;
elseif frac_corr_pleis_Pb208_Th232(i,1) > 0 && frac_corr_pleis_Pb208_Th232(i,1) > model_82_hi(i,1)
bias_avg_Pb206_U238(i,1) = 0;
bias_avg_Pb207_Pb206(i,1) = 0;
bias_avg_Pb207_U235(i,1) = 0;
bias_avg_Pb208_Th232(i,1) = 0;
elseif frac_corr_pleis_Pb208_Th232(i,1) > 0 && frac_corr_pleis_Pb208_Th232(i,1) < model_82_lo(i,1)
bias_avg_Pb206_U238(i,1) = 0;
bias_avg_Pb207_Pb206(i,1) = 0;
bias_avg_Pb207_U235(i,1) = 0;
bias_avg_Pb208_Th232(i,1) = 0;
else
bias_avg_Pb206_U238(i,1) = frac_corr_pleis_Pb206_U238(i,1);
bias_avg_Pb207_Pb206(i,1) = frac_corr_pleis_Pb207_Pb206(i,1);
bias_avg_Pb207_U235(i,1) = frac_corr_pleis_Pb207_U235(i,1);
bias_avg_Pb208_Th232(i,1) = frac_corr_pleis_Pb208_Th232(i,1);
end
end
			end
%%%%% implement sliding window (window size is 50 rows) Pb206/U238 %%%%%
bias_avg_Pb206_U238(16:length(pleis)+15,1) = bias_avg_Pb206_U238;
bias_avg_Pb206_U238(1:15,1) = 0;
bias_avg_Pb206_U238(length(bias_avg_Pb206_U238)+1:length(bias_avg_Pb206_U238)+35,1) = 0;

for i = 1:length(pleis)
corr_shift_Pb206_U238(i,1) = mean(nonzeros(bias_avg_Pb206_U238(i:i+50,1)));
end
for i = 1:length(pleis)
corr_shift_Pb206_U238_std(i,1) = std(nonzeros(bias_avg_Pb206_U238(i:i+50,1)));
end
for i = 1:length(pleis)
corr_shift_Pb206_U238_std1(i,1) = std(nonzeros(bias_avg_Pb206_U238(i:i+50,1)),1);
end

for i = 1:length(pleis)
corr_shift_Pb206_U238_c = bias_avg_Pb206_U238./bias_avg_Pb206_U238;
corr_shift_Pb206_U238_c(~isfinite(corr_shift_Pb206_U238_c))=0;
corr_shift_Pb206_U238_count(i,1) = sum(nonzeros(corr_shift_Pb206_U238_c(i:i+50,1)));
end

pleis_fract_Pb206_U238_err = (sqrt((corr_Pb206_U238_err.*corr_Pb206_U238_err) ... 
	+ (pleis_Pb206_U238_known_err.*pleis_Pb206_U238_known_err)));

drift_err_68_win = sqrt( ... 
	+ ((200.*corr_shift_Pb206_U238_std1./corr_shift_Pb206_U238) ...
	.*(200.*corr_shift_Pb206_U238_std1./corr_shift_Pb206_U238)));

bias_corr_pleis_Pb206_U238_err = pleis.*(sqrt((pleis_fract_Pb206_U238_err.*pleis_fract_Pb206_U238_err) ... 
	+ ((200.*corr_shift_Pb206_U238_std1./corr_shift_Pb206_U238) ...
	.*(200.*corr_shift_Pb206_U238_std1./corr_shift_Pb206_U238))));

bias_corr_samples_Pb206_U238_err = samples.*(sqrt( ...
(((200.*corr_shift_Pb206_U238_std./sqrt(corr_shift_Pb206_U238_count))./corr_shift_Pb206_U238).* ...
((200.*corr_shift_Pb206_U238_std./sqrt(corr_shift_Pb206_U238_count))./corr_shift_Pb206_U238)) + ...
(corr_Pb206_U238_err.*corr_Pb206_U238_err)));

bias_corr_fc5z_Pb206_U238_err = fc5z.*(sqrt( ...
(((200.*corr_shift_Pb206_U238_std./sqrt(corr_shift_Pb206_U238_count))./corr_shift_Pb206_U238).* ...
((200.*corr_shift_Pb206_U238_std./sqrt(corr_shift_Pb206_U238_count))./corr_shift_Pb206_U238)) + ...
(corr_Pb206_U238_err.*corr_Pb206_U238_err)));

bias_corr_All_Pb206_U238_err = bias_corr_pleis_Pb206_U238_err + bias_corr_samples_Pb206_U238_err ...
	+ bias_corr_fc5z_Pb206_U238_err;

%%%%% implement sliding window (window size is 50 rows) Pb207/Pb206 %%%%%
bias_avg_Pb207_Pb206(16:length(pleis)+15,1) = bias_avg_Pb207_Pb206;
bias_avg_Pb207_Pb206(1:15,1) = 0;
bias_avg_Pb207_Pb206(length(bias_avg_Pb207_Pb206)+1:length(bias_avg_Pb207_Pb206)+35,1) = 0;

for i = 1:length(pleis)
corr_shift_Pb207_Pb206(i,1) = mean(nonzeros(bias_avg_Pb207_Pb206(i:i+50,1)));
end
for i = 1:length(pleis)
corr_shift_Pb207_Pb206_std(i,1) = std(nonzeros(bias_avg_Pb207_Pb206(i:i+50,1)));
end
for i = 1:length(pleis)
corr_shift_Pb207_Pb206_std1(i,1) = std(nonzeros(bias_avg_Pb207_Pb206(i:i+50,1)),1);
end

for i = 1:length(pleis)
corr_shift_Pb207_Pb206_c = bias_avg_Pb207_Pb206./bias_avg_Pb207_Pb206;
corr_shift_Pb207_Pb206_c(~isfinite(corr_shift_Pb207_Pb206_c))=0;
corr_shift_Pb207_Pb206_count(i,1) = sum(nonzeros(corr_shift_Pb207_Pb206_c(i:i+50,1)));
end

pleis_fract_Pb207_Pb206_err = (sqrt((corr_Pb207_Pb206_err.*corr_Pb207_Pb206_err) ... 
	+ (pleis_Pb207_Pb206_known_err.*pleis_Pb207_Pb206_known_err)));

drift_err_76_win = sqrt( ... 
	+ ((200.*corr_shift_Pb207_Pb206_std1./corr_shift_Pb207_Pb206) ...
	.*(200.*corr_shift_Pb207_Pb206_std1./corr_shift_Pb207_Pb206)));

bias_corr_pleis_Pb207_Pb206_err = pleis.*(sqrt((pleis_fract_Pb207_Pb206_err.*pleis_fract_Pb207_Pb206_err) ... 
	+ ((200.*corr_shift_Pb207_Pb206_std1./corr_shift_Pb207_Pb206) ...
	.*(200.*corr_shift_Pb207_Pb206_std1./corr_shift_Pb207_Pb206))));

bias_corr_samples_Pb207_Pb206_err = samples.*(sqrt( ...
(((200.*corr_shift_Pb207_Pb206_std./sqrt(corr_shift_Pb207_Pb206_count))./corr_shift_Pb207_Pb206).* ...
((200.*corr_shift_Pb207_Pb206_std./sqrt(corr_shift_Pb207_Pb206_count))./corr_shift_Pb207_Pb206)) + ...
(corr_Pb207_Pb206_err.*corr_Pb207_Pb206_err)));

bias_corr_fc5z_Pb207_Pb206_err = fc5z.*(sqrt( ...
(((200.*corr_shift_Pb207_Pb206_std./sqrt(corr_shift_Pb207_Pb206_count))./corr_shift_Pb207_Pb206).* ...
((200.*corr_shift_Pb207_Pb206_std./sqrt(corr_shift_Pb207_Pb206_count))./corr_shift_Pb207_Pb206)) + ...
(corr_Pb207_Pb206_err.*corr_Pb207_Pb206_err)));

bias_corr_All_Pb207_Pb206_err = bias_corr_pleis_Pb207_Pb206_err + bias_corr_samples_Pb207_Pb206_err ...
	+ bias_corr_fc5z_Pb207_Pb206_err;

%%%%% implement sliding window (window size is 50 rows) Pb207/U235 %%%%%
bias_avg_Pb207_U235(16:length(pleis)+15,1) = bias_avg_Pb207_U235;
bias_avg_Pb207_U235(1:15,1) = 0;
bias_avg_Pb207_U235(length(bias_avg_Pb207_U235)+1:length(bias_avg_Pb207_U235)+35,1) = 0;

for i = 1:length(pleis)
corr_shift_Pb207_U235(i,1) = mean(nonzeros(bias_avg_Pb207_U235(i:i+50,1)));
end
for i = 1:length(pleis)
corr_shift_Pb207_U235_std(i,1) = std(nonzeros(bias_avg_Pb207_U235(i:i+50,1)));
end
for i = 1:length(pleis)
corr_shift_Pb207_U235_std1(i,1) = std(nonzeros(bias_avg_Pb207_U235(i:i+50,1)),1);
end

for i = 1:length(pleis)
corr_shift_Pb207_U235_c = bias_avg_Pb207_U235./bias_avg_Pb207_U235;
corr_shift_Pb207_U235_c(~isfinite(corr_shift_Pb207_U235_c))=0;
corr_shift_Pb207_U235_count(i,1) = sum(nonzeros(corr_shift_Pb207_U235_c(i:i+50,1)));
end

pleis_fract_Pb207_U235_err = (sqrt((corr_Pb207_U235_err.*corr_Pb207_U235_err) ... 
	+ (pleis_Pb207_U235_known_err.*pleis_Pb207_U235_known_err)));

drift_err_75_win = sqrt( ... 
	+ ((200.*corr_shift_Pb207_U235_std1./corr_shift_Pb207_U235) ...
	.*(200.*corr_shift_Pb207_U235_std1./corr_shift_Pb207_U235)));

bias_corr_pleis_Pb207_U235_err = pleis.*(sqrt((pleis_fract_Pb207_U235_err.*pleis_fract_Pb207_U235_err) ... 
	+ ((200.*corr_shift_Pb207_U235_std1./corr_shift_Pb207_U235) ...
	.*(200.*corr_shift_Pb207_U235_std1./corr_shift_Pb207_U235))));

bias_corr_samples_Pb207_U235_err = samples.*(sqrt( ...
(((200.*corr_shift_Pb207_U235_std./sqrt(corr_shift_Pb207_U235_count))./corr_shift_Pb207_U235).* ...
((200.*corr_shift_Pb207_U235_std./sqrt(corr_shift_Pb207_U235_count))./corr_shift_Pb207_U235)) + ...
(corr_Pb207_U235_err.*corr_Pb207_U235_err)));

bias_corr_fc5z_Pb207_U235_err = fc5z.*(sqrt( ...
(((200.*corr_shift_Pb207_U235_std./sqrt(corr_shift_Pb207_U235_count))./corr_shift_Pb207_U235).* ...
((200.*corr_shift_Pb207_U235_std./sqrt(corr_shift_Pb207_U235_count))./corr_shift_Pb207_U235)) + ...
(corr_Pb207_U235_err.*corr_Pb207_U235_err)));

bias_corr_All_Pb207_U235_err = bias_corr_pleis_Pb207_U235_err + bias_corr_samples_Pb207_U235_err ...
	+ bias_corr_fc5z_Pb207_U235_err;

%%%%% implement sliding window (window size is 50 rows) Pb208/Th232 %%%%%
bias_avg_Pb208_Th232(16:length(pleis)+15,1) = bias_avg_Pb208_Th232;
bias_avg_Pb208_Th232(1:15,1) = 0;
bias_avg_Pb208_Th232(length(bias_avg_Pb208_Th232)+1:length(bias_avg_Pb208_Th232)+35,1) = 0;

for i = 1:length(pleis)
corr_shift_Pb208_Th232(i,1) = mean(nonzeros(bias_avg_Pb208_Th232(i:i+50,1)));
end
for i = 1:length(pleis)
corr_shift_Pb208_Th232_std(i,1) = std(nonzeros(bias_avg_Pb208_Th232(i:i+50,1)));
end
for i = 1:length(pleis)
corr_shift_Pb208_Th232_std1(i,1) = std(nonzeros(bias_avg_Pb208_Th232(i:i+50,1)),1);
end

for i = 1:length(pleis)
corr_shift_Pb208_Th232_c = bias_avg_Pb208_Th232./bias_avg_Pb208_Th232;
corr_shift_Pb208_Th232_c(~isfinite(corr_shift_Pb208_Th232_c))=0;
corr_shift_Pb208_Th232_count(i,1) = sum(nonzeros(corr_shift_Pb208_Th232_c(i:i+50,1)));
end

pleis_fract_Pb208_Th232_err = (sqrt((corr_Pb208_Th232_err.*corr_Pb208_Th232_err) ... 
	+ (pleis_Pb208_Th232_known_err.*pleis_Pb208_Th232_known_err)));

drift_err_82_win = sqrt( ... 
	+ ((200.*corr_shift_Pb208_Th232_std1./corr_shift_Pb208_Th232) ...
	.*(200.*corr_shift_Pb208_Th232_std1./corr_shift_Pb208_Th232)));

bias_corr_pleis_Pb208_Th232_err = pleis.*(sqrt((pleis_fract_Pb208_Th232_err.*pleis_fract_Pb208_Th232_err) ... 
	+ ((200.*corr_shift_Pb208_Th232_std1./corr_shift_Pb208_Th232) ...
	.*(200.*corr_shift_Pb208_Th232_std1./corr_shift_Pb208_Th232))));

bias_corr_samples_Pb208_Th232_err = samples.*(sqrt( ...
(((200.*corr_shift_Pb208_Th232_std./sqrt(corr_shift_Pb208_Th232_count))./corr_shift_Pb208_Th232).* ...
((200.*corr_shift_Pb208_Th232_std./sqrt(corr_shift_Pb208_Th232_count))./corr_shift_Pb208_Th232)) + ...
(corr_Pb208_Th232_err.*corr_Pb208_Th232_err)));

bias_corr_fc5z_Pb208_Th232_err = fc5z.*(sqrt( ...
(((200.*corr_shift_Pb208_Th232_std./sqrt(corr_shift_Pb208_Th232_count))./corr_shift_Pb208_Th232).* ...
((200.*corr_shift_Pb208_Th232_std./sqrt(corr_shift_Pb208_Th232_count))./corr_shift_Pb208_Th232)) + ...
(corr_Pb208_Th232_err.*corr_Pb208_Th232_err)));

bias_corr_All_Pb208_Th232_err = bias_corr_pleis_Pb208_Th232_err + bias_corr_samples_Pb208_Th232_err ...
	+ bias_corr_fc5z_Pb208_Th232_err;

		end

Pb206_U238 = bias_corr_samples_Pb206_U238 + bias_corr_pleis_Pb206_U238 + bias_corr_fc5z_Pb206_U238;
Pb207_Pb206 = bias_corr_samples_Pb207_Pb206 + bias_corr_pleis_Pb207_Pb206 + bias_corr_fc5z_Pb207_Pb206;
Pb207_U235 = bias_corr_samples_Pb207_U235 + bias_corr_pleis_Pb207_U235 + bias_corr_fc5z_Pb207_U235;
Pb208_Th232 = bias_corr_samples_Pb208_Th232 + bias_corr_pleis_Pb208_Th232 + bias_corr_fc5z_Pb208_Th232;

Pb206_U238_err = bias_corr_samples_Pb206_U238_err + bias_corr_pleis_Pb206_U238_err + bias_corr_fc5z_Pb206_U238_err;
Pb207_Pb206_err = bias_corr_samples_Pb207_Pb206_err + bias_corr_pleis_Pb207_Pb206_err + bias_corr_fc5z_Pb207_Pb206_err;
Pb207_U235_err = bias_corr_samples_Pb207_U235_err + bias_corr_pleis_Pb207_U235_err + bias_corr_fc5z_Pb207_U235_err;
Pb208_Th232_err = bias_corr_samples_Pb208_Th232_err + bias_corr_pleis_Pb208_Th232_err + bias_corr_fc5z_Pb208_Th232_err;

%% PLOT DEFAULT Pb206/U238 DRIFT CORRECTION %%%%%
%			rad_on_error=get(handles.uipanel_error_prop_type,'selectedobject');
%			switch rad_on_error
%			case handles.radio_errorprop_envelope
%			if exist('drift_err_68_env','var') == 0
%			err_dlg=errordlg('Data was reduced using a sliding window. You will need to re-reduce data set with fitted envelope error propagation','Hang on a sec...');
%			waitfor(err_dlg);
%			else
%			end
%			case handles.radio_errorprop_sliding
%			if exist('drift_err_68_win','var') == 0
%			err_dlg=errordlg('Data was reduced using a sliding window. You will need to re-reduce data set with sliding window error propagation','Wait!');
%			waitfor(err_dlg);
%			else
%			drift_err_68_win=handles.drift_err_68_win;
%			end
%			end
			
		rad_on=get(handles.uipanel_plot_type,'selectedobject');
        switch rad_on
        case handles.radio_measured_ratios

		frac_corr_pleis_Pb206_U238_nz_meas = nonzeros(pleis.*corr_Pb206_U238); %measured ratios
		fract_pleis_68_hi_meas = frac_corr_pleis_Pb206_U238_nz_meas + (frac_corr_pleis_Pb206_U238_nz_meas.*(frac_corr_pleis_Pb206_U238_nz_err.*0.01));
		fract_pleis_68_lo_meas = frac_corr_pleis_Pb206_U238_nz_meas - (frac_corr_pleis_Pb206_U238_nz_meas.*(frac_corr_pleis_Pb206_U238_nz_err.*0.01));
		frac_corr_pleis_rej_68_meas = pleis_Pb206_U238_known./frac_corr_pleis_rej_68; %measured ratios
		fit_68_meas = pleis_Pb206_U238_known./fit_68;
		fit_68_hi_meas = pleis_Pb206_U238_known./fit_68_hi;
		fit_68_lo_meas = pleis_Pb206_U238_known./fit_68_lo;

			rad_on_outliers=get(handles.uipanel_outliers,'selectedobject');
			switch rad_on_outliers
			case handles.radio_none
			case handles.radio_reject_poly

			model_68_pleis_meas = polyfit(pleis_time,pleis_Pb206_U238_known./frac_corr_pleis_Pb206_U238_nz,reject_poly_order);
			model_68_meas = polyval(model_68_pleis_meas,time);
			model_68_hi_meas = model_68_meas + model_68_meas.*outlier_cutoff_68.*.01;
			model_68_lo_meas = model_68_meas - model_68_meas.*outlier_cutoff_68.*.01;

		    case handles.radio_reject_spline

			model_68_pleis_meas = splinefit(pleis_time,pleis_Pb206_U238_known./frac_corr_pleis_Pb206_U238_nz,reject_spline_breaks);
			model_68_meas = ppval(model_68_pleis_meas,time);
			model_68_hi_meas = model_68_meas + model_68_meas.*outlier_cutoff_68.*.01;
			model_68_lo_meas = model_68_meas - model_68_meas.*outlier_cutoff_68.*.01;

			end

		axes(handles.axes_bias);
			
			rad_on_error=get(handles.uipanel_error_prop_type,'selectedobject');
			switch rad_on_error
			case handles.radio_errorprop_envelope
			if exist('drift_err_68_env','var')
			f=vertcat(fit_68_lo_meas,flipud(fit_68_hi_meas));
			fill(vertcat(time, flipud(time)),vertcat(fit_68_lo_meas,flipud(fit_68_hi_meas)), 'b','FaceAlpha',.3,'EdgeAlpha',.3)
			end
			case handles.radio_errorprop_sliding
			if exist('drift_err_68_win','var')
			f=vertcat(fit_68_meas-(drift_err_68_win.*0.01.*fit_68_meas),flipud(fit_68_meas+(drift_err_68_win.*0.01.*fit_68_meas)));
			fill(vertcat(time, flipud(time)),vertcat(fit_68_meas-(drift_err_68_win.*0.01.*fit_68_meas),flipud(fit_68_meas+(drift_err_68_win.*0.01.*fit_68_meas))), 'b','FaceAlpha',.3,'EdgeAlpha',.3)
			end
			end
		
		hold on
		plot(time,fit_68_meas, 'r','LineWidth',2)
		e68=errorbar(pleis_time,frac_corr_pleis_Pb206_U238_nz_meas,(frac_corr_pleis_Pb206_U238_nz_meas.*(frac_corr_pleis_Pb206_U238_nz_err.*0.01)),'o','MarkerSize',...
		5,'MarkerEdgeColor','k','MarkerFaceColor', 'k');
		scatter(time_rej, frac_corr_pleis_rej_68_meas, 100, 'r', 'filled')

			rad_on_outliers=get(handles.uipanel_outliers,'selectedobject');
			switch rad_on_outliers
			case handles.radio_none

			max_all_68_meas = max(vertcat(fit_68_hi_meas,frac_corr_pleis_Pb206_U238_nz_meas, fit_68_meas, fract_pleis_68_hi_meas, f));
			min_all_68_meas = min(vertcat(fit_68_lo_meas, frac_corr_pleis_Pb206_U238_nz_meas, fit_68_meas, fract_pleis_68_lo_meas, f));
			axis([min(time) max(time) min_all_68_meas max_all_68_meas]);

			case handles.radio_reject_poly

			plot(time, model_68_hi_meas, 'r')
			plot(time, model_68_lo_meas, 'r')
			max_all_68_meas = max(vertcat(fit_68_hi_meas,frac_corr_pleis_Pb206_U238_nz_meas, fit_68_meas, model_68_hi_meas, fract_pleis_68_hi_meas, f));
			min_all_68_meas = min(vertcat(fit_68_lo_meas, frac_corr_pleis_Pb206_U238_nz_meas, fit_68_meas, model_68_lo_meas, fract_pleis_68_lo_meas, f));
			axis([min(time) max(time) min_all_68_meas max_all_68_meas]);

		    case handles.radio_reject_spline

			plot(time, model_68_hi_meas, 'r')
			plot(time, model_68_lo_meas, 'r')
			max_all_68_meas = max(vertcat(fit_68_hi_meas,frac_corr_pleis_Pb206_U238_nz_meas, fit_68_meas, model_68_hi_meas, fract_pleis_68_hi_meas, f));
			min_all_68_meas = min(vertcat(fit_68_lo_meas, frac_corr_pleis_Pb206_U238_nz_meas, fit_68_meas, model_68_lo_meas, fract_pleis_68_lo_meas, f));
			axis([min(time) max(time) min_all_68_meas max_all_68_meas]);

			end
		
		hold off
		title('Pb206/U238 Session drift')
		xlabel('Decimal time')
		ylabel('Measured Pb206/U238')

		case handles.radio_fract_factor

		axes(handles.axes_bias);

			rad_on_error=get(handles.uipanel_error_prop_type,'selectedobject');
			switch rad_on_error
			case handles.radio_errorprop_envelope
			f=vertcat(fit_68_lo,flipud(fit_68_hi));
			fill(vertcat(time, flipud(time)),vertcat(fit_68_lo,flipud(fit_68_hi)), 'b','FaceAlpha',.3,'EdgeAlpha',.3)
			case handles.radio_errorprop_sliding
			f=vertcat(fit_68-(drift_err_68_win.*0.01.*fit_68),flipud(fit_68+(drift_err_68_win.*0.01.*fit_68)));
			fill(vertcat(time, flipud(time)),vertcat(fit_68-(drift_err_68_win.*0.01.*fit_68),flipud(fit_68+(drift_err_68_win.*0.01.*fit_68))), 'b','FaceAlpha',.3,'EdgeAlpha',.3)
			end

		hold on
		plot(time,fit_68, 'r','LineWidth',2)
		e68=errorbar(pleis_time,frac_corr_pleis_Pb206_U238_nz,(frac_corr_pleis_Pb206_U238_nz.*(frac_corr_pleis_Pb206_U238_nz_err.*0.01)),'o','MarkerSize',...
		5,'MarkerEdgeColor','k','MarkerFaceColor', 'k');

			rad_on_outliers=get(handles.uipanel_outliers,'selectedobject');
			switch rad_on_outliers
			case handles.radio_none

		max_all_68 = max(vertcat(fit_68_hi,frac_corr_pleis_Pb206_U238_nz, fit_68, fract_pleis_68_hi, f));
		min_all_68 = min(vertcat(fit_68_lo,frac_corr_pleis_Pb206_U238_nz, fit_68, fract_pleis_68_lo, f));
		axis([min(time) max(time) min(min_all_68) max(max_all_68)]);

			case {handles.radio_reject_poly, handles.radio_reject_spline}

		plot(time, model_68_hi, 'r')
		plot(time, model_68_lo, 'r')
		max_all_68 = max(vertcat(fit_68_hi,frac_corr_pleis_Pb206_U238_nz, fit_68, model_68_hi, fract_pleis_68_hi, f));
		min_all_68 = min(vertcat(fit_68_lo,frac_corr_pleis_Pb206_U238_nz, fit_68, model_68_lo, fract_pleis_68_lo, f));
		axis([min(time) max(time) min(min_all_68) max(max_all_68)]);

			end

		scatter(time_rej, frac_corr_pleis_rej_68, 100, 'r', 'filled')
		hold off
		title('Pb206/U238 Session drift')
		xlabel('Decimal time')
		ylabel('Pb206/U238 fractionation factor')
		end

%% CALCULATE RHO AND REPLACE 'BAD' (<0 OR >1) CORRELATION COEFFICIENT (RHO) %%%%%

rho_fix = replace_bad_rho;

rhoA =((bias_corr_All_Pb206_U238_err.*bias_corr_All_Pb206_U238_err) + ...
	(bias_corr_All_Pb207_U235_err.*bias_corr_All_Pb207_U235_err)) - ...
	(bias_corr_All_Pb207_Pb206_err.*bias_corr_All_Pb207_Pb206_err);
rhoB =2.*(bias_corr_All_Pb206_U238_err.*bias_corr_All_Pb207_U235_err);
rho = rhoA./rhoB;

rho_hi = rho > 1;
rho_lo = rho < 0;
rho_bad = sum(rho_hi) + sum(rho_lo);

for i = 1:length(rho)
if rho(i,:) < 0
	rho_corr(i,:) = replace_bad_rho;
elseif rho(i,:) > 1
	rho_corr(i,:) = replace_bad_rho;
else
	rho_corr(i,:) = rho(i,:);
end
end

set(handles.replaced_rho,'String',rho_bad);

pleis_rho = nonzeros(pleis.*rho);
fc5z_rho = nonzeros(fc5z.*rho);
samples_rho = nonzeros(samples.*rho);

pleis_data = [nonzeros(bias_corr_pleis_Pb207_Pb206),nonzeros(bias_corr_pleis_Pb207_Pb206_err), ...
	nonzeros(bias_corr_pleis_Pb207_U235),nonzeros(bias_corr_pleis_Pb207_U235_err),...
	nonzeros(bias_corr_pleis_Pb206_U238),nonzeros(bias_corr_pleis_Pb206_U238_err)];

center=[pleis_data(:,3),pleis_data(:,5)];

sigx_abs = pleis_data(:,3).*pleis_data(:,4).*0.01;
sigy_abs = pleis_data(:,5).*pleis_data(:,6).*0.01;

sigx_sq = sigx_abs.*sigx_abs;
sigy_sq = sigy_abs.*sigy_abs;
rho_sigx_sigy = sigx_abs.*sigy_abs.*pleis_rho;
sigmarule=1.25;
numpoints=50;

frac_corr_pleis_acc = abs(frac_corr_pleis_rej - 1);

pleis_rho_acc = nonzeros(frac_corr_pleis_acc.*pleis_rho);
pleis_data_acc = ([frac_corr_pleis_acc.*nonzeros(bias_corr_pleis_Pb207_Pb206),frac_corr_pleis_acc.*nonzeros(bias_corr_pleis_Pb207_Pb206_err), ...
	frac_corr_pleis_acc.*nonzeros(bias_corr_pleis_Pb207_U235),frac_corr_pleis_acc.*nonzeros(bias_corr_pleis_Pb207_U235_err),...
	frac_corr_pleis_acc.*nonzeros(bias_corr_pleis_Pb206_U238),frac_corr_pleis_acc.*nonzeros(bias_corr_pleis_Pb206_U238_err)]);
pleis_data_acc( ~any(pleis_data_acc,2), : ) = [];
center_acc=[frac_corr_pleis_acc.*pleis_data(:,3),frac_corr_pleis_acc.*pleis_data(:,5)];
center_acc( ~any(center_acc,2), : ) = [];
sigx_abs_acc = nonzeros(frac_corr_pleis_acc.*sigx_abs);
sigy_abs_acc = nonzeros(frac_corr_pleis_acc.*sigy_abs);
sigx_sq_acc = nonzeros(frac_corr_pleis_acc.*sigx_sq);
sigy_sq_acc = nonzeros(frac_corr_pleis_acc.*sigy_sq);
rho_sigx_sigy_acc = nonzeros(frac_corr_pleis_acc.*rho_sigx_sigy);

pleis_rho_rej = nonzeros(frac_corr_pleis_rej.*pleis_rho);
pleis_data_rej = ([frac_corr_pleis_rej.*nonzeros(bias_corr_pleis_Pb207_Pb206),frac_corr_pleis_rej.*nonzeros(bias_corr_pleis_Pb207_Pb206_err), ...
	frac_corr_pleis_rej.*nonzeros(bias_corr_pleis_Pb207_U235),frac_corr_pleis_rej.*nonzeros(bias_corr_pleis_Pb207_U235_err),...
	frac_corr_pleis_rej.*nonzeros(bias_corr_pleis_Pb206_U238),frac_corr_pleis_rej.*nonzeros(bias_corr_pleis_Pb206_U238_err)]);
pleis_data_rej( ~any(pleis_data_rej,2), : ) = [];
center_rej=[frac_corr_pleis_rej.*pleis_data(:,3),frac_corr_pleis_rej.*pleis_data(:,5)];
center_rej( ~any(center_rej,2), : ) = [];
sigx_abs_rej = nonzeros(frac_corr_pleis_rej.*sigx_abs);
sigy_abs_rej = nonzeros(frac_corr_pleis_rej.*sigy_abs);
sigx_sq_rej = nonzeros(frac_corr_pleis_rej.*sigx_sq);
sigy_sq_rej = nonzeros(frac_corr_pleis_rej.*sigy_sq);
rho_sigx_sigy_rej = nonzeros(frac_corr_pleis_rej.*rho_sigx_sigy);

%% FILTERS TO AVOID TAKING LOG OF NEGATIVE NUMBERS %%
tmp_Pb206_U238_age = 1+bias_corr_All_Pb206_U238;
tmp_Pb206_U238_err = 1+bias_corr_All_Pb206_U238 - (bias_corr_All_Pb206_U238_err/100.*bias_corr_All_Pb206_U238);

for i = 1:length(tmp_Pb206_U238_age)
if tmp_Pb206_U238_age(i,1) < 0
tmp_Pb206_U238_age(i,1) = 0;
else
tmp_Pb206_U238_age(i,1) = tmp_Pb206_U238_age(i,1);
end
end

for i = 1:length(tmp_Pb206_U238_err)
if tmp_Pb206_U238_err(i,1) < 0
tmp_Pb206_U238_err(i,1) = 0;
else
tmp_Pb206_U238_err(i,1) = tmp_Pb206_U238_err(i,1);
end
end

tmp_Pb207_U235_age = 1+bias_corr_All_Pb207_U235;
tmp_Pb207_U235_err = 1+bias_corr_All_Pb207_U235-(bias_corr_All_Pb207_U235_err/100.*bias_corr_All_Pb207_U235);

for i = 1:length(tmp_Pb207_U235_age)
if tmp_Pb207_U235_age(i,1) < 0
tmp_Pb207_U235_age(i,1) = 0;
else
tmp_Pb207_U235_age(i,1) = tmp_Pb207_U235_age(i,1);
end
end

for i = 1:length(tmp_Pb207_U235_err)
if tmp_Pb207_U235_err(i,1) < 0
tmp_Pb207_U235_err(i,1) = 0;
else
tmp_Pb207_U235_err(i,1) = tmp_Pb207_U235_err(i,1);
end
end

tmp_Pb208_Th232_age = 1+bias_corr_All_Pb208_Th232;
tmp_Pb208_Th232_err = bias_corr_All_Pb208_Th232 - bias_corr_All_Pb208_Th232.*bias_corr_All_Pb208_Th232_err/100;

for i = 1:length(tmp_Pb208_Th232_age)
if tmp_Pb208_Th232_age(i,1) < 0
tmp_Pb208_Th232_age(i,1) = 0;
else
tmp_Pb208_Th232_age(i,1) = tmp_Pb208_Th232_age(i,1);
end
end

for i = 1:length(tmp_Pb208_Th232_err)
if tmp_Pb208_Th232_err(i,1) < 0
tmp_Pb208_Th232_err(i,1) = 0;
else
tmp_Pb208_Th232_err(i,1) = tmp_Pb208_Th232_err(i,1);
end
end

%% AGE CALCULATIONS %%
All_Pb206_U238_age = 1/0.000000000155125.*log(tmp_Pb206_U238_age)/1000000;
All_Pb206_U238_age_err =abs((1/0.000000000155125.*log(tmp_Pb206_U238_err)/1000000) ...
	-(1/0.000000000155125.*log(1+bias_corr_All_Pb206_U238 ...
	+(bias_corr_All_Pb206_U238_err/100.*bias_corr_All_Pb206_U238))/1000000))/2;

for i = 1:length(bias_corr_All_Pb207_Pb206)
All_Pb207_Pb206_age(i,:) = newton_method(bias_corr_All_Pb207_Pb206(i,:), 2000, .0000001);
end
for i = 1:length(bias_corr_All_Pb207_Pb206)
All_Pb207_Pb206_age_err(i,:) = AgePb76Er5(All_Pb207_Pb206_age(i,:), bias_corr_All_Pb207_Pb206_err(i,:));
end

All_Pb207_U235_age = 1/0.00000000098485.*log(tmp_Pb207_U235_age)/1000000;
All_Pb207_U235_age_err =abs((1/0.00000000098485.*log(tmp_Pb207_U235_err)/1000000) ...
	-(1/0.00000000098485.*log(1+bias_corr_All_Pb207_U235 ...
	+(bias_corr_All_Pb207_U235_err/100.*bias_corr_All_Pb207_U235))/1000000))/2;

All_Pb208_Th232_age = 1/0.000000000049475.*log(tmp_Pb208_Th232_age)/1000000;
All_Pb208_Th232_age_err = All_Pb208_Th232_age-( 1/0.000000000049475.*log(1+(tmp_Pb208_Th232_err))/1000000);

%% REMOVE ANY/ALL NANs %%
pleis_Pb206_U238_age = nonzeros(pleis.*All_Pb206_U238_age);
pleis_Pb206_U238_age = pleis_Pb206_U238_age(all(~isnan(pleis_Pb206_U238_age),2),:);
pleis_Pb206_U238_age_err = nonzeros(pleis.*All_Pb206_U238_age_err);
pleis_Pb206_U238_age_err = pleis_Pb206_U238_age_err(all(~isnan(pleis_Pb206_U238_age_err),2),:);
pleis_Pb207_Pb206_age = nonzeros(pleis.*All_Pb207_Pb206_age);
pleis_Pb207_Pb206_age = pleis_Pb207_Pb206_age(all(~isnan(pleis_Pb207_Pb206_age),2),:);
pleis_Pb207_Pb206_age_err = nonzeros(pleis.*All_Pb207_Pb206_age_err);
pleis_Pb207_Pb206_age_err = pleis_Pb207_Pb206_age_err(all(~isnan(pleis_Pb207_Pb206_age_err),2),:);
pleis_Pb207_U235_age = nonzeros(pleis.*All_Pb207_U235_age);
pleis_Pb207_U235_age = pleis_Pb207_U235_age(all(~isnan(pleis_Pb207_U235_age),2),:);
pleis_Pb207_U235_age_err = nonzeros(pleis.*All_Pb207_U235_age_err);
pleis_Pb207_U235_age_err = pleis_Pb207_U235_age_err(all(~isnan(pleis_Pb207_U235_age_err),2),:);
pleis_Pb208_Th232_age = nonzeros(pleis.*All_Pb208_Th232_age);
pleis_Pb208_Th232_age = pleis_Pb208_Th232_age(all(~isnan(pleis_Pb208_Th232_age),2),:);
pleis_Pb208_Th232_age_err = nonzeros(pleis.*All_Pb208_Th232_age_err);
pleis_Pb208_Th232_age_err = pleis_Pb208_Th232_age_err(all(~isnan(pleis_Pb208_Th232_age_err),2),:);

fc5z_Pb206_U238_age = nonzeros(fc5z.*All_Pb206_U238_age);
fc5z_Pb206_U238_age = fc5z_Pb206_U238_age(all(~isnan(fc5z_Pb206_U238_age),2),:);
fc5z_Pb206_U238_age_err = nonzeros(fc5z.*All_Pb206_U238_age_err);
fc5z_Pb206_U238_age_err = fc5z_Pb206_U238_age_err(all(~isnan(fc5z_Pb206_U238_age_err),2),:);
fc5z_Pb207_Pb206_age = nonzeros(fc5z.*All_Pb207_Pb206_age);
fc5z_Pb207_Pb206_age = fc5z_Pb207_Pb206_age(all(~isnan(fc5z_Pb207_Pb206_age),2),:);
fc5z_Pb207_Pb206_age_err = nonzeros(fc5z.*All_Pb207_Pb206_age_err);
fc5z_Pb207_Pb206_age_err = fc5z_Pb207_Pb206_age_err(all(~isnan(fc5z_Pb207_Pb206_age_err),2),:);
fc5z_Pb207_U235_age = nonzeros(fc5z.*All_Pb207_U235_age);
fc5z_Pb207_U235_age = fc5z_Pb207_U235_age(all(~isnan(fc5z_Pb207_U235_age),2),:);
fc5z_Pb207_U235_age_err = nonzeros(fc5z.*All_Pb207_U235_age_err);
fc5z_Pb207_U235_age_err = fc5z_Pb207_U235_age_err(all(~isnan(fc5z_Pb207_U235_age_err),2),:);
fc5z_Pb208_Th232_age = nonzeros(fc5z.*All_Pb208_Th232_age);
fc5z_Pb208_Th232_age = fc5z_Pb208_Th232_age(all(~isnan(fc5z_Pb208_Th232_age),2),:);
fc5z_Pb208_Th232_age_err = nonzeros(fc5z.*All_Pb208_Th232_age_err);
fc5z_Pb208_Th232_age_err = fc5z_Pb208_Th232_age_err(all(~isnan(fc5z_Pb208_Th232_age_err),2),:);

samples_Pb206_U238_age = nonzeros(samples.*All_Pb206_U238_age);
samples_Pb206_U238_age = samples_Pb206_U238_age(all(~isnan(samples_Pb206_U238_age),2),:);
samples_Pb206_U238_age_err = nonzeros(samples.*All_Pb206_U238_age_err);
samples_Pb206_U238_age_err = samples_Pb206_U238_age_err(all(~isnan(samples_Pb206_U238_age_err),2),:);
samples_Pb207_Pb206_age = nonzeros(samples.*All_Pb207_Pb206_age);
samples_Pb207_Pb206_age = samples_Pb207_Pb206_age(all(~isnan(samples_Pb207_Pb206_age),2),:);
samples_Pb207_Pb206_age_err = nonzeros(samples.*All_Pb207_Pb206_age_err);
samples_Pb207_Pb206_age_err = samples_Pb207_Pb206_age_err(all(~isnan(samples_Pb207_Pb206_age_err),2),:);
samples_Pb207_U235_age = nonzeros(samples.*All_Pb207_U235_age);
samples_Pb207_U235_age = samples_Pb207_U235_age(all(~isnan(samples_Pb207_U235_age),2),:);
samples_Pb207_U235_age_err = nonzeros(samples.*All_Pb207_U235_age_err);
samples_Pb207_U235_age_err = samples_Pb207_U235_age_err(all(~isnan(samples_Pb207_U235_age_err),2),:);
samples_Pb208_Th232_age = nonzeros(samples.*All_Pb208_Th232_age);
samples_Pb208_Th232_age = samples_Pb208_Th232_age(all(~isnan(samples_Pb208_Th232_age),2),:);
samples_Pb208_Th232_age_err = nonzeros(samples.*All_Pb208_Th232_age_err);
samples_Pb208_Th232_age_err = samples_Pb208_Th232_age_err(all(~isnan(samples_Pb208_Th232_age_err),2),:);


%% CALCULATE DISCORDANCE %%
discordance_Pb206U238_Pb207Pb206 = 100-(100*samples_Pb206_U238_age./samples_Pb207_Pb206_age);
discordance_Pb206U238_Pb207U235 = 100-(100*samples_Pb206_U238_age./samples_Pb207_U235_age);

pleis_discordance_Pb206U238_Pb207Pb206 = 100-(100*pleis_Pb206_U238_age./pleis_Pb207_Pb206_age);
pleis_discordance_Pb206U238_Pb207U235 = 100-(100*pleis_Pb206_U238_age./pleis_Pb207_U235_age);

fc5z_discordance_Pb206U238_Pb207Pb206 = 100-(100*fc5z_Pb206_U238_age./fc5z_Pb207_Pb206_age);
fc5z_discordance_Pb206U238_Pb207U235 = 100-(100*fc5z_Pb206_U238_age./fc5z_Pb207_U235_age);

final_sample_num = transpose(1:1:length(nonzeros(samples)));
final_pleis_num = transpose(1:1:length(nonzeros(pleis)));
final_fc5z_num = transpose(1:1:length(nonzeros(fc5z)));

%% USER-DEFINED REDUCED DATA FILTERS %%
cutoff_uncert = str2num(get(handles.filter_unc_cutoff,'String'));
cutoff_76_68 = str2num(get(handles.filter_transition_68_76,'String'));
cutoff_disc_lt_cutoff_disc = str2num(get(handles.filter_disc_young,'String'));
cutoff_disc = str2num(get(handles.filter_disc_transition,'String'));
cutoff_disc_gt_cutoff_disc = str2num(get(handles.filter_disc_old,'String'));
cutoff_rev_disc = str2num(get(handles.filter_disc_rev,'String'));

for i = 1:length(samples_Pb206_U238_age)
if samples_Pb206_U238_age(i,1) > cutoff_76_68
	best_age(i,1) = samples_Pb207_Pb206_age(i,1);
else 
	best_age(i,1) = samples_Pb206_U238_age(i,1);
end
end

for i = 1:length(samples_Pb206_U238_age)
if samples_Pb206_U238_age(i,1) > cutoff_76_68
	best_age_err(i,1) = samples_Pb207_Pb206_age_err(i,1);
else 
	best_age_err(i,1) = samples_Pb206_U238_age_err(i,1);
end
end

final_samples = [final_sample_num, nonzeros(samples.*bias_corr_samples_Pb207_Pb206), nonzeros(samples.*bias_corr_samples_Pb207_Pb206_err), ...
	nonzeros(samples.*bias_corr_samples_Pb207_U235), nonzeros(samples.*bias_corr_samples_Pb207_U235_err), ...
	nonzeros(samples.*bias_corr_samples_Pb206_U238), nonzeros(samples.*bias_corr_samples_Pb206_U238_err), ...
	nonzeros(samples.*rho), nonzeros(samples.*bias_corr_samples_Pb208_Th232), nonzeros(samples.*bias_corr_samples_Pb208_Th232_err), ...
	samples_Pb206_U238_age, samples_Pb206_U238_age_err, samples_Pb207_U235_age, samples_Pb207_U235_age_err, ...
	samples_Pb207_Pb206_age, samples_Pb207_Pb206_age_err, samples_Pb208_Th232_age, samples_Pb208_Th232_age_err, ...
	discordance_Pb206U238_Pb207Pb206, discordance_Pb206U238_Pb207U235, best_age, best_age_err];

final_pleis = [final_pleis_num, nonzeros(pleis.*bias_corr_pleis_Pb207_Pb206), nonzeros(pleis.*bias_corr_pleis_Pb207_Pb206_err), ...
    nonzeros(pleis.*bias_corr_pleis_Pb207_U235), nonzeros(pleis.*bias_corr_pleis_Pb207_U235_err), ...
    nonzeros(pleis.*bias_corr_pleis_Pb206_U238), nonzeros(pleis.*bias_corr_pleis_Pb206_U238_err), ...
    nonzeros(pleis.*rho), nonzeros(pleis.*bias_corr_pleis_Pb208_Th232), nonzeros(pleis.*bias_corr_pleis_Pb208_Th232_err), ...
    pleis_Pb206_U238_age, pleis_Pb206_U238_age_err, pleis_Pb207_U235_age, pleis_Pb207_U235_age_err, ...
    pleis_Pb207_Pb206_age, pleis_Pb207_Pb206_age_err, pleis_Pb208_Th232_age, pleis_Pb208_Th232_age_err, ...
    pleis_discordance_Pb206U238_Pb207Pb206, pleis_discordance_Pb206U238_Pb207U235];

final_fc5z = [final_fc5z_num, nonzeros(fc5z.*bias_corr_fc5z_Pb207_Pb206), nonzeros(fc5z.*bias_corr_fc5z_Pb207_Pb206_err), ...
    nonzeros(fc5z.*bias_corr_fc5z_Pb207_U235), nonzeros(fc5z.*bias_corr_fc5z_Pb207_U235_err), ...
    nonzeros(fc5z.*bias_corr_fc5z_Pb206_U238), nonzeros(fc5z.*bias_corr_fc5z_Pb206_U238_err), ...
    nonzeros(fc5z.*rho), nonzeros(fc5z.*bias_corr_fc5z_Pb208_Th232), nonzeros(fc5z.*bias_corr_fc5z_Pb208_Th232_err), ...
    fc5z_Pb206_U238_age, fc5z_Pb206_U238_age_err, fc5z_Pb207_U235_age, fc5z_Pb207_U235_age_err, ...
    fc5z_Pb207_Pb206_age, fc5z_Pb207_Pb206_age_err, fc5z_Pb208_Th232_age, fc5z_Pb208_Th232_age_err, ...
    fc5z_discordance_Pb206U238_Pb207Pb206, fc5z_discordance_Pb206U238_Pb207U235];

%assignin ('base','final_samples',final_samples); %export variable to workspace

final_samples_gt_cutoff_disc = zeros(length(final_samples),22);
final_samples_lt_cutoff_disc = zeros(length(final_samples),22);

lt_length = length(final_samples_lt_cutoff_disc(:,1));
gt_length = length(final_samples_gt_cutoff_disc(:,1));

discordant_samples = zeros(length(final_sample_num),22);

sample_length = length(final_samples(:,1));

final_samples_sort= sortrows(final_samples, 21);

for i = 1:sample_length
if final_samples_sort(i,21) > cutoff_disc
	final_samples_gt_cutoff_disc(i,:) = final_samples_sort(i,:);
else 
	final_samples_lt_cutoff_disc(i,:) = final_samples_sort(i,:);
end
end

for i = 1:lt_length
if final_samples_lt_cutoff_disc(i,20) < final_samples_lt_cutoff_disc(i,5) + cutoff_disc_lt_cutoff_disc
	concordant_samples_lt_cutoff(i,:) = final_samples_lt_cutoff_disc(i,:);
elseif final_samples_lt_cutoff_disc(i,20) < final_samples_lt_cutoff_disc(i,7) + cutoff_disc_lt_cutoff_disc
	concordant_samples_lt_cutoff(i,:) = final_samples_lt_cutoff_disc(i,:);
else
	discordant_samples(i,:) = final_samples_lt_cutoff_disc(i,:);
end
end

for i = 1:gt_length
if  final_samples_gt_cutoff_disc(i,19) < -cutoff_rev_disc
   discordant_samples(i,:) = final_samples_gt_cutoff_disc(i,:);
elseif final_samples_gt_cutoff_disc(i,19) > cutoff_disc_gt_cutoff_disc 
   discordant_samples(i,:) = final_samples_gt_cutoff_disc(i,:); 
else
    concordant_samples_gt_cutoff(i,:) = final_samples_gt_cutoff_disc(i,:);
end
end

for i = 1:lt_length
if final_samples_lt_cutoff_disc(i,7) < cutoff_uncert
	concordant_samples_lt_cutoff_uncert(i,:) = final_samples_lt_cutoff_disc(i,:);
else
	discordant_samples(i,:) = final_samples_lt_cutoff_disc(i,:);
end
end

for i = 1:gt_length
if final_samples_gt_cutoff_disc(i,3) < cutoff_uncert
	concordant_samples_gt_cutoff_uncert(i,:) = final_samples_gt_cutoff_disc(i,:);
else
	discordant_samples(i,:) = final_samples_gt_cutoff_disc(i,:);
end
end

concordant_samples = zeros(length(final_samples_sort),22);

for i = 1:length(final_samples_sort(:,1))
if discordant_samples(i,:) < 1
	concordant_samples(i,:) = final_samples_sort(i,:);
else
	discordant_samples(i,:) = final_samples_sort(i,:);
end
end

concordant_samples_sort= sortrows(concordant_samples, 21);
discordant_samples_sort= sortrows(discordant_samples, 21);

concordant_samples_sort( all(~concordant_samples_sort,2), : ) = [];
discordant_samples_sort( all(~discordant_samples_sort,2), : ) = [];

data1 = concordant_samples_sort(:,21:22);
data2 = discordant_samples_sort(:,21:22);

%% CONCORDIA PLOT PRIMARY REFERENCE MATERIAL %%
axes(handles.axes_primary);
set(handles.axes_primary,'FontSize',8);
set(handles.primary_reference,'String',PLEIS);

timemin = 0;
timemax = 4500000000;
timeinterval = 50000000;
time3 = timemin:timeinterval:timemax;
x = exp(0.00000000098485.*time3)-1;
y = exp(0.000000000155125.*time3)-1;

age_label_x = [0.3437; 0.4828];
age_label_y = [0.0476; 0.0640];
age_label = {'300 Ma'; '400 Ma'};

age_label2_x = 0.3937;
age_label2_y = 0.0537;
age_label2 = {'337.1 Ma'};

for i = 1:length(sigx_sq_acc);
covmat_acc=[sigx_sq_acc(i,1),rho_sigx_sigy_acc(i,1);rho_sigx_sigy_acc(i,1),sigy_sq_acc(i,1)];
[PD_acc,PV_acc]=eig(covmat_acc);
PV_acc=diag(PV_acc).^.5;
theta_acc=linspace(0,2.*pi,numpoints)';
elpt_acc=[cos(theta_acc),sin(theta_acc)]*diag(PV_acc)*PD_acc';
numsigma=length(sigmarule);
elpt_acc=repmat(elpt_acc,1,numsigma).*repmat(sigmarule(floor(1:.5:numsigma+.5)),numpoints,1);
elpt_acc=elpt_acc+repmat(center(i,1:2),numpoints,numsigma);
plot(elpt_acc(:,1:2:end),elpt_acc(:,2:2:end),'b','LineWidth',1.2);
hold on
end

for i = 1:length(sigx_sq_rej);
covmat_rej=[sigx_sq_rej(i,1),rho_sigx_sigy_rej(i,1);rho_sigx_sigy_rej(i,1),sigy_sq_rej(i,1)];
[PD_rej,PV_rej]=eig(covmat_rej);
PV_rej=diag(PV_rej).^.5;
theta_rej=linspace(0,2.*pi,numpoints)';
elpt_rej=[cos(theta_rej),sin(theta_rej)]*diag(PV_rej)*PD_rej';
numsigma=length(sigmarule);
elpt_rej=repmat(elpt_rej,1,numsigma).*repmat(sigmarule(floor(1:.5:numsigma+.5)),numpoints,1);
elpt_rej=elpt_rej+repmat(center(i,1:2),numpoints,numsigma);
plot(elpt_rej(:,1:2:end),elpt_rej(:,2:2:end),'r','LineWidth',.5);
hold on
end

plot(x,y,'k','LineWidth',1.4)
hold on
p1 = scatter(age_label2_x, age_label2_y,40,'MarkerEdgeColor','k','MarkerFaceColor','g','LineWidth',1.5);
labelpoints (age_label2_x, age_label2_y, age_label2, 'SE', .005);
legend([p1],'accepted age','Location','northwest');

scatter(age_label_x, age_label_y,20,'MarkerEdgeColor','k','MarkerFaceColor','y','LineWidth',1.5)
labelpoints (age_label_x, age_label_y, age_label, 'SE', .005);
axis([.27 .54 .041 .07]);
xlabel('207Pb/235U', 'FontSize', 7);
ylabel('206Pb/238U', 'FontSize', 7);

%% CONCORDIA PLOT SECONDARY REFERENCE MATERIAL %%
fc5z_data = [nonzeros(bias_corr_fc5z_Pb207_Pb206),nonzeros(bias_corr_fc5z_Pb207_Pb206_err) ...
	,nonzeros(bias_corr_fc5z_Pb207_U235),nonzeros(bias_corr_fc5z_Pb207_U235_err),...
	nonzeros(bias_corr_fc5z_Pb206_U238),nonzeros(bias_corr_fc5z_Pb206_U238_err)];

center=[fc5z_data(:,3),fc5z_data(:,5)];

sigx_abs = fc5z_data(:,3).*fc5z_data(:,4).*0.01;
sigy_abs = fc5z_data(:,5).*fc5z_data(:,6).*0.01;

sigx_sq = sigx_abs.*sigx_abs;
sigy_sq = sigy_abs.*sigy_abs;
rho_sigx_sigy = sigx_abs.*sigy_abs.*fc5z_rho;

axes(handles.axes_secondary);
set(handles.axes_secondary,'FontSize',8);
set(handles.secondary_reference,'String',FC5Z);

for i = 1:length(nonzeros(bias_corr_fc5z_Pb207_Pb206));
covmat=[sigx_sq(i,1),rho_sigx_sigy(i,1);rho_sigx_sigy(i,1),sigy_sq(i,1)];
[PD,PV]=eig(covmat);
PV=diag(PV).^.5;
theta=linspace(0,2.*pi,numpoints)';
elpt=[cos(theta),sin(theta)]*diag(PV)*PD';
numsigma=length(sigmarule);
elpt=repmat(elpt,1,numsigma).*repmat(sigmarule(floor(1:.5:numsigma+.5)),numpoints,1);
elpt=elpt+repmat(center(i,1:2),numpoints,numsigma);
plot(elpt(:,1:2:end),elpt(:,2:2:end),'b','LineWidth',1.2);
hold on
end

timemin = 0;
timemax = 4500000000;
timeinterval = 50000000;
time3 = timemin:timeinterval:timemax;

x = exp(0.00000000098485.*time3)-1;
y = exp(0.000000000155125.*time3)-1;

age_label_x = [1.7307; 1.8404; 2.0732];
age_label_y = [0.1714; 0.1787; 0.1934];
age_label = {'1020 Ma'; '1060 Ma'; '1140 Ma'};

age_label3_x = 1.9429;
age_label3_y = 0.1853;
age_label3 = {'1099.1 Ma'};

plot(x,y,'k','LineWidth',1.4)
hold on

p2 = scatter(age_label3_x, age_label3_y,40,'MarkerEdgeColor','k','MarkerFaceColor','g','LineWidth',1.5);
labelpoints (age_label3_x, age_label3_y, age_label3, 'SE', .005);
legend([p2],'accepted age','Location','northwest');

scatter(age_label_x, age_label_y,20,'MarkerEdgeColor','k','MarkerFaceColor','y','LineWidth',1.5)
labelpoints (age_label_x, age_label_y, age_label, 'SE', .005);

axis([1.5 2.5 .15 .22]);
xlabel('207Pb/235U', 'FontSize', 7);
ylabel('206Pb/238U', 'FontSize', 7);

%% POPULATE LISTBOX, AND PLOT INDIVIDUAL SAMPLE RAW DATA, INTEGRATION WINDOW, AND BASELINE CORRECTION WINDOW %%
name_idx = length(name); %automatically plot final sample run

set(handles.listbox1, 'String', name_char);
set(handles.listbox1,'Value',length(name));
values = data_ind(:,3:11,name_idx);
values2 = values(any(values,2),:);
log_values = log10(values2);
log_values(~isfinite(log_values))=0;
t = data_ind(1:length(values2(:,1)),2,name_idx);
C = {[0 .5 0],[.5 0 0],[.5 .5 0],[0 .5 .5],[.5 0 .5],[0 0 1],[0 1 1],[1 0 1]}; % Cell array of colors

axes(handles.axes_current_intensities);
cla(handles.axes_current_intensities,'reset');
if get(handles.thick_lines,'Value')==1 
thickness = 1;
else
thickness = 0.5;
end

axes(handles.axes_current_intensities);
cla(handles.axes_current_intensities,'reset');
hold on
if get(handles.chk_Hg201,'Value')==1 
plot(t,log_values(:,1),'linewidth', thickness,'color',C{1});
end
if get(handles.chk_Hg202,'Value')==1 
plot(t,log_values(:,2),'linewidth', thickness,'color',C{2});
end
if get(handles.chk_Pb204,'Value')==1 
plot(t,log_values(:,3),'linewidth', thickness,'color',C{3});
end
if get(handles.chk_Pb206,'Value')==1 
plot(t,log_values(:,4),'linewidth', thickness,'color',C{4});
end
if get(handles.chk_Pb207,'Value')==1 
plot(t,log_values(:,5),'linewidth', thickness,'color',C{5});
end
if get(handles.chk_Pb208,'Value')==1 
plot(t,log_values(:,6),'linewidth', thickness,'color',C{6});
end
if get(handles.chk_Th232,'Value')==1 
plot(t,log_values(:,7),'linewidth', thickness,'color',C{7});
end
if get(handles.chk_U238,'Value')==1 
plot(t,log_values(:,8),'linewidth', thickness, 'color',C{8});
end

hold off
title('Sample intensity')
xlabel('time (seconds)')
ylabel('Intensity (log10 cps)')
axis([0 max(t) 2 max(max(log_values))+0.5])

Y1_BL_trim = log_values(1:t_BL_trim_length(1,length(name)),:);
Y1_BL_trim_min = min(Y1_BL_trim);
Y1_BL_trim_max = max(Y1_BL_trim);
Y1_BL_trim_min = 2;
Y1_BL_trim_max = max(Y1_BL_trim_max);
t_INT_trim_last = nonzeros(t_INT_trim(:,name_idx));
t_INT_trim_min = min(t_INT_trim_last);
t_INT_trim_min_idx = t_INT_trim_max_idx - length(t_INT_trim_last) + 1;
Y1_INT_trim = log_values(t_INT_trim_min_idx(1,name_idx):t_INT_trim_max_idx(1,name_idx),:);
values_INT_trim = values(t_INT_trim_min_idx:t_INT_trim_max_idx,:);
Y1_INT_trim_min = min(Y1_INT_trim);
Y1_INT_trim_max = max(Y1_INT_trim);
Y1_INT_trim_min = min(Y1_INT_trim_min);
Y1_INT_trim_max = max(Y1_INT_trim_max);

if get(handles.chk_windows,'Value')==1 
hold on
rectangle('Position',[BL_xmin Y1_BL_trim_min BL_xmax-BL_xmin Y1_BL_trim_max-Y1_BL_trim_min],'EdgeColor','k','LineWidth',2)
rectangle('Position',[INT_xmin(1,name_idx) Y1_INT_trim_min INT_xmax(1,name_idx)-INT_xmin(1,name_idx) Y1_INT_trim_max-Y1_INT_trim_min],'EdgeColor','k','LineWidth',2)
hold off
end

%% PLOT INDIVIDUAL SAMPLE CONCORDIA %%

rhoA =((Pb206_U238_err.*Pb206_U238_err) + ...
	(Pb207_U235_err.*Pb207_U235_err)) - ...
	(Pb207_Pb206_err.*Pb207_Pb206_err);
rhoB =2.*(Pb206_U238_err.*Pb207_U235_err);
rho = rhoA./rhoB;

if rho < 0
rho_corr = str2num(get(handles.replace_bad_rho,'String'));
elseif rho > 1
rho_corr = str2num(get(handles.replace_bad_rho,'String'));
else
rho_corr = rho;
end

concordia_data = [Pb207_Pb206,Pb207_Pb206_err, ...
	Pb207_U235,Pb207_U235_err,...
	Pb206_U238,Pb206_U238_err];

center=[concordia_data(name_idx,3),concordia_data(name_idx,5)];

sigx_abs = concordia_data(:,3).*concordia_data(:,4).*0.01;
sigy_abs = concordia_data(:,5).*concordia_data(:,6).*0.01;

sigx_sq = sigx_abs(name_idx,1).*sigx_abs(name_idx,1);
sigy_sq = sigy_abs(name_idx,1).*sigy_abs(name_idx,1);
rho_sigx_sigy = sigx_abs(name_idx,1).*sigy_abs(name_idx,1).*rho(name_idx,1);

axes(handles.axes_current_concordia);

covmat=[sigx_sq,rho_sigx_sigy;rho_sigx_sigy,sigy_sq];
[PD,PV]=eig(covmat);
PV=diag(PV).^.5;
theta=linspace(0,2.*pi,numpoints)';
elpt=[cos(theta),sin(theta)]*diag(PV)*PD';
numsigma=length(sigmarule);
elpt=repmat(elpt,1,numsigma).*repmat(sigmarule(floor(1:.5:numsigma+.5)),numpoints,1);
elpt=elpt+repmat(center,numpoints,numsigma);
plot(elpt(:,1:2:end),elpt(:,2:2:end),'b','LineWidth',2);
hold on

timemin = 0;
timemax = 4500000000;
timeinterval = 50000000;
time3 = timemin:timeinterval:timemax;

x = exp(0.00000000098485.*time3)-1;
y = exp(0.000000000155125.*time3)-1;

xaxismin = Pb207_U235(name_idx,1) - 0.3.*Pb207_U235(name_idx,1);
xaxismax = Pb207_U235(name_idx,1) + 0.3.*Pb207_U235(name_idx,1);
yaxismin = Pb206_U238(name_idx,1) - 0.3.*Pb206_U238(name_idx,1);
yaxismax = Pb206_U238(name_idx,1) + 0.3.*Pb206_U238(name_idx,1);

Pb206_U238_age = All_Pb206_U238_age(name_idx,1);
Pb206_U238_age_err = All_Pb206_U238_age_err(name_idx,1);

Pb207_Pb206_age = All_Pb207_Pb206_age(name_idx,1);
Pb207_Pb206_age_err = All_Pb207_Pb206_age_err(name_idx,1);

age_label_num = 0:50:4500;
for i=1:length(x)
if x(1,i) < xaxismax &&  x(1,i) > xaxismin && y(1,i) < yaxismax && y(1,i) > yaxismin
age_label4(i,1) = {sprintf('%.1f',age_label_num(1,i))};
x2(i,1) = x(1,i);
y2(i,1) = y(1,i);
age_label_num2(i,1) = age_label_num(1,i);
else
age_label4(i,1) = num2cell(9999);
x2(i,1) = 9999;
y2(i,1) = 9999;
age_label_num2(i,1) = 9999;
end
end

age_label5 = age_label4(~cellfun(@isempty, age_label4));
x2 = nonzeros(x2);
y2 = nonzeros(y2);
age_label_num2 = nonzeros(age_label_num2.*1000000);

age_label_x = exp(0.00000000098485.*age_label_num2)-1;
age_label_y = exp(0.000000000155125.*age_label_num2)-1;

plot(x,y,'k','LineWidth',1.4)
hold on
scatter(age_label_x, age_label_y,20,'MarkerEdgeColor','k','MarkerFaceColor','y','LineWidth',1.5)
labelpoints(age_label_x, age_label_y, age_label5, 'SE');

age_label3_x = Pb207_U235(name_idx,1);
age_label3_y = Pb206_U238(name_idx,1);

if Pb206_U238_age < cutoff_76_68
age_label3 = {Pb206_U238_age};
else
age_label3 = {Pb207_Pb206_age};
end

if Pb206_U238_age < cutoff_76_68
age_label4 = {Pb206_U238_age_err};
else
age_label4 = {Pb207_Pb206_age_err};
end

scatter(age_label3_x, age_label3_y, 200,'MarkerEdgeColor','k','MarkerFaceColor','g','LineWidth',1.5);
set(handles.text139, 'String', age_label3); 
set(handles.text141, 'String', age_label4); 
axis([xaxismin xaxismax yaxismin yaxismax]);
xlabel('207Pb/235U', 'FontSize', 7);
ylabel('206Pb/238U', 'FontSize', 7);

%% DISTRIBUTION PLOT %%
axes(handles.axes_distribution); 

rad_on_plot=get(handles.uipanel_plot,'selectedobject');
	switch rad_on_plot
    case handles.filt_data
dist_data = data1;
    case handles.rej_data
dist_data = data2;
    case handles.all_data
dist_data = vertcat(data1,data2);
	end

cla reset
set(gca,'xtick',[],'ytick',[],'Xcolor','w','Ycolor','w')
xmin = str2num(get(handles.xmin,'String'));
xmax = str2num(get(handles.xmax,'String'));
xint = str2num(get(handles.xint,'String'));
hist_ymin = str2num(get(handles.ymin,'String'));
hist_ymax = str2num(get(handles.ymax,'String'));
bins = str2num(get(handles.bins,'String'));

	rad_on_dist=get(handles.uipanel_distribution,'selectedobject');
	switch rad_on_dist
    case handles.radio_hist
	axes(handles.axes_distribution);    
	hist(dist_data(:,1), bins);
	set(gca,'box','off')
	axis([xmin xmax hist_ymin hist_ymax])
	ax1 = gca;
	set(ax1,'XColor','k','YColor','k')
	set(get(ax1,'Ylabel'),'String','frequency', 'FontSize', 7)    
	set(get(ax1,'Xlabel'),'String','Age (Ma)', 'FontSize', 7)

    case handles.radio_pdp
	axes(handles.axes_distribution);     
	x=xmin:xint:xmax;
	pdp=pdp5_2sig(dist_data(:,1),dist_data(:,2),xmin,xmax,xint);    
	hl1 = plot(x,pdp,'Color',[0.1 0.8 0.1]);
	ax1 = gca;
	set(ax1,'XColor','k','YColor','k')
	pdpmax = max(pdp);
	axis([xmin xmax 0 pdpmax+0.1*pdpmax])
	lgnd=legend('Probability Density Plot');
	set(hl1,'linewidth',2)
	set(gca,'box','off')
	ax1 = gca;
	set(ax1,'XColor','k','YColor','k')
	set(get(ax1,'Ylabel'),'String','probability', 'FontSize', 7)    
	set(get(ax1,'Xlabel'),'String','Age (Ma)', 'FontSize', 7)
	set(lgnd,'color','w');
	legend boxoff

    case handles.radio_kde
	axes(handles.axes_distribution);     

		rad_on_kernel=get(handles.uipanel_kernel,'selectedobject');
		switch rad_on_kernel
		case handles.optimize
		x=xmin:xint:xmax;
		a=xmin;
		b=xmax;
		c=xint;
		xA = a:c:b;
		xA = transpose(xA);
		tin=linspace(1,length(xA),length(xA));
		A = dist_data(:,1);
		n = length(A);
		[bandwidth,kdeA,xmesh1,cdf]=kde(A,length(tin),a,b);
		kdeA=transpose(interp1(xmesh1, kdeA, xA));
		hl1 = plot(tin,kdeA,'Color',[1 0 0]);
		ax1 = gca;
		set(ax1,'XColor','k','YColor','k')
		kdemax = max(kdeA);
		axis([xmin xmax 0 kdemax+0.2*kdemax])
		lgnd=legend('Kernel Density Estimate');
		set(hl1,'linewidth',2)
		set(gca,'box','off')
		ax1 = gca;
		set(ax1,'XColor','k','YColor','k')
		set(get(ax1,'Ylabel'),'String','probability', 'FontSize', 7)    
		set(get(ax1,'Xlabel'),'String','Age (Ma)', 'FontSize', 7) 
		set(handles.optimize_text, 'String', bandwidth);
		set(lgnd,'color','w');
		legend boxoff

		case handles.Myr_kernel

		x=xmin:xint:xmax;
		kernel = str2num(get(handles.Myr_Kernel_text,'String'));
		kernel_dist_data(1:length(dist_data(:,1)),1) = kernel;
		kde1=pdp5_2sig(dist_data(:,1),kernel_dist_data,xmin,xmax,xint);    
		hl1 = plot(x,kde1,'Color',[1 0 0]);
		ax1 = gca;
		set(ax1,'XColor','k','YColor','k')
		pdpmax = max(kde1);
		axis([xmin xmax 0 pdpmax+0.2*pdpmax])
		lgnd=legend('Kernel Density Estimate');
		set(hl1,'linewidth',2)
		set(gca,'box','off')
		ax1 = gca;
		set(ax1,'XColor','k','YColor','k')
		set(get(ax1,'Ylabel'),'String','probability', 'FontSize', 7)    
		set(get(ax1,'Xlabel'),'String','Age (Ma)', 'FontSize', 7)		
		end
		set(lgnd,'color','w');
		legend boxoff

    case handles.radio_hist_pdp
	axes(handles.axes_distribution);        
	x=xmin:xint:xmax;
	pdp=pdp5_2sig(dist_data(:,1),dist_data(:,2),xmin,xmax,xint);
	hist(dist_data(:,1), bins);
	set(gca,'box','off')
	axis([xmin xmax hist_ymin hist_ymax])
	ax1 = gca;
	set(ax1,'XColor','k','YColor','k')
	set(get(ax1,'Ylabel'),'String','frequency', 'FontSize', 7)
	xlabel('Age (Ma)', 'FontSize', 7)
	ax2 = axes('Units', 'character'); %create a new axis and set units to be character
	set(ax2, 'Position',get(ax1,'Position'),...
    'XAxisLocation','top',...
    'YAxisLocation','right',...
    'Color','none',...
    'XColor','k','YColor','k');
	hold on
	pdp=pdp5_2sig(dist_data(:,1),dist_data(:,2),xmin,xmax,xint);
	hl1 = plot(x,pdp,'Color',[0.1 0.8 0.1]);
	ax1 = gca;
	set(ax1,'XColor','k','YColor','k')
	pdpmax = max(pdp);
	axis([xmin xmax 0 pdpmax+0.1*pdpmax])
	set(gca,'xtick',[])
	set(get(ax2,'Ylabel'),'String','probability')
	lgnd=legend('Probability Density Plot');
	set(hl1,'linewidth',2)	
	set(lgnd,'color','w');
	legend boxoff

    case handles.radio_hist_kde
	axes(handles.axes_distribution);
 
 		rad_on_kernel=get(handles.uipanel_kernel,'selectedobject');
		switch rad_on_kernel
		case handles.optimize      

		hist(dist_data(:,1), bins);
		set(gca,'box','off')
		axis([xmin xmax hist_ymin hist_ymax])
		ax1 = gca;
		set(ax1,'XColor','k','YColor','k')
		set(get(ax1,'Ylabel'),'String','frequency', 'FontSize', 7)
		xlabel('Age (Ma)', 'FontSize', 7)
		ax2 = axes('Units', 'character'); %create a new axis and set units to be character
		set(ax2, 'Position',get(ax1,'Position'),...
        'XAxisLocation','top',...
        'YAxisLocation','right',...
        'Color','none',...
        'XColor','k','YColor','k');
		hold on
		a=xmin;
		b=xmax;
		c=xint;
		xA = a:c:b;
		xA = transpose(xA);
		tin=linspace(1,length(xA),length(xA));
		A = dist_data(:,1);
		n = length(A);
		[bandwidth,kdeA,xmesh1,cdf]=kde(A,length(tin),a,b);
		kdeA=transpose(interp1(xmesh1, kdeA, xA));
		hl2 = plot(xA,kdeA,'Color',[1 0 0]);
		ax1 = gca;
		set(ax1,'XColor','k','YColor','k')
		kdemax = max(kdeA);
		axis([xmin xmax 0 kdemax+0.2*kdemax])
		set(gca,'xtick',[])
		set(get(ax2,'Ylabel'),'String','probability')
		lgnd=legend('Kernel Density Estimate');
		set(hl2,'linewidth',2) 
		set(handles.optimize_text, 'String', bandwidth); 
		set(lgnd,'color','w');
		legend boxoff

		case handles.Myr_kernel

		hist(dist_data(:,1), bins);
		set(gca,'box','off')
		axis([xmin xmax hist_ymin hist_ymax])
		ax1 = gca;
		set(ax1,'XColor','k','YColor','k')
		set(get(ax1,'Ylabel'),'String','frequency', 'FontSize', 7)
		xlabel('Age (Ma)', 'FontSize', 7)
		ax2 = axes('Units', 'character'); %create a new axis and set units to be character
		set(ax2, 'Position',get(ax1,'Position'),...
        'XAxisLocation','top',...
        'YAxisLocation','right',...
        'Color','none',...
        'XColor','k','YColor','k');
		hold on
		x=xmin:xint:xmax;
		kernel = str2num(get(handles.Myr_Kernel_text,'String'));
		kernel_dist_data(1:length(dist_data(:,1)),1) = kernel;
		kde1=pdp5_2sig(dist_data(:,1),kernel_dist_data,xmin,xmax,xint);    
		hl2 = plot(x,kde1,'Color',[1 0 0]);
		ax1 = gca;
		set(ax1,'XColor','k','YColor','k')
		kdemax = max(kde1);
		axis([xmin xmax 0 kdemax+0.2*kdemax])
		set(gca,'xtick',[])
		set(get(ax2,'Ylabel'),'String','probability')
		lgnd=legend('Kernel Density Estimate');
		set(hl2,'linewidth',2)
 		set(lgnd,'color','w');
		legend boxoff
		end

    case handles.radio_hist_pdp_kde
	axes(handles.axes_distribution);        
	x=xmin:xint:xmax;
	pdp=pdp5_2sig(dist_data(:,1),dist_data(:,2),xmin,xmax,xint);
	hist(dist_data(:,1), bins);
	set(gca,'box','off')
	xlabel('Age (Ma)', 'FontSize', 7)
	axis([xmin xmax hist_ymin hist_ymax])
	ax1 = gca;
	set(ax1,'XColor','k','YColor','k')
	set(get(ax1,'Ylabel'),'String','frequency')
	ax2 = axes('Units', 'character'); %create a new axis and set units to be character
	set(ax2, 'Position',get(ax1,'Position'),...
    'XAxisLocation','top',...
    'YAxisLocation','right',...
    'Color','none',...
    'XColor','k','YColor','k');
	hold on

 		rad_on_kernel=get(handles.uipanel_kernel,'selectedobject');
		switch rad_on_kernel
		case handles.optimize

		a=xmin;
		b=xmax;
		c=xint;
		xA = a:c:b;
		xA = transpose(xA);
		tin=linspace(1,length(xA),length(xA));
		A = dist_data(:,1);
		n = length(A);
		[bandwidth,kdeA,xmesh1,cdf]=kde(A,length(tin),a,b);
		kdeA=transpose(interp1(xmesh1, kdeA, xA));
		pdp=pdp5_2sig(dist_data(:,1),dist_data(:,2),xmin,xmax,xint);
		x=xmin:xint:xmax;
		hl1 = plot(x,pdp,'Color',[0.1 0.8 0.1]);
		hl2 = plot(xA,kdeA,'Color',[1 0 0]);
		ax1 = gca;
		set(ax1,'XColor','k','YColor','k')
		pdpmax = max(pdp);
		kdemax = max(kdeA);
		maxboth = [pdpmax,kdemax];
		maxboth = max(maxboth);
		axis([xmin xmax 0 maxboth+0.1*maxboth])
		set(gca,'xtick',[])
		set(get(ax2,'Ylabel'),'String','probability')
		lgnd=legend('Probability Density Plot','Kernel Density Estimate');
		set(hl1,'linewidth',2)
		set(hl2,'linewidth',2)     
   		set(handles.optimize_text, 'String', bandwidth); 
		set(lgnd,'color','w');
		legend boxoff
		
		case handles.Myr_kernel

		a=xmin;
		b=xmax;
		c=xint;
		xA = a:c:b;
		xA = transpose(xA);
		tin=linspace(1,length(xA),length(xA));
		A = dist_data(:,1);
		n = length(A);
		[bandwidth,kdeA,xmesh1,cdf]=kde(A,length(tin),a,b);
		kdeA=transpose(interp1(xmesh1, kdeA, xA));
		pdp=pdp5_2sig(dist_data(:,1),dist_data(:,2),xmin,xmax,xint);
		x=xmin:xint:xmax;
		hl1 = plot(x,pdp,'Color',[0.1 0.8 0.1]);
		x=xmin:xint:xmax;
		kernel = str2num(get(handles.Myr_Kernel_text,'String'));
		kernel_dist_data(1:length(dist_data(:,1)),1) = kernel;
		kde1=pdp5_2sig(dist_data(:,1),kernel_dist_data,xmin,xmax,xint);    
		hl2 = plot(x,kde1,'Color',[1 0 0]);		
		ax1 = gca;
		set(ax1,'XColor','k','YColor','k')
		pdpmax = max(pdp);
		kdemax = max(kde1);
		maxboth = [pdpmax,kdemax];
		maxboth = max(maxboth);
		axis([xmin xmax 0 maxboth+0.1*maxboth])
		set(gca,'xtick',[])
		set(get(ax2,'Ylabel'),'String','probability')
		lgnd=legend('Probability Density Plot','Kernel Density Estimate');
		set(hl1,'linewidth',2)
		set(hl2,'linewidth',2) 
   		set(lgnd,'color','w');
		legend boxoff
		end
	end

nsamp = num2str(length(dist_data));
set(handles.n_plotted,'String',nsamp);

handles.time=time;
handles.pleis_time=pleis_time;
handles.pleis=pleis;
handles.time_rej=time_rej;
handles.frac_corr_pleis_Pb206_U238_nz=frac_corr_pleis_Pb206_U238_nz;
handles.frac_corr_pleis_Pb206_U238_nz_err=frac_corr_pleis_Pb206_U238_nz_err;
handles.frac_corr_pleis_rej_68=frac_corr_pleis_rej_68;
handles.pleis_Pb206_U238_known=pleis_Pb206_U238_known;
handles.corr_Pb206_U238=corr_Pb206_U238;
handles.fit_68=fit_68;
handles.fit_68_lo=fit_68_lo;
handles.fit_68_hi=fit_68_hi;

			rad_on_outliers=get(handles.uipanel_outliers,'selectedobject');
			switch rad_on_outliers
			case {handles.radio_reject_poly, handles.radio_reject_spline}

			handles.model_68_hi=model_68_hi;
			handles.model_68_lo=model_68_lo;
			handles.model_76_hi=model_76_hi;
			handles.model_76_lo=model_76_lo;
			handles.model_75_hi=model_75_hi;
			handles.model_75_lo=model_75_lo;
			handles.model_82_hi=model_82_hi;
			handles.model_82_lo=model_82_lo;

			end

handles.fract_pleis_68_hi=fract_pleis_68_hi;
handles.fract_pleis_68_lo=fract_pleis_68_lo;
handles.frac_corr_pleis_Pb207_Pb206_nz=frac_corr_pleis_Pb207_Pb206_nz;
handles.frac_corr_pleis_Pb207_Pb206_nz_err=frac_corr_pleis_Pb207_Pb206_nz_err;
handles.frac_corr_pleis_rej_76=frac_corr_pleis_rej_76;
handles.pleis_Pb207_Pb206_known=pleis_Pb207_Pb206_known;
handles.corr_Pb207_Pb206=corr_Pb207_Pb206;
handles.fit_76=fit_76;
handles.fit_76_lo=fit_76_lo;
handles.fit_76_hi=fit_76_hi;

handles.fract_pleis_76_hi=fract_pleis_76_hi;
handles.fract_pleis_76_lo=fract_pleis_76_lo;
handles.frac_corr_pleis_Pb207_U235_nz=frac_corr_pleis_Pb207_U235_nz;
handles.frac_corr_pleis_Pb207_U235_nz_err=frac_corr_pleis_Pb207_U235_nz_err;
handles.frac_corr_pleis_rej_75=frac_corr_pleis_rej_75;
handles.pleis_Pb207_U235_known=pleis_Pb207_U235_known;
handles.corr_Pb207_U235=corr_Pb207_U235;
handles.fit_75=fit_75;
handles.fit_75_lo=fit_75_lo;
handles.fit_75_hi=fit_75_hi;

handles.fract_pleis_75_hi=fract_pleis_75_hi;
handles.fract_pleis_75_lo=fract_pleis_75_lo;
handles.frac_corr_pleis_Pb208_Th232_nz=frac_corr_pleis_Pb208_Th232_nz;
handles.frac_corr_pleis_Pb208_Th232_nz_err=frac_corr_pleis_Pb208_Th232_nz_err;
handles.frac_corr_pleis_rej_82=frac_corr_pleis_rej_82;
handles.pleis_Pb208_Th232_known=pleis_Pb208_Th232_known;
handles.corr_Pb208_Th232=corr_Pb208_Th232;
handles.fit_82=fit_82;
handles.fit_82_lo=fit_82_lo;
handles.fit_82_hi=fit_82_hi;
handles.fract_pleis_82_hi=fract_pleis_82_hi;
handles.fract_pleis_82_lo=fract_pleis_82_lo;

			rad_on_error=get(handles.uipanel_error_prop_type,'selectedobject');
			switch rad_on_error
			case handles.radio_errorprop_envelope 
			handles.drift_err_68_env=drift_err_68_env;
			handles.drift_err_76_env=drift_err_76_env;
			handles.drift_err_75_env=drift_err_75_env;
			handles.drift_err_82_env=drift_err_82_env;
			errprop = 0;
			case handles.radio_errorprop_sliding
			handles.drift_err_68_win=drift_err_68_win;
			handles.drift_err_76_win=drift_err_76_win;
			handles.drift_err_75_win=drift_err_75_win;
			handles.drift_err_82_win=drift_err_82_win;
			errprop = 1;
			end

handles.errprop = errprop;
set(handles.axes_bias,'FontSize',7);
set(handles.axes_primary,'FontSize',7);
set(handles.axes_secondary,'FontSize',7);
set(handles.axes_current_intensities,'FontSize',7);
set(handles.axes_current_concordia,'FontSize',7);
handles.t = t;
handles.log_values = log_values;
handles.C = C;
handles.INT_xmax = INT_xmax;
handles.INT_xmin = INT_xmin;
handles.data_ind = data_ind;
handles.name = name;
handles.t_BL_trim_length = t_BL_trim_length;
handles.t_INT_trim = t_INT_trim;
handles.BL_xmin = BL_xmin;
handles.BL_xmax = BL_xmax;
handles.t_INT_trim_max_idx = t_INT_trim_max_idx;
handles.t_INT_trim_min_idx = t_INT_trim_min_idx;
handles.data_ind = data_ind;
handles.sigx_abs = sigx_abs;
handles.sigy_abs = sigy_abs;
handles.numpoints = numpoints;
handles.rho = rho;
handles.sigmarule = sigmarule;
handles.center = center; 
handles.Pb207_U235 = Pb207_U235;
handles.Pb206_U238 = Pb206_U238;
handles.Pb207_U235_err = Pb207_U235_err;
handles.Pb206_U238_err = Pb206_U238_err;
handles.concordia_data = concordia_data;
handles.All_Pb206_U238_age = All_Pb206_U238_age;
handles.All_Pb206_U238_age_err = All_Pb206_U238_age_err;
handles.All_Pb207_Pb206_age = All_Pb207_Pb206_age;
handles.All_Pb207_Pb206_age_err = All_Pb207_Pb206_age_err;
handles.data1 = data1;
handles.data2 = data2;
handles.final_sample_num=final_sample_num;
handles.samples = samples;
handles.concordant_samples_sort = concordant_samples_sort;
handles.discordant_samples_sort = discordant_samples_sort;
handles.analysis_num = analysis_num;
handles.fc5z= fc5z;
handles.analysis_num = analysis_num;
handles.final_fc5z = final_fc5z;
handles.final_pleis = final_pleis;
handles.fc5z_time = fc5z_time;
handles.bias_corr_pleis_Pb207_Pb206 = bias_corr_pleis_Pb207_Pb206;
handles.bias_corr_fc5z_Pb207_Pb206 = bias_corr_fc5z_Pb207_Pb206;
handles.pleis_data = pleis_data;
handles.fc5z_data = fc5z_data;
handles.pleis_rho = pleis_rho;
handles.fc5z_rho = fc5z_rho;

guidata(hObject,handles);

%% PUSHBUTTON PLOT Pb206/U238 SESSION DRIFT %%
function plot_fract_68_Callback(hObject, eventdata, handles)
cla(handles.axes_bias,'reset');
time=handles.time;
pleis_time=handles.pleis_time;
frac_corr_pleis_Pb206_U238_nz=handles.frac_corr_pleis_Pb206_U238_nz;
frac_corr_pleis_Pb206_U238_nz_err=handles.frac_corr_pleis_Pb206_U238_nz_err;
frac_corr_pleis_rej_68=handles.frac_corr_pleis_rej_68;
corr_Pb206_U238=handles.corr_Pb206_U238;
pleis_Pb206_U238_known=handles.pleis_Pb206_U238_known;
fit_68=handles.fit_68;
fit_68_lo=handles.fit_68_lo;
fit_68_hi=handles.fit_68_hi;
pleis=handles.pleis;
time_rej=handles.time_rej;
fract_pleis_68_hi=handles.fract_pleis_68_hi;
fract_pleis_68_lo=handles.fract_pleis_68_lo;
outlier_cutoff_68 = str2num(get(handles.outlier_cutoff_68,'String'));
reject_poly_order = str2num(get(handles.reject_poly_order,'String'));
reject_spline_breaks = str2num(get(handles.reject_spline_breaks,'String'));
errprop = handles.errprop;

			rad_on_outliers=get(handles.uipanel_outliers,'selectedobject');
			switch rad_on_outliers
			case {handles.radio_reject_poly, handles.radio_reject_spline}

			model_68_hi=handles.model_68_hi;
			model_68_lo=handles.model_68_lo;
			model_68_hi=handles.model_68_hi;
			model_68_lo=handles.model_68_lo;
			model_68_hi=handles.model_68_hi;
			model_68_lo=handles.model_68_lo;
			model_68_hi=handles.model_68_hi;
			model_68_lo=handles.model_68_lo;

			end
		
if errprop == 0
drift_err_68_env=handles.drift_err_68_env;
else
drift_err_68_win=handles.drift_err_68_win;
end

			rad_on_error=get(handles.uipanel_error_prop_type,'selectedobject');
			switch rad_on_error
			case handles.radio_errorprop_envelope
			if exist('drift_err_68_env','var') == 0
			err_dlg=errordlg('Data was reduced using a sliding window. You will need to re-reduce data set with fitted envelope error propagation','Hang on a sec...');
			waitfor(err_dlg);
			else
			end
			case handles.radio_errorprop_sliding
			if exist('drift_err_68_win','var') == 0
			err_dlg=errordlg('Data was reduced using a sliding window. You will need to re-reduce data set with sliding window error propagation','Wait!');
			waitfor(err_dlg);
			else
			drift_err_68_win=handles.drift_err_68_win;
			end
			end
			
		rad_on=get(handles.uipanel_plot_type,'selectedobject');
        switch rad_on
        case handles.radio_measured_ratios

		frac_corr_pleis_Pb206_U238_nz_meas = nonzeros(pleis.*corr_Pb206_U238); %measured ratios
		fract_pleis_68_hi_meas = frac_corr_pleis_Pb206_U238_nz_meas + (frac_corr_pleis_Pb206_U238_nz_meas.*(frac_corr_pleis_Pb206_U238_nz_err.*0.01));
		fract_pleis_68_lo_meas = frac_corr_pleis_Pb206_U238_nz_meas - (frac_corr_pleis_Pb206_U238_nz_meas.*(frac_corr_pleis_Pb206_U238_nz_err.*0.01));
		frac_corr_pleis_rej_68_meas = pleis_Pb206_U238_known./frac_corr_pleis_rej_68; %measured ratios
		fit_68_meas = pleis_Pb206_U238_known./fit_68;
		fit_68_hi_meas = pleis_Pb206_U238_known./fit_68_hi;
		fit_68_lo_meas = pleis_Pb206_U238_known./fit_68_lo;

			rad_on_outliers=get(handles.uipanel_outliers,'selectedobject');
			switch rad_on_outliers
			case handles.radio_none
			case handles.radio_reject_poly

			model_68_pleis_meas = polyfit(pleis_time,pleis_Pb206_U238_known./frac_corr_pleis_Pb206_U238_nz,reject_poly_order);
			model_68_meas = polyval(model_68_pleis_meas,time);
			model_68_hi_meas = model_68_meas + model_68_meas.*outlier_cutoff_68.*.01;
			model_68_lo_meas = model_68_meas - model_68_meas.*outlier_cutoff_68.*.01;

		    case handles.radio_reject_spline

			model_68_pleis_meas = splinefit(pleis_time,pleis_Pb206_U238_known./frac_corr_pleis_Pb206_U238_nz,reject_spline_breaks);
			model_68_meas = ppval(model_68_pleis_meas,time);
			model_68_hi_meas = model_68_meas + model_68_meas.*outlier_cutoff_68.*.01;
			model_68_lo_meas = model_68_meas - model_68_meas.*outlier_cutoff_68.*.01;

			end

		axes(handles.axes_bias);
			
			rad_on_error=get(handles.uipanel_error_prop_type,'selectedobject');
			switch rad_on_error
			case handles.radio_errorprop_envelope
			if exist('drift_err_68_env','var')
			f=vertcat(fit_68_lo_meas,flipud(fit_68_hi_meas));
			fill(vertcat(time, flipud(time)),vertcat(fit_68_lo_meas,flipud(fit_68_hi_meas)), 'b','FaceAlpha',.3,'EdgeAlpha',.3)
			end
			case handles.radio_errorprop_sliding
			if exist('drift_err_68_win','var')
			f=vertcat(fit_68_meas-(drift_err_68_win.*0.01.*fit_68_meas),flipud(fit_68_meas+(drift_err_68_win.*0.01.*fit_68_meas)));
			fill(vertcat(time, flipud(time)),vertcat(fit_68_meas-(drift_err_68_win.*0.01.*fit_68_meas),flipud(fit_68_meas+(drift_err_68_win.*0.01.*fit_68_meas))), 'b','FaceAlpha',.3,'EdgeAlpha',.3)
			end
			end
		
		hold on
		plot(time,fit_68_meas, 'r','LineWidth',2)
		e68=errorbar(pleis_time,frac_corr_pleis_Pb206_U238_nz_meas,(frac_corr_pleis_Pb206_U238_nz_meas.*(frac_corr_pleis_Pb206_U238_nz_err.*0.01)),'o','MarkerSize',...
		5,'MarkerEdgeColor','k','MarkerFaceColor', 'k');
		scatter(time_rej, frac_corr_pleis_rej_68_meas, 100, 'r', 'filled')

			rad_on_outliers=get(handles.uipanel_outliers,'selectedobject');
			switch rad_on_outliers
			case handles.radio_none

			max_all_68_meas = max(vertcat(fit_68_hi_meas,frac_corr_pleis_Pb206_U238_nz_meas, fit_68_meas, fract_pleis_68_hi_meas, f));
			min_all_68_meas = min(vertcat(fit_68_lo_meas, frac_corr_pleis_Pb206_U238_nz_meas, fit_68_meas, fract_pleis_68_lo_meas, f));
			axis([min(time) max(time) min_all_68_meas max_all_68_meas]);

			case handles.radio_reject_poly

			plot(time, model_68_hi_meas, 'r')
			plot(time, model_68_lo_meas, 'r')
			max_all_68_meas = max(vertcat(fit_68_hi_meas,frac_corr_pleis_Pb206_U238_nz_meas, fit_68_meas, model_68_hi_meas, fract_pleis_68_hi_meas, f));
			min_all_68_meas = min(vertcat(fit_68_lo_meas, frac_corr_pleis_Pb206_U238_nz_meas, fit_68_meas, model_68_lo_meas, fract_pleis_68_lo_meas, f));
			axis([min(time) max(time) min_all_68_meas max_all_68_meas]);

		    case handles.radio_reject_spline

			plot(time, model_68_hi_meas, 'r')
			plot(time, model_68_lo_meas, 'r')
			max_all_68_meas = max(vertcat(fit_68_hi_meas,frac_corr_pleis_Pb206_U238_nz_meas, fit_68_meas, model_68_hi_meas, fract_pleis_68_hi_meas)), f;
			min_all_68_meas = min(vertcat(fit_68_lo_meas, frac_corr_pleis_Pb206_U238_nz_meas, fit_68_meas, model_68_lo_meas, fract_pleis_68_lo_meas)), f;
			axis([min(time) max(time) min_all_68_meas max_all_68_meas]);

			end
		
		hold off
		title('Pb206/U238 Session drift')
		xlabel('Decimal time')
		ylabel('Measured Pb206/U238')

		case handles.radio_fract_factor

			rad_on_outliers=get(handles.uipanel_outliers,'selectedobject');
			switch rad_on_outliers
			case handles.radio_none
			case handles.radio_reject_poly

			model_68_pleis = polyfit(pleis_time,frac_corr_pleis_Pb206_U238_nz,reject_poly_order);
			model_68 = polyval(model_68_pleis,time);
			model_68_hi = model_68 + model_68.*outlier_cutoff_68.*.01;
			model_68_lo = model_68 - model_68.*outlier_cutoff_68.*.01;

		    case handles.radio_reject_spline

			model_68_pleis = splinefit(pleis_time,frac_corr_pleis_Pb206_U238_nz,reject_spline_breaks);
			model_68 = ppval(model_68_pleis,time);
			model_68_hi = model_68 + model_68.*outlier_cutoff_68.*.01;
			model_68_lo = model_68 - model_68.*outlier_cutoff_68.*.01;

			end

		axes(handles.axes_bias);

			rad_on_error=get(handles.uipanel_error_prop_type,'selectedobject');
			switch rad_on_error
			case handles.radio_errorprop_envelope
			f=vertcat(fit_68_lo,flipud(fit_68_hi));
			fill(vertcat(time, flipud(time)),vertcat(fit_68_lo,flipud(fit_68_hi)), 'b','FaceAlpha',.3,'EdgeAlpha',.3)
			case handles.radio_errorprop_sliding
			f=vertcat(fit_68-(drift_err_68_win.*0.01.*fit_68),flipud(fit_68+(drift_err_68_win.*0.01.*fit_68)));
			fill(vertcat(time, flipud(time)),vertcat(fit_68-(drift_err_68_win.*0.01.*fit_68),flipud(fit_68+(drift_err_68_win.*0.01.*fit_68))), 'b','FaceAlpha',.3,'EdgeAlpha',.3)
			end

		hold on
		plot(time,fit_68, 'r','LineWidth',2)
		e68=errorbar(pleis_time,frac_corr_pleis_Pb206_U238_nz,(frac_corr_pleis_Pb206_U238_nz.*(frac_corr_pleis_Pb206_U238_nz_err.*0.01)),'o','MarkerSize',...
		5,'MarkerEdgeColor','k','MarkerFaceColor', 'k');

			rad_on_outliers=get(handles.uipanel_outliers,'selectedobject');
			switch rad_on_outliers
			case handles.radio_none

		max_all_68 = max(vertcat(fit_68_hi,frac_corr_pleis_Pb206_U238_nz, fit_68, fract_pleis_68_hi, f));
		min_all_68 = min(vertcat(fit_68_lo,frac_corr_pleis_Pb206_U238_nz, fit_68, fract_pleis_68_lo, f));
		axis([min(time) max(time) min(min_all_68) max(max_all_68)]);

			case {handles.radio_reject_poly, handles.radio_reject_spline}

		plot(time, model_68_hi, 'r')
		plot(time, model_68_lo, 'r')
		max_all_68 = max(vertcat(fit_68_hi,frac_corr_pleis_Pb206_U238_nz, fit_68, model_68_hi, fract_pleis_68_hi, f));
		min_all_68 = min(vertcat(fit_68_lo,frac_corr_pleis_Pb206_U238_nz, fit_68, model_68_lo, fract_pleis_68_lo, f));
		axis([min(time) max(time) min(min_all_68) max(max_all_68)]);

			end

		scatter(time_rej, frac_corr_pleis_rej_68, 100, 'r', 'filled')
		hold off
		title('Pb206/U238 Session drift')
		xlabel('Decimal time')
		ylabel('Pb206/U238 fractionation factor')
		end

if exist('err_dlg','var')
cla(handles.axes_bias,'reset');
end

guidata(hObject,handles);

%% PUSHBUTTON PLOT Pb207/Pb206 SESSION DRIFT %%
function plot_fract_76_Callback(hObject, eventdata, handles)
cla(handles.axes_bias,'reset');
time=handles.time;
pleis_time=handles.pleis_time;
frac_corr_pleis_Pb207_Pb206_nz=handles.frac_corr_pleis_Pb207_Pb206_nz;
frac_corr_pleis_Pb207_Pb206_nz_err=handles.frac_corr_pleis_Pb207_Pb206_nz_err;
frac_corr_pleis_rej_76=handles.frac_corr_pleis_rej_76;
corr_Pb207_Pb206=handles.corr_Pb207_Pb206;
pleis_Pb207_Pb206_known=handles.pleis_Pb207_Pb206_known;
fit_76=handles.fit_76;
fit_76_lo=handles.fit_76_lo;
fit_76_hi=handles.fit_76_hi;
pleis=handles.pleis;
time_rej=handles.time_rej;
fract_pleis_76_hi=handles.fract_pleis_76_hi;
fract_pleis_76_lo=handles.fract_pleis_76_lo;
outlier_cutoff_76 = str2num(get(handles.outlier_cutoff_76,'String'));
reject_poly_order = str2num(get(handles.reject_poly_order,'String'));
reject_spline_breaks = str2num(get(handles.reject_spline_breaks,'String'));
errprop = handles.errprop;

			rad_on_outliers=get(handles.uipanel_outliers,'selectedobject');
			switch rad_on_outliers
			case {handles.radio_reject_poly, handles.radio_reject_spline}

			model_76_hi=handles.model_76_hi;
			model_76_lo=handles.model_76_lo;
			model_76_hi=handles.model_76_hi;
			model_76_lo=handles.model_76_lo;
			model_76_hi=handles.model_76_hi;
			model_76_lo=handles.model_76_lo;
			model_76_hi=handles.model_76_hi;
			model_76_lo=handles.model_76_lo;

			end
		
if errprop == 0
drift_err_76_env=handles.drift_err_76_env;
else
drift_err_76_win=handles.drift_err_76_win;
end

			rad_on_error=get(handles.uipanel_error_prop_type,'selectedobject');
			switch rad_on_error
			case handles.radio_errorprop_envelope
			if exist('drift_err_76_env','var') == 0
			err_dlg=errordlg('Data was reduced using a sliding window. You will need to re-reduce data set with fitted envelope error propagation','Hang on a sec...');
			waitfor(err_dlg);
			else
			end
			case handles.radio_errorprop_sliding
			if exist('drift_err_76_win','var') == 0
			err_dlg=errordlg('Data was reduced using a sliding window. You will need to re-reduce data set with sliding window error propagation','Wait!');
			waitfor(err_dlg);
			else
			drift_err_76_win=handles.drift_err_76_win;
			end
			end
			
		rad_on=get(handles.uipanel_plot_type,'selectedobject');
        switch rad_on
        case handles.radio_measured_ratios

		frac_corr_pleis_Pb207_Pb206_nz_meas = nonzeros(pleis.*corr_Pb207_Pb206); %measured ratios
		fract_pleis_76_hi_meas = frac_corr_pleis_Pb207_Pb206_nz_meas + (frac_corr_pleis_Pb207_Pb206_nz_meas.*(frac_corr_pleis_Pb207_Pb206_nz_err.*0.01));
		fract_pleis_76_lo_meas = frac_corr_pleis_Pb207_Pb206_nz_meas - (frac_corr_pleis_Pb207_Pb206_nz_meas.*(frac_corr_pleis_Pb207_Pb206_nz_err.*0.01));
		frac_corr_pleis_rej_76_meas = pleis_Pb207_Pb206_known./frac_corr_pleis_rej_76; %measured ratios
		fit_76_meas = pleis_Pb207_Pb206_known./fit_76;
		fit_76_hi_meas = pleis_Pb207_Pb206_known./fit_76_hi;
		fit_76_lo_meas = pleis_Pb207_Pb206_known./fit_76_lo;

			rad_on_outliers=get(handles.uipanel_outliers,'selectedobject');
			switch rad_on_outliers
			case handles.radio_none
			case handles.radio_reject_poly

			model_76_pleis_meas = polyfit(pleis_time,pleis_Pb207_Pb206_known./frac_corr_pleis_Pb207_Pb206_nz,reject_poly_order);
			model_76_meas = polyval(model_76_pleis_meas,time);
			model_76_hi_meas = model_76_meas + model_76_meas.*outlier_cutoff_76.*.01;
			model_76_lo_meas = model_76_meas - model_76_meas.*outlier_cutoff_76.*.01;

		    case handles.radio_reject_spline

			model_76_pleis_meas = splinefit(pleis_time,pleis_Pb207_Pb206_known./frac_corr_pleis_Pb207_Pb206_nz,reject_spline_breaks);
			model_76_meas = ppval(model_76_pleis_meas,time);
			model_76_hi_meas = model_76_meas + model_76_meas.*outlier_cutoff_76.*.01;
			model_76_lo_meas = model_76_meas - model_76_meas.*outlier_cutoff_76.*.01;

			end

		axes(handles.axes_bias);
			
			rad_on_error=get(handles.uipanel_error_prop_type,'selectedobject');
			switch rad_on_error
			case handles.radio_errorprop_envelope
			if exist('drift_err_76_env','var')
			f=vertcat(fit_76_lo_meas,flipud(fit_76_hi_meas));
			fill(vertcat(time, flipud(time)),vertcat(fit_76_lo_meas,flipud(fit_76_hi_meas)), 'b','FaceAlpha',.3,'EdgeAlpha',.3)
			end
			case handles.radio_errorprop_sliding
			if exist('drift_err_76_win','var')
			f=vertcat(fit_76_meas-(drift_err_76_win.*0.01.*fit_76_meas),flipud(fit_76_meas+(drift_err_76_win.*0.01.*fit_76_meas)));
			fill(vertcat(time, flipud(time)),vertcat(fit_76_meas-(drift_err_76_win.*0.01.*fit_76_meas),flipud(fit_76_meas+(drift_err_76_win.*0.01.*fit_76_meas))), 'b','FaceAlpha',.3,'EdgeAlpha',.3)
			end
			end
		
		hold on
		plot(time,fit_76_meas, 'r','LineWidth',2)
		e76=errorbar(pleis_time,frac_corr_pleis_Pb207_Pb206_nz_meas,(frac_corr_pleis_Pb207_Pb206_nz_meas.*(frac_corr_pleis_Pb207_Pb206_nz_err.*0.01)),'o','MarkerSize',...
		5,'MarkerEdgeColor','k','MarkerFaceColor', 'k');
		scatter(time_rej, frac_corr_pleis_rej_76_meas, 100, 'r', 'filled')

			rad_on_outliers=get(handles.uipanel_outliers,'selectedobject');
			switch rad_on_outliers
			case handles.radio_none

			max_all_76_meas = max(vertcat(fit_76_hi_meas,frac_corr_pleis_Pb207_Pb206_nz_meas, fit_76_meas, fract_pleis_76_hi_meas, f));
			min_all_76_meas = min(vertcat(fit_76_lo_meas, frac_corr_pleis_Pb207_Pb206_nz_meas, fit_76_meas, fract_pleis_76_lo_meas, f));
			axis([min(time) max(time) min_all_76_meas max_all_76_meas]);

			case handles.radio_reject_poly

			plot(time, model_76_hi_meas, 'r')
			plot(time, model_76_lo_meas, 'r')
			max_all_76_meas = max(vertcat(fit_76_hi_meas,frac_corr_pleis_Pb207_Pb206_nz_meas, fit_76_meas, model_76_hi_meas, fract_pleis_76_hi_meas, f));
			min_all_76_meas = min(vertcat(fit_76_lo_meas, frac_corr_pleis_Pb207_Pb206_nz_meas, fit_76_meas, model_76_lo_meas, fract_pleis_76_lo_meas, f));
			axis([min(time) max(time) min_all_76_meas max_all_76_meas]);

		    case handles.radio_reject_spline

			plot(time, model_76_hi_meas, 'r')
			plot(time, model_76_lo_meas, 'r')
			max_all_76_meas = max(vertcat(fit_76_hi_meas,frac_corr_pleis_Pb207_Pb206_nz_meas, fit_76_meas, model_76_hi_meas, fract_pleis_76_hi_meas)), f;
			min_all_76_meas = min(vertcat(fit_76_lo_meas, frac_corr_pleis_Pb207_Pb206_nz_meas, fit_76_meas, model_76_lo_meas, fract_pleis_76_lo_meas)), f;
			axis([min(time) max(time) min_all_76_meas max_all_76_meas]);

			end
		
		hold off
		title('Pb206/U238 Session drift')
		xlabel('Decimal time')
		ylabel('Measured Pb206/U238')

		case handles.radio_fract_factor

			rad_on_outliers=get(handles.uipanel_outliers,'selectedobject');
			switch rad_on_outliers
			case handles.radio_none
			case handles.radio_reject_poly

			model_76_pleis = polyfit(pleis_time,frac_corr_pleis_Pb207_Pb206_nz,reject_poly_order);
			model_76 = polyval(model_76_pleis,time);
			model_76_hi = model_76 + model_76.*outlier_cutoff_76.*.01;
			model_76_lo = model_76 - model_76.*outlier_cutoff_76.*.01;

		    case handles.radio_reject_spline

			model_76_pleis = splinefit(pleis_time,frac_corr_pleis_Pb207_Pb206_nz,reject_spline_breaks);
			model_76 = ppval(model_76_pleis,time);
			model_76_hi = model_76 + model_76.*outlier_cutoff_76.*.01;
			model_76_lo = model_76 - model_76.*outlier_cutoff_76.*.01;

			end

		axes(handles.axes_bias);

			rad_on_error=get(handles.uipanel_error_prop_type,'selectedobject');
			switch rad_on_error
			case handles.radio_errorprop_envelope
			f=vertcat(fit_76_lo,flipud(fit_76_hi));
			fill(vertcat(time, flipud(time)),vertcat(fit_76_lo,flipud(fit_76_hi)), 'b','FaceAlpha',.3,'EdgeAlpha',.3)
			case handles.radio_errorprop_sliding
			f=vertcat(fit_76-(drift_err_76_win.*0.01.*fit_76),flipud(fit_76+(drift_err_76_win.*0.01.*fit_76)));
			fill(vertcat(time, flipud(time)),vertcat(fit_76-(drift_err_76_win.*0.01.*fit_76),flipud(fit_76+(drift_err_76_win.*0.01.*fit_76))), 'b','FaceAlpha',.3,'EdgeAlpha',.3)
			end

		hold on
		plot(time,fit_76, 'r','LineWidth',2)
		e76=errorbar(pleis_time,frac_corr_pleis_Pb207_Pb206_nz,(frac_corr_pleis_Pb207_Pb206_nz.*(frac_corr_pleis_Pb207_Pb206_nz_err.*0.01)),'o','MarkerSize',...
		5,'MarkerEdgeColor','k','MarkerFaceColor', 'k');

			rad_on_outliers=get(handles.uipanel_outliers,'selectedobject');
			switch rad_on_outliers
			case handles.radio_none

		max_all_76 = max(vertcat(fit_76_hi,frac_corr_pleis_Pb207_Pb206_nz, fit_76, fract_pleis_76_hi, f));
		min_all_76 = min(vertcat(fit_76_lo,frac_corr_pleis_Pb207_Pb206_nz, fit_76, fract_pleis_76_lo, f));
		axis([min(time) max(time) min(min_all_76) max(max_all_76)]);

			case {handles.radio_reject_poly, handles.radio_reject_spline}

		plot(time, model_76_hi, 'r')
		plot(time, model_76_lo, 'r')
		max_all_76 = max(vertcat(fit_76_hi,frac_corr_pleis_Pb207_Pb206_nz, fit_76, model_76_hi, fract_pleis_76_hi, f));
		min_all_76 = min(vertcat(fit_76_lo,frac_corr_pleis_Pb207_Pb206_nz, fit_76, model_76_lo, fract_pleis_76_lo, f));
		axis([min(time) max(time) min(min_all_76) max(max_all_76)]);

			end

		scatter(time_rej, frac_corr_pleis_rej_76, 100, 'r', 'filled')
		hold off
		title('Pb206/U238 Session drift')
		xlabel('Decimal time')
		ylabel('Pb206/U238 fractionation factor')
		end

if exist('err_dlg','var')
cla(handles.axes_bias,'reset');
end

guidata(hObject,handles);

%% PUSHBUTTON PLOT Pb207/U235 SESSION DRIFT %%
function plot_fract_75_Callback(hObject, eventdata, handles)
cla(handles.axes_bias,'reset');
time=handles.time;
pleis_time=handles.pleis_time;
frac_corr_pleis_Pb207_U235_nz=handles.frac_corr_pleis_Pb207_U235_nz;
frac_corr_pleis_Pb207_U235_nz_err=handles.frac_corr_pleis_Pb207_U235_nz_err;
frac_corr_pleis_rej_75=handles.frac_corr_pleis_rej_75;
corr_Pb207_U235=handles.corr_Pb207_U235;
pleis_Pb207_U235_known=handles.pleis_Pb207_U235_known;
fit_75=handles.fit_75;
fit_75_lo=handles.fit_75_lo;
fit_75_hi=handles.fit_75_hi;
pleis=handles.pleis;
time_rej=handles.time_rej;
fract_pleis_75_hi=handles.fract_pleis_75_hi;
fract_pleis_75_lo=handles.fract_pleis_75_lo;
outlier_cutoff_75 = str2num(get(handles.outlier_cutoff_75,'String'));
reject_poly_order = str2num(get(handles.reject_poly_order,'String'));
reject_spline_breaks = str2num(get(handles.reject_spline_breaks,'String'));
errprop = handles.errprop;

			rad_on_outliers=get(handles.uipanel_outliers,'selectedobject');
			switch rad_on_outliers
			case {handles.radio_reject_poly, handles.radio_reject_spline}

			model_75_hi=handles.model_75_hi;
			model_75_lo=handles.model_75_lo;
			model_75_hi=handles.model_75_hi;
			model_75_lo=handles.model_75_lo;
			model_75_hi=handles.model_75_hi;
			model_75_lo=handles.model_75_lo;
			model_75_hi=handles.model_75_hi;
			model_75_lo=handles.model_75_lo;

			end
		
if errprop == 0
drift_err_75_env=handles.drift_err_75_env;
else
drift_err_75_win=handles.drift_err_75_win;
end

			rad_on_error=get(handles.uipanel_error_prop_type,'selectedobject');
			switch rad_on_error
			case handles.radio_errorprop_envelope
			if exist('drift_err_75_env','var') == 0
			err_dlg=errordlg('Data was reduced using a sliding window. You will need to re-reduce data set with fitted envelope error propagation','Hang on a sec...');
			waitfor(err_dlg);
			else
			end
			case handles.radio_errorprop_sliding
			if exist('drift_err_75_win','var') == 0
			err_dlg=errordlg('Data was reduced using a sliding window. You will need to re-reduce data set with sliding window error propagation','Wait!');
			waitfor(err_dlg);
			else
			drift_err_75_win=handles.drift_err_75_win;
			end
			end
			
		rad_on=get(handles.uipanel_plot_type,'selectedobject');
        switch rad_on
        case handles.radio_measured_ratios

		frac_corr_pleis_Pb207_U235_nz_meas = nonzeros(pleis.*corr_Pb207_U235); %measured ratios
		fract_pleis_75_hi_meas = frac_corr_pleis_Pb207_U235_nz_meas + (frac_corr_pleis_Pb207_U235_nz_meas.*(frac_corr_pleis_Pb207_U235_nz_err.*0.01));
		fract_pleis_75_lo_meas = frac_corr_pleis_Pb207_U235_nz_meas - (frac_corr_pleis_Pb207_U235_nz_meas.*(frac_corr_pleis_Pb207_U235_nz_err.*0.01));
		frac_corr_pleis_rej_75_meas = pleis_Pb207_U235_known./frac_corr_pleis_rej_75; %measured ratios
		fit_75_meas = pleis_Pb207_U235_known./fit_75;
		fit_75_hi_meas = pleis_Pb207_U235_known./fit_75_hi;
		fit_75_lo_meas = pleis_Pb207_U235_known./fit_75_lo;

			rad_on_outliers=get(handles.uipanel_outliers,'selectedobject');
			switch rad_on_outliers
			case handles.radio_none
			case handles.radio_reject_poly

			model_75_pleis_meas = polyfit(pleis_time,pleis_Pb207_U235_known./frac_corr_pleis_Pb207_U235_nz,reject_poly_order);
			model_75_meas = polyval(model_75_pleis_meas,time);
			model_75_hi_meas = model_75_meas + model_75_meas.*outlier_cutoff_75.*.01;
			model_75_lo_meas = model_75_meas - model_75_meas.*outlier_cutoff_75.*.01;

		    case handles.radio_reject_spline

			model_75_pleis_meas = splinefit(pleis_time,pleis_Pb207_U235_known./frac_corr_pleis_Pb207_U235_nz,reject_spline_breaks);
			model_75_meas = ppval(model_75_pleis_meas,time);
			model_75_hi_meas = model_75_meas + model_75_meas.*outlier_cutoff_75.*.01;
			model_75_lo_meas = model_75_meas - model_75_meas.*outlier_cutoff_75.*.01;

			end

		axes(handles.axes_bias);
			
			rad_on_error=get(handles.uipanel_error_prop_type,'selectedobject');
			switch rad_on_error
			case handles.radio_errorprop_envelope
			if exist('drift_err_75_env','var')
			f=vertcat(fit_75_lo_meas,flipud(fit_75_hi_meas));
			fill(vertcat(time, flipud(time)),vertcat(fit_75_lo_meas,flipud(fit_75_hi_meas)), 'b','FaceAlpha',.3,'EdgeAlpha',.3)
			end
			case handles.radio_errorprop_sliding
			if exist('drift_err_75_win','var')
			f=vertcat(fit_75_meas-(drift_err_75_win.*0.01.*fit_75_meas),flipud(fit_75_meas+(drift_err_75_win.*0.01.*fit_75_meas)));
			fill(vertcat(time, flipud(time)),vertcat(fit_75_meas-(drift_err_75_win.*0.01.*fit_75_meas),flipud(fit_75_meas+(drift_err_75_win.*0.01.*fit_75_meas))), 'b','FaceAlpha',.3,'EdgeAlpha',.3)
			end
			end
		
		hold on
		plot(time,fit_75_meas, 'r','LineWidth',2)
		e75=errorbar(pleis_time,frac_corr_pleis_Pb207_U235_nz_meas,(frac_corr_pleis_Pb207_U235_nz_meas.*(frac_corr_pleis_Pb207_U235_nz_err.*0.01)),'o','MarkerSize',...
		5,'MarkerEdgeColor','k','MarkerFaceColor', 'k');
		scatter(time_rej, frac_corr_pleis_rej_75_meas, 100, 'r', 'filled')

			rad_on_outliers=get(handles.uipanel_outliers,'selectedobject');
			switch rad_on_outliers
			case handles.radio_none

			max_all_75_meas = max(vertcat(fit_75_hi_meas,frac_corr_pleis_Pb207_U235_nz_meas, fit_75_meas, fract_pleis_75_hi_meas, f));
			min_all_75_meas = min(vertcat(fit_75_lo_meas, frac_corr_pleis_Pb207_U235_nz_meas, fit_75_meas, fract_pleis_75_lo_meas, f));
			axis([min(time) max(time) min_all_75_meas max_all_75_meas]);

			case handles.radio_reject_poly

			plot(time, model_75_hi_meas, 'r')
			plot(time, model_75_lo_meas, 'r')
			max_all_75_meas = max(vertcat(fit_75_hi_meas,frac_corr_pleis_Pb207_U235_nz_meas, fit_75_meas, model_75_hi_meas, fract_pleis_75_hi_meas, f));
			min_all_75_meas = min(vertcat(fit_75_lo_meas, frac_corr_pleis_Pb207_U235_nz_meas, fit_75_meas, model_75_lo_meas, fract_pleis_75_lo_meas, f));
			axis([min(time) max(time) min_all_75_meas max_all_75_meas]);

		    case handles.radio_reject_spline

			plot(time, model_75_hi_meas, 'r')
			plot(time, model_75_lo_meas, 'r')
			max_all_75_meas = max(vertcat(fit_75_hi_meas,frac_corr_pleis_Pb207_U235_nz_meas, fit_75_meas, model_75_hi_meas, fract_pleis_75_hi_meas)), f;
			min_all_75_meas = min(vertcat(fit_75_lo_meas, frac_corr_pleis_Pb207_U235_nz_meas, fit_75_meas, model_75_lo_meas, fract_pleis_75_lo_meas)), f;
			axis([min(time) max(time) min_all_75_meas max_all_75_meas]);

			end
		
		hold off
		title('Pb206/U238 Session drift')
		xlabel('Decimal time')
		ylabel('Measured Pb206/U238')

		case handles.radio_fract_factor

			rad_on_outliers=get(handles.uipanel_outliers,'selectedobject');
			switch rad_on_outliers
			case handles.radio_none
			case handles.radio_reject_poly

			model_75_pleis = polyfit(pleis_time,frac_corr_pleis_Pb207_U235_nz,reject_poly_order);
			model_75 = polyval(model_75_pleis,time);
			model_75_hi = model_75 + model_75.*outlier_cutoff_75.*.01;
			model_75_lo = model_75 - model_75.*outlier_cutoff_75.*.01;

		    case handles.radio_reject_spline

			model_75_pleis = splinefit(pleis_time,frac_corr_pleis_Pb207_U235_nz,reject_spline_breaks);
			model_75 = ppval(model_75_pleis,time);
			model_75_hi = model_75 + model_75.*outlier_cutoff_75.*.01;
			model_75_lo = model_75 - model_75.*outlier_cutoff_75.*.01;

			end

		axes(handles.axes_bias);

			rad_on_error=get(handles.uipanel_error_prop_type,'selectedobject');
			switch rad_on_error
			case handles.radio_errorprop_envelope
			f=vertcat(fit_75_lo,flipud(fit_75_hi));
			fill(vertcat(time, flipud(time)),vertcat(fit_75_lo,flipud(fit_75_hi)), 'b','FaceAlpha',.3,'EdgeAlpha',.3)
			case handles.radio_errorprop_sliding
			f=vertcat(fit_75-(drift_err_75_win.*0.01.*fit_75),flipud(fit_75+(drift_err_75_win.*0.01.*fit_75)));
			fill(vertcat(time, flipud(time)),vertcat(fit_75-(drift_err_75_win.*0.01.*fit_75),flipud(fit_75+(drift_err_75_win.*0.01.*fit_75))), 'b','FaceAlpha',.3,'EdgeAlpha',.3)
			end

		hold on
		plot(time,fit_75, 'r','LineWidth',2)
		e75=errorbar(pleis_time,frac_corr_pleis_Pb207_U235_nz,(frac_corr_pleis_Pb207_U235_nz.*(frac_corr_pleis_Pb207_U235_nz_err.*0.01)),'o','MarkerSize',...
		5,'MarkerEdgeColor','k','MarkerFaceColor', 'k');

			rad_on_outliers=get(handles.uipanel_outliers,'selectedobject');
			switch rad_on_outliers
			case handles.radio_none

		max_all_75 = max(vertcat(fit_75_hi,frac_corr_pleis_Pb207_U235_nz, fit_75, fract_pleis_75_hi, f));
		min_all_75 = min(vertcat(fit_75_lo,frac_corr_pleis_Pb207_U235_nz, fit_75, fract_pleis_75_lo, f));
		axis([min(time) max(time) min(min_all_75) max(max_all_75)]);

			case {handles.radio_reject_poly, handles.radio_reject_spline}

		plot(time, model_75_hi, 'r')
		plot(time, model_75_lo, 'r')
		max_all_75 = max(vertcat(fit_75_hi,frac_corr_pleis_Pb207_U235_nz, fit_75, model_75_hi, fract_pleis_75_hi, f));
		min_all_75 = min(vertcat(fit_75_lo,frac_corr_pleis_Pb207_U235_nz, fit_75, model_75_lo, fract_pleis_75_lo, f));
		axis([min(time) max(time) min(min_all_75) max(max_all_75)]);

			end

		scatter(time_rej, frac_corr_pleis_rej_75, 100, 'r', 'filled')
		hold off
		title('Pb206/U238 Session drift')
		xlabel('Decimal time')
		ylabel('Pb206/U238 fractionation factor')
		end

if exist('err_dlg','var')
cla(handles.axes_bias,'reset');
end

guidata(hObject,handles);

%% PUSHBUTTON PLOT Pb208/Th232 SESSION DRIFT %%
function plot_fract_82_Callback(hObject, eventdata, handles)
cla(handles.axes_bias,'reset');
time=handles.time;
pleis_time=handles.pleis_time;
frac_corr_pleis_Pb208_Th232_nz=handles.frac_corr_pleis_Pb208_Th232_nz;
frac_corr_pleis_Pb208_Th232_nz_err=handles.frac_corr_pleis_Pb208_Th232_nz_err;
frac_corr_pleis_rej_82=handles.frac_corr_pleis_rej_82;
corr_Pb208_Th232=handles.corr_Pb208_Th232;
pleis_Pb208_Th232_known=handles.pleis_Pb208_Th232_known;
fit_82=handles.fit_82;
fit_82_lo=handles.fit_82_lo;
fit_82_hi=handles.fit_82_hi;
pleis=handles.pleis;
time_rej=handles.time_rej;
fract_pleis_82_hi=handles.fract_pleis_82_hi;
fract_pleis_82_lo=handles.fract_pleis_82_lo;
outlier_cutoff_82 = str2num(get(handles.outlier_cutoff_82,'String'));
reject_poly_order = str2num(get(handles.reject_poly_order,'String'));
reject_spline_breaks = str2num(get(handles.reject_spline_breaks,'String'));
errprop = handles.errprop;

			rad_on_outliers=get(handles.uipanel_outliers,'selectedobject');
			switch rad_on_outliers
			case {handles.radio_reject_poly, handles.radio_reject_spline}

			model_82_hi=handles.model_82_hi;
			model_82_lo=handles.model_82_lo;
			model_82_hi=handles.model_82_hi;
			model_82_lo=handles.model_82_lo;
			model_82_hi=handles.model_82_hi;
			model_82_lo=handles.model_82_lo;
			model_82_hi=handles.model_82_hi;
			model_82_lo=handles.model_82_lo;

			end
		
if errprop == 0
drift_err_82_env=handles.drift_err_82_env;
else
drift_err_82_win=handles.drift_err_82_win;
end

			rad_on_error=get(handles.uipanel_error_prop_type,'selectedobject');
			switch rad_on_error
			case handles.radio_errorprop_envelope
			if exist('drift_err_82_env','var') == 0
			err_dlg=errordlg('Data was reduced using a sliding window. You will need to re-reduce data set with fitted envelope error propagation','Hang on a sec...');
			waitfor(err_dlg);
			else
			end
			case handles.radio_errorprop_sliding
			if exist('drift_err_82_win','var') == 0
			err_dlg=errordlg('Data was reduced using a sliding window. You will need to re-reduce data set with sliding window error propagation','Wait!');
			waitfor(err_dlg);
			else
			drift_err_82_win=handles.drift_err_82_win;
			end
			end
			
		rad_on=get(handles.uipanel_plot_type,'selectedobject');
        switch rad_on
        case handles.radio_measured_ratios

		frac_corr_pleis_Pb208_Th232_nz_meas = nonzeros(pleis.*corr_Pb208_Th232); %measured ratios
		fract_pleis_82_hi_meas = frac_corr_pleis_Pb208_Th232_nz_meas + (frac_corr_pleis_Pb208_Th232_nz_meas.*(frac_corr_pleis_Pb208_Th232_nz_err.*0.01));
		fract_pleis_82_lo_meas = frac_corr_pleis_Pb208_Th232_nz_meas - (frac_corr_pleis_Pb208_Th232_nz_meas.*(frac_corr_pleis_Pb208_Th232_nz_err.*0.01));
		frac_corr_pleis_rej_82_meas = pleis_Pb208_Th232_known./frac_corr_pleis_rej_82; %measured ratios
		fit_82_meas = pleis_Pb208_Th232_known./fit_82;
		fit_82_hi_meas = pleis_Pb208_Th232_known./fit_82_hi;
		fit_82_lo_meas = pleis_Pb208_Th232_known./fit_82_lo;

			rad_on_outliers=get(handles.uipanel_outliers,'selectedobject');
			switch rad_on_outliers
			case handles.radio_none
			case handles.radio_reject_poly

			model_82_pleis_meas = polyfit(pleis_time,pleis_Pb208_Th232_known./frac_corr_pleis_Pb208_Th232_nz,reject_poly_order);
			model_82_meas = polyval(model_82_pleis_meas,time);
			model_82_hi_meas = model_82_meas + model_82_meas.*outlier_cutoff_82.*.01;
			model_82_lo_meas = model_82_meas - model_82_meas.*outlier_cutoff_82.*.01;

		    case handles.radio_reject_spline

			model_82_pleis_meas = splinefit(pleis_time,pleis_Pb208_Th232_known./frac_corr_pleis_Pb208_Th232_nz,reject_spline_breaks);
			model_82_meas = ppval(model_82_pleis_meas,time);
			model_82_hi_meas = model_82_meas + model_82_meas.*outlier_cutoff_82.*.01;
			model_82_lo_meas = model_82_meas - model_82_meas.*outlier_cutoff_82.*.01;

			end

		axes(handles.axes_bias);
			
			rad_on_error=get(handles.uipanel_error_prop_type,'selectedobject');
			switch rad_on_error
			case handles.radio_errorprop_envelope
			if exist('drift_err_82_env','var')
			f=vertcat(fit_82_lo_meas,flipud(fit_82_hi_meas));
			fill(vertcat(time, flipud(time)),vertcat(fit_82_lo_meas,flipud(fit_82_hi_meas)), 'b','FaceAlpha',.3,'EdgeAlpha',.3)
			end
			case handles.radio_errorprop_sliding
			if exist('drift_err_82_win','var')
			f=vertcat(fit_82_meas-(drift_err_82_win.*0.01.*fit_82_meas),flipud(fit_82_meas+(drift_err_82_win.*0.01.*fit_82_meas)));
			fill(vertcat(time, flipud(time)),vertcat(fit_82_meas-(drift_err_82_win.*0.01.*fit_82_meas),flipud(fit_82_meas+(drift_err_82_win.*0.01.*fit_82_meas))), 'b','FaceAlpha',.3,'EdgeAlpha',.3)
			end
			end
		
		hold on
		plot(time,fit_82_meas, 'r','LineWidth',2)
		e82=errorbar(pleis_time,frac_corr_pleis_Pb208_Th232_nz_meas,(frac_corr_pleis_Pb208_Th232_nz_meas.*(frac_corr_pleis_Pb208_Th232_nz_err.*0.01)),'o','MarkerSize',...
		5,'MarkerEdgeColor','k','MarkerFaceColor', 'k');
		scatter(time_rej, frac_corr_pleis_rej_82_meas, 100, 'r', 'filled')

			rad_on_outliers=get(handles.uipanel_outliers,'selectedobject');
			switch rad_on_outliers
			case handles.radio_none

			max_all_82_meas = max(vertcat(fit_82_hi_meas,frac_corr_pleis_Pb208_Th232_nz_meas, fit_82_meas, fract_pleis_82_hi_meas, f));
			min_all_82_meas = min(vertcat(fit_82_lo_meas, frac_corr_pleis_Pb208_Th232_nz_meas, fit_82_meas, fract_pleis_82_lo_meas, f));
			axis([min(time) max(time) min_all_82_meas max_all_82_meas]);

			case handles.radio_reject_poly

			plot(time, model_82_hi_meas, 'r')
			plot(time, model_82_lo_meas, 'r')
			max_all_82_meas = max(vertcat(fit_82_hi_meas,frac_corr_pleis_Pb208_Th232_nz_meas, fit_82_meas, model_82_hi_meas, fract_pleis_82_hi_meas, f));
			min_all_82_meas = min(vertcat(fit_82_lo_meas, frac_corr_pleis_Pb208_Th232_nz_meas, fit_82_meas, model_82_lo_meas, fract_pleis_82_lo_meas, f));
			axis([min(time) max(time) min_all_82_meas max_all_82_meas]);

		    case handles.radio_reject_spline

			plot(time, model_82_hi_meas, 'r')
			plot(time, model_82_lo_meas, 'r')
			max_all_82_meas = max(vertcat(fit_82_hi_meas,frac_corr_pleis_Pb208_Th232_nz_meas, fit_82_meas, model_82_hi_meas, fract_pleis_82_hi_meas)), f;
			min_all_82_meas = min(vertcat(fit_82_lo_meas, frac_corr_pleis_Pb208_Th232_nz_meas, fit_82_meas, model_82_lo_meas, fract_pleis_82_lo_meas)), f;
			axis([min(time) max(time) min_all_82_meas max_all_82_meas]);

			end
		
		hold off
		title('Pb206/U238 Session drift')
		xlabel('Decimal time')
		ylabel('Measured Pb206/U238')

		case handles.radio_fract_factor

			rad_on_outliers=get(handles.uipanel_outliers,'selectedobject');
			switch rad_on_outliers
			case handles.radio_none
			case handles.radio_reject_poly

			model_82_pleis = polyfit(pleis_time,frac_corr_pleis_Pb208_Th232_nz,reject_poly_order);
			model_82 = polyval(model_82_pleis,time);
			model_82_hi = model_82 + model_82.*outlier_cutoff_82.*.01;
			model_82_lo = model_82 - model_82.*outlier_cutoff_82.*.01;

		    case handles.radio_reject_spline

			model_82_pleis = splinefit(pleis_time,frac_corr_pleis_Pb208_Th232_nz,reject_spline_breaks);
			model_82 = ppval(model_82_pleis,time);
			model_82_hi = model_82 + model_82.*outlier_cutoff_82.*.01;
			model_82_lo = model_82 - model_82.*outlier_cutoff_82.*.01;

			end

		axes(handles.axes_bias);

			rad_on_error=get(handles.uipanel_error_prop_type,'selectedobject');
			switch rad_on_error
			case handles.radio_errorprop_envelope
			f=vertcat(fit_82_lo,flipud(fit_82_hi));
			fill(vertcat(time, flipud(time)),vertcat(fit_82_lo,flipud(fit_82_hi)), 'b','FaceAlpha',.3,'EdgeAlpha',.3)
			case handles.radio_errorprop_sliding
			f=vertcat(fit_82-(drift_err_82_win.*0.01.*fit_82),flipud(fit_82+(drift_err_82_win.*0.01.*fit_82)));
			fill(vertcat(time, flipud(time)),vertcat(fit_82-(drift_err_82_win.*0.01.*fit_82),flipud(fit_82+(drift_err_82_win.*0.01.*fit_82))), 'b','FaceAlpha',.3,'EdgeAlpha',.3)
			end

		hold on
		plot(time,fit_82, 'r','LineWidth',2)
		e82=errorbar(pleis_time,frac_corr_pleis_Pb208_Th232_nz,(frac_corr_pleis_Pb208_Th232_nz.*(frac_corr_pleis_Pb208_Th232_nz_err.*0.01)),'o','MarkerSize',...
		5,'MarkerEdgeColor','k','MarkerFaceColor', 'k');

			rad_on_outliers=get(handles.uipanel_outliers,'selectedobject');
			switch rad_on_outliers
			case handles.radio_none

		max_all_82 = max(vertcat(fit_82_hi,frac_corr_pleis_Pb208_Th232_nz, fit_82, fract_pleis_82_hi, f));
		min_all_82 = min(vertcat(fit_82_lo,frac_corr_pleis_Pb208_Th232_nz, fit_82, fract_pleis_82_lo, f));
		axis([min(time) max(time) min(min_all_82) max(max_all_82)]);

			case {handles.radio_reject_poly, handles.radio_reject_spline}

		plot(time, model_82_hi, 'r')
		plot(time, model_82_lo, 'r')
		max_all_82 = max(vertcat(fit_82_hi,frac_corr_pleis_Pb208_Th232_nz, fit_82, model_82_hi, fract_pleis_82_hi, f));
		min_all_82 = min(vertcat(fit_82_lo,frac_corr_pleis_Pb208_Th232_nz, fit_82, model_82_lo, fract_pleis_82_lo, f));
		axis([min(time) max(time) min(min_all_82) max(max_all_82)]);

			end

		scatter(time_rej, frac_corr_pleis_rej_82, 100, 'r', 'filled')
		hold off
		title('Pb206/U238 Session drift')
		xlabel('Decimal time')
		ylabel('Pb206/U238 fractionation factor')
		end

if exist('err_dlg','var')
cla(handles.axes_bias,'reset');
end

guidata(hObject,handles);

%% LISTBOX %%
function listbox1_Callback(hObject, eventdata, handles)

cla(handles.axes_current_intensities,'reset');
cla(handles.axes_current_concordia,'reset');

data_ind = handles.data_ind;
name = handles.name;
t_BL_trim_length = handles.t_BL_trim_length;
%name_idx = handles.name_idx;
t_INT_trim = handles.t_INT_trim;
BL_xmin = handles.BL_xmin;
BL_xmax = handles.BL_xmax;
t_INT_trim_max_idx = handles.t_INT_trim_max_idx;
t_INT_trim_min_idx = handles.t_INT_trim_min_idx;
INT_xmax = handles.INT_xmax;
INT_xmin = handles.INT_xmin;
sigx_abs = handles.sigx_abs;
sigy_abs = handles.sigy_abs;
numpoints = handles.numpoints;
rho = handles.rho;
sigmarule = handles.sigmarule;
Pb207_U235 = handles.Pb207_U235;
Pb206_U238 = handles.Pb206_U238;
Pb207_U235_err = handles.Pb207_U235_err;
Pb206_U238_err = handles.Pb206_U238_err;
concordia_data = handles.concordia_data;
All_Pb206_U238_age = handles.All_Pb206_U238_age;
All_Pb206_U238_age_err = handles.All_Pb206_U238_age_err;
All_Pb207_Pb206_age = handles.All_Pb207_Pb206_age;
All_Pb207_Pb206_age_err = handles.All_Pb207_Pb206_age_err;
cutoff_76_68 = str2num(get(handles.filter_transition_68_76,'String'));

name_idx = get(handles.listbox1,'Value');

values = data_ind(:,3:11,name_idx);
values2 = values(any(values,2),:);
log_values = log10(values2);
log_values(~isfinite(log_values))=0;
t = data_ind(1:length(values2(:,1)),2,name_idx);
C = {[0 .5 0],[.5 0 0],[.5 .5 0],[0 .5 .5],[.5 0 .5],[0 0 1],[0 1 1],[1 0 1]}; % Cell array of colors

axes(handles.axes_current_intensities);
cla(handles.axes_current_intensities,'reset');
if get(handles.thick_lines,'Value')==1 
thickness = 1;
else
thickness = 0.5;
end

axes(handles.axes_current_intensities);
cla(handles.axes_current_intensities,'reset');
hold on
if get(handles.chk_Hg201,'Value')==1 
plot(t,log_values(:,1),'linewidth', thickness,'color',C{1});
end
if get(handles.chk_Hg202,'Value')==1 
plot(t,log_values(:,2),'linewidth', thickness,'color',C{2});
end
if get(handles.chk_Pb204,'Value')==1 
plot(t,log_values(:,3),'linewidth', thickness,'color',C{3});
end
if get(handles.chk_Pb206,'Value')==1 
plot(t,log_values(:,4),'linewidth', thickness,'color',C{4});
end
if get(handles.chk_Pb207,'Value')==1 
plot(t,log_values(:,5),'linewidth', thickness,'color',C{5});
end
if get(handles.chk_Pb208,'Value')==1 
plot(t,log_values(:,6),'linewidth', thickness,'color',C{6});
end
if get(handles.chk_Th232,'Value')==1 
plot(t,log_values(:,7),'linewidth', thickness,'color',C{7});
end
if get(handles.chk_U238,'Value')==1 
plot(t,log_values(:,8),'linewidth', thickness, 'color',C{8});
end

hold off
title('Sample intensity')
xlabel('time (seconds)')
ylabel('Intensity (log10 cps)')
axis([0 max(t) 2 max(max(log_values))+0.5])

Y1_BL_trim = log_values(1:t_BL_trim_length(1,length(name)),:);
Y1_BL_trim_min = min(Y1_BL_trim);
Y1_BL_trim_max = max(Y1_BL_trim);
Y1_BL_trim_min = 2;
Y1_BL_trim_max = max(Y1_BL_trim_max);
t_INT_trim_last = nonzeros(t_INT_trim(:,name_idx));
t_INT_trim_min = min(t_INT_trim_last);
t_INT_trim_min_idx = t_INT_trim_max_idx - length(t_INT_trim_last) + 1;
Y1_INT_trim = log_values(t_INT_trim_min_idx(1,name_idx):t_INT_trim_max_idx(1,name_idx),:);
values_INT_trim = values(t_INT_trim_min_idx:t_INT_trim_max_idx,:);
Y1_INT_trim_min = min(Y1_INT_trim);
Y1_INT_trim_max = max(Y1_INT_trim);
Y1_INT_trim_min = min(Y1_INT_trim_min);
Y1_INT_trim_max = max(Y1_INT_trim_max);

if get(handles.chk_windows,'Value')==1 
hold on
rectangle('Position',[BL_xmin Y1_BL_trim_min BL_xmax-BL_xmin Y1_BL_trim_max-Y1_BL_trim_min],'EdgeColor','k','LineWidth',2)
rectangle('Position',[INT_xmin(1,name_idx) Y1_INT_trim_min INT_xmax(1,name_idx)-INT_xmin(1,name_idx) Y1_INT_trim_max-Y1_INT_trim_min],'EdgeColor','k','LineWidth',2)
hold off

axes(handles.axes_current_concordia);

center=[concordia_data(name_idx,3),concordia_data(name_idx,5)];

sigx_sq = sigx_abs(name_idx,1).*sigx_abs(name_idx,1);
sigy_sq = sigy_abs(name_idx,1).*sigy_abs(name_idx,1);
rho_sigx_sigy = sigx_abs(name_idx,1).*sigy_abs(name_idx,1).*rho(name_idx,1);

covmat=[sigx_sq,rho_sigx_sigy;rho_sigx_sigy,sigy_sq];
[PD,PV]=eig(covmat);
PV=diag(PV).^.5;
theta=linspace(0,2.*pi,numpoints)';
elpt=[cos(theta),sin(theta)]*diag(PV)*PD';
numsigma=length(sigmarule);
elpt=repmat(elpt,1,numsigma).*repmat(sigmarule(floor(1:.5:numsigma+.5)),numpoints,1);
elpt=elpt+repmat(center,numpoints,numsigma);
plot(elpt(:,1:2:end),elpt(:,2:2:end),'b','LineWidth',2);
hold on

timemin = 0;
timemax = 4500000000;
timeinterval = 50000000;
time3 = timemin:timeinterval:timemax;

x = exp(0.00000000098485.*time3)-1;
y = exp(0.000000000155125.*time3)-1;

xaxismin = Pb207_U235(name_idx,1) - 0.6.*Pb207_U235(name_idx,1);
xaxismax = Pb207_U235(name_idx,1) + 0.3.*Pb207_U235(name_idx,1);
yaxismin = Pb206_U238(name_idx,1) - 0.3.*Pb206_U238(name_idx,1);
yaxismax = Pb206_U238(name_idx,1) + 0.3.*Pb206_U238(name_idx,1);

Pb206_U238_age = All_Pb206_U238_age(name_idx,1);
Pb206_U238_age_err = All_Pb206_U238_age_err(name_idx,1);

Pb207_Pb206_age = All_Pb207_Pb206_age(name_idx,1);
Pb207_Pb206_age_err = All_Pb207_Pb206_age_err(name_idx,1);

age_label_num = 0:50:4500;
for i=1:length(x)
if x(1,i) < xaxismax &&  x(1,i) > xaxismin && y(1,i) < yaxismax && y(1,i) > yaxismin
age_label4(i,1) = {sprintf('%.1f',age_label_num(1,i))};
x2(i,1) = x(1,i);
y2(i,1) = y(1,i);
age_label_num2(i,1) = age_label_num(1,i);
else
age_label4(i,1) = num2cell(9999);
x2(i,1) = 9999;
y2(i,1) = 9999;
age_label_num2(i,1) = 9999;
end
end

age_label5 = age_label4(~cellfun(@isempty, age_label4));
x2 = nonzeros(x2);
y2 = nonzeros(y2);
age_label_num2 = nonzeros(age_label_num2.*1000000);

age_label_x = exp(0.00000000098485.*age_label_num2)-1;
age_label_y = exp(0.000000000155125.*age_label_num2)-1;

plot(x,y,'k','LineWidth',1.4)
hold on
scatter(age_label_x, age_label_y,20,'MarkerEdgeColor','k','MarkerFaceColor','y','LineWidth',1.5)
labelpoints(age_label_x, age_label_y, age_label5, 'SE');

age_label3_x = Pb207_U235(name_idx,1);
age_label3_y = Pb206_U238(name_idx,1);

if Pb206_U238_age < cutoff_76_68
age_label3 = {Pb206_U238_age};
age_label4 = {Pb206_U238_age_err};
else
age_label3 = {Pb207_Pb206_age};
age_label4 = {Pb207_Pb206_age_err};
end

scatter(age_label3_x, age_label3_y, 200,'MarkerEdgeColor','k','MarkerFaceColor','g','LineWidth',1.5);
set(handles.text139, 'String', age_label3); 
set(handles.text141, 'String', age_label4); 
axis([xaxismin xaxismax yaxismin yaxismax]);
xlabel('207Pb/235U', 'FontSize', 7);
ylabel('206Pb/238U', 'FontSize', 7);

end

%% CHECKBOX WINDOWS %%
function chk_windows_Callback(hObject, eventdata, handles)
INT_xmax = handles.INT_xmax;
INT_xmin = handles.INT_xmin;
BL_xmin = str2num(get(handles.BL_min,'String'));
BL_xmax = str2num(get(handles.BL_max,'String'));
threshold_U238 = str2num(get(handles.threshold,'String'));
add_sec = str2num(get(handles.add_int,'String'));
int_time = str2num(get(handles.int_duration,'String'));
name_idx = get(handles.listbox1,'Value');
data_ind = handles.data_ind;
name = handles.name;
t_BL_trim_length = handles.t_BL_trim_length;
t_INT_trim = handles.t_INT_trim;
t_INT_trim_max_idx = handles.t_INT_trim_max_idx;
t_INT_trim_min_idx = handles.t_INT_trim_min_idx;

values = data_ind(:,3:11,name_idx);
values2 = values(any(values,2),:);
log_values = log10(values2);
log_values(~isfinite(log_values))=0;
t = data_ind(1:length(values2(:,1)),2,name_idx);
C = {[0 .5 0],[.5 0 0],[.5 .5 0],[0 .5 .5],[.5 0 .5],[0 0 1],[0 1 1],[1 0 1]}; % Cell array of colors

if get(handles.thick_lines,'Value')==1 
thickness = 1;
else
thickness = 0.5;
end

axes(handles.axes_current_intensities);
cla(handles.axes_current_intensities,'reset');
hold on
if get(handles.chk_Hg201,'Value')==1 
plot(t,log_values(:,1),'linewidth', thickness,'color',C{1});
end
if get(handles.chk_Hg202,'Value')==1 
plot(t,log_values(:,2),'linewidth', thickness,'color',C{2});
end
if get(handles.chk_Pb204,'Value')==1 
plot(t,log_values(:,3),'linewidth', thickness,'color',C{3});
end
if get(handles.chk_Pb206,'Value')==1 
plot(t,log_values(:,4),'linewidth', thickness,'color',C{4});
end
if get(handles.chk_Pb207,'Value')==1 
plot(t,log_values(:,5),'linewidth', thickness,'color',C{5});
end
if get(handles.chk_Pb208,'Value')==1 
plot(t,log_values(:,6),'linewidth', thickness,'color',C{6});
end
if get(handles.chk_Th232,'Value')==1 
plot(t,log_values(:,7),'linewidth', thickness,'color',C{7});
end
if get(handles.chk_U238,'Value')==1 
plot(t,log_values(:,8),'linewidth', thickness, 'color',C{8});
end

Y1_BL_trim = log_values(1:t_BL_trim_length(1,length(name)),:);
Y1_BL_trim_min = min(Y1_BL_trim);
Y1_BL_trim_max = max(Y1_BL_trim);
Y1_BL_trim_min = 2;
Y1_BL_trim_max = max(Y1_BL_trim_max);
t_INT_trim_last = nonzeros(t_INT_trim(:,name_idx));
t_INT_trim_min = min(t_INT_trim_last);
t_INT_trim_min_idx = t_INT_trim_max_idx - length(t_INT_trim_last) + 1;
Y1_INT_trim = log_values(t_INT_trim_min_idx(1,name_idx):t_INT_trim_max_idx(1,name_idx),:);
values_INT_trim = values(t_INT_trim_min_idx:t_INT_trim_max_idx,:);
Y1_INT_trim_min = min(Y1_INT_trim);
Y1_INT_trim_max = max(Y1_INT_trim);
Y1_INT_trim_min = min(Y1_INT_trim_min);
Y1_INT_trim_max = max(Y1_INT_trim_max);

hold off
title('Sample intensity')
xlabel('time (seconds)')
ylabel('Intensity (log10 cps)')
axis([0 max(t) 2 max(max(log_values))+0.5])

if get(handles.chk_windows,'Value')==1 
hold on
rectangle('Position',[BL_xmin Y1_BL_trim_min BL_xmax-BL_xmin Y1_BL_trim_max-Y1_BL_trim_min],'EdgeColor','k','LineWidth',2)
rectangle('Position',[INT_xmin(1,name_idx) Y1_INT_trim_min INT_xmax(1,name_idx)-INT_xmin(1,name_idx) Y1_INT_trim_max-Y1_INT_trim_min],'EdgeColor','k','LineWidth',2)
hold off
end

set(handles.axes_current_intensities,'FontSize',7);

guidata(hObject,handles);

%% CHECKBOX THICKER LINES %%
function thick_lines_Callback(hObject, eventdata, handles)
INT_xmax = handles.INT_xmax;
INT_xmin = handles.INT_xmin;
BL_xmin = str2num(get(handles.BL_min,'String'));
BL_xmax = str2num(get(handles.BL_max,'String'));
threshold_U238 = str2num(get(handles.threshold,'String'));
add_sec = str2num(get(handles.add_int,'String'));
int_time = str2num(get(handles.int_duration,'String'));
name_idx = get(handles.listbox1,'Value');
data_ind = handles.data_ind;
name = handles.name;
t_BL_trim_length = handles.t_BL_trim_length;
t_INT_trim = handles.t_INT_trim;
t_INT_trim_max_idx = handles.t_INT_trim_max_idx;
t_INT_trim_min_idx = handles.t_INT_trim_min_idx;

values = data_ind(:,3:11,name_idx);
values2 = values(any(values,2),:);
log_values = log10(values2);
log_values(~isfinite(log_values))=0;
t = data_ind(1:length(values2(:,1)),2,name_idx);
C = {[0 .5 0],[.5 0 0],[.5 .5 0],[0 .5 .5],[.5 0 .5],[0 0 1],[0 1 1],[1 0 1]}; % Cell array of colors

if get(handles.thick_lines,'Value')==1 
thickness = 1;
else
thickness = 0.5;
end

axes(handles.axes_current_intensities);
cla(handles.axes_current_intensities,'reset');
hold on
if get(handles.chk_Hg201,'Value')==1 
plot(t,log_values(:,1),'linewidth', thickness,'color',C{1});
end
if get(handles.chk_Hg202,'Value')==1 
plot(t,log_values(:,2),'linewidth', thickness,'color',C{2});
end
if get(handles.chk_Pb204,'Value')==1 
plot(t,log_values(:,3),'linewidth', thickness,'color',C{3});
end
if get(handles.chk_Pb206,'Value')==1 
plot(t,log_values(:,4),'linewidth', thickness,'color',C{4});
end
if get(handles.chk_Pb207,'Value')==1 
plot(t,log_values(:,5),'linewidth', thickness,'color',C{5});
end
if get(handles.chk_Pb208,'Value')==1 
plot(t,log_values(:,6),'linewidth', thickness,'color',C{6});
end
if get(handles.chk_Th232,'Value')==1 
plot(t,log_values(:,7),'linewidth', thickness,'color',C{7});
end
if get(handles.chk_U238,'Value')==1 
plot(t,log_values(:,8),'linewidth', thickness, 'color',C{8});
end

Y1_BL_trim = log_values(1:t_BL_trim_length(1,length(name)),:);
Y1_BL_trim_min = min(Y1_BL_trim);
Y1_BL_trim_max = max(Y1_BL_trim);
Y1_BL_trim_min = 2;
Y1_BL_trim_max = max(Y1_BL_trim_max);
t_INT_trim_last = nonzeros(t_INT_trim(:,name_idx));
t_INT_trim_min = min(t_INT_trim_last);
t_INT_trim_min_idx = t_INT_trim_max_idx - length(t_INT_trim_last) + 1;
Y1_INT_trim = log_values(t_INT_trim_min_idx(1,name_idx):t_INT_trim_max_idx(1,name_idx),:);
values_INT_trim = values(t_INT_trim_min_idx:t_INT_trim_max_idx,:);
Y1_INT_trim_min = min(Y1_INT_trim);
Y1_INT_trim_max = max(Y1_INT_trim);
Y1_INT_trim_min = min(Y1_INT_trim_min);
Y1_INT_trim_max = max(Y1_INT_trim_max);

hold off
title('Sample intensity')
xlabel('time (seconds)')
ylabel('Intensity (log10 cps)')
axis([0 max(t) 2 max(max(log_values))+0.5])

if get(handles.chk_windows,'Value')==1 
hold on
rectangle('Position',[BL_xmin Y1_BL_trim_min BL_xmax-BL_xmin Y1_BL_trim_max-Y1_BL_trim_min],'EdgeColor','k','LineWidth',2)
rectangle('Position',[INT_xmin(1,name_idx) Y1_INT_trim_min INT_xmax(1,name_idx)-INT_xmin(1,name_idx) Y1_INT_trim_max-Y1_INT_trim_min],'EdgeColor','k','LineWidth',2)
hold off
end

set(handles.axes_current_intensities,'FontSize',7);

guidata(hObject,handles);

%% CHECKBOX 201Hg %%
function chk_Hg201_Callback(hObject, eventdata, handles)
INT_xmax = handles.INT_xmax;
INT_xmin = handles.INT_xmin;
BL_xmin = str2num(get(handles.BL_min,'String'));
BL_xmax = str2num(get(handles.BL_max,'String'));
threshold_U238 = str2num(get(handles.threshold,'String'));
add_sec = str2num(get(handles.add_int,'String'));
int_time = str2num(get(handles.int_duration,'String'));
name_idx = get(handles.listbox1,'Value');
data_ind = handles.data_ind;
name = handles.name;
t_BL_trim_length = handles.t_BL_trim_length;
t_INT_trim = handles.t_INT_trim;
t_INT_trim_max_idx = handles.t_INT_trim_max_idx;
t_INT_trim_min_idx = handles.t_INT_trim_min_idx;

values = data_ind(:,3:11,name_idx);
values2 = values(any(values,2),:);
log_values = log10(values2);
log_values(~isfinite(log_values))=0;
t = data_ind(1:length(values2(:,1)),2,name_idx);
C = {[0 .5 0],[.5 0 0],[.5 .5 0],[0 .5 .5],[.5 0 .5],[0 0 1],[0 1 1],[1 0 1]}; % Cell array of colors

if get(handles.thick_lines,'Value')==1 
thickness = 1;
else
thickness = 0.5;
end

axes(handles.axes_current_intensities);
cla(handles.axes_current_intensities,'reset');
hold on
if get(handles.chk_Hg201,'Value')==1 
plot(t,log_values(:,1),'linewidth', thickness,'color',C{1});
end
if get(handles.chk_Hg202,'Value')==1 
plot(t,log_values(:,2),'linewidth', thickness,'color',C{2});
end
if get(handles.chk_Pb204,'Value')==1 
plot(t,log_values(:,3),'linewidth', thickness,'color',C{3});
end
if get(handles.chk_Pb206,'Value')==1 
plot(t,log_values(:,4),'linewidth', thickness,'color',C{4});
end
if get(handles.chk_Pb207,'Value')==1 
plot(t,log_values(:,5),'linewidth', thickness,'color',C{5});
end
if get(handles.chk_Pb208,'Value')==1 
plot(t,log_values(:,6),'linewidth', thickness,'color',C{6});
end
if get(handles.chk_Th232,'Value')==1 
plot(t,log_values(:,7),'linewidth', thickness,'color',C{7});
end
if get(handles.chk_U238,'Value')==1 
plot(t,log_values(:,8),'linewidth', thickness, 'color',C{8});
end

Y1_BL_trim = log_values(1:t_BL_trim_length(1,length(name)),:);
Y1_BL_trim_min = min(Y1_BL_trim);
Y1_BL_trim_max = max(Y1_BL_trim);
Y1_BL_trim_min = 2;
Y1_BL_trim_max = max(Y1_BL_trim_max);
t_INT_trim_last = nonzeros(t_INT_trim(:,name_idx));
t_INT_trim_min = min(t_INT_trim_last);
t_INT_trim_min_idx = t_INT_trim_max_idx - length(t_INT_trim_last) + 1;
Y1_INT_trim = log_values(t_INT_trim_min_idx(1,name_idx):t_INT_trim_max_idx(1,name_idx),:);
values_INT_trim = values(t_INT_trim_min_idx:t_INT_trim_max_idx,:);
Y1_INT_trim_min = min(Y1_INT_trim);
Y1_INT_trim_max = max(Y1_INT_trim);
Y1_INT_trim_min = min(Y1_INT_trim_min);
Y1_INT_trim_max = max(Y1_INT_trim_max);

hold off
title('Sample intensity')
xlabel('time (seconds)')
ylabel('Intensity (log10 cps)')
axis([0 max(t) 2 max(max(log_values))+0.5])

if get(handles.chk_windows,'Value')==1 
hold on
rectangle('Position',[BL_xmin Y1_BL_trim_min BL_xmax-BL_xmin Y1_BL_trim_max-Y1_BL_trim_min],'EdgeColor','k','LineWidth',2)
rectangle('Position',[INT_xmin(1,name_idx) Y1_INT_trim_min INT_xmax(1,name_idx)-INT_xmin(1,name_idx) Y1_INT_trim_max-Y1_INT_trim_min],'EdgeColor','k','LineWidth',2)
hold off
end

set(handles.axes_current_intensities,'FontSize',7);

guidata(hObject,handles);

%% CHECKBOX 202Hg %%
function chk_Hg202_Callback(hObject, eventdata, handles)
INT_xmax = handles.INT_xmax;
INT_xmin = handles.INT_xmin;
BL_xmin = str2num(get(handles.BL_min,'String'));
BL_xmax = str2num(get(handles.BL_max,'String'));
threshold_U238 = str2num(get(handles.threshold,'String'));
add_sec = str2num(get(handles.add_int,'String'));
int_time = str2num(get(handles.int_duration,'String'));
name_idx = get(handles.listbox1,'Value');
data_ind = handles.data_ind;
name = handles.name;
t_BL_trim_length = handles.t_BL_trim_length;
t_INT_trim = handles.t_INT_trim;
t_INT_trim_max_idx = handles.t_INT_trim_max_idx;
t_INT_trim_min_idx = handles.t_INT_trim_min_idx;

values = data_ind(:,3:11,name_idx);
values2 = values(any(values,2),:);
log_values = log10(values2);
log_values(~isfinite(log_values))=0;
t = data_ind(1:length(values2(:,1)),2,name_idx);
C = {[0 .5 0],[.5 0 0],[.5 .5 0],[0 .5 .5],[.5 0 .5],[0 0 1],[0 1 1],[1 0 1]}; % Cell array of colors

if get(handles.thick_lines,'Value')==1 
thickness = 1;
else
thickness = 0.5;
end

axes(handles.axes_current_intensities);
cla(handles.axes_current_intensities,'reset');
hold on
if get(handles.chk_Hg201,'Value')==1 
plot(t,log_values(:,1),'linewidth', thickness,'color',C{1});
end
if get(handles.chk_Hg202,'Value')==1 
plot(t,log_values(:,2),'linewidth', thickness,'color',C{2});
end
if get(handles.chk_Pb204,'Value')==1 
plot(t,log_values(:,3),'linewidth', thickness,'color',C{3});
end
if get(handles.chk_Pb206,'Value')==1 
plot(t,log_values(:,4),'linewidth', thickness,'color',C{4});
end
if get(handles.chk_Pb207,'Value')==1 
plot(t,log_values(:,5),'linewidth', thickness,'color',C{5});
end
if get(handles.chk_Pb208,'Value')==1 
plot(t,log_values(:,6),'linewidth', thickness,'color',C{6});
end
if get(handles.chk_Th232,'Value')==1 
plot(t,log_values(:,7),'linewidth', thickness,'color',C{7});
end
if get(handles.chk_U238,'Value')==1 
plot(t,log_values(:,8),'linewidth', thickness, 'color',C{8});
end

Y1_BL_trim = log_values(1:t_BL_trim_length(1,length(name)),:);
Y1_BL_trim_min = min(Y1_BL_trim);
Y1_BL_trim_max = max(Y1_BL_trim);
Y1_BL_trim_min = 2;
Y1_BL_trim_max = max(Y1_BL_trim_max);
t_INT_trim_last = nonzeros(t_INT_trim(:,name_idx));
t_INT_trim_min = min(t_INT_trim_last);
t_INT_trim_min_idx = t_INT_trim_max_idx - length(t_INT_trim_last) + 1;
Y1_INT_trim = log_values(t_INT_trim_min_idx(1,name_idx):t_INT_trim_max_idx(1,name_idx),:);
values_INT_trim = values(t_INT_trim_min_idx:t_INT_trim_max_idx,:);
Y1_INT_trim_min = min(Y1_INT_trim);
Y1_INT_trim_max = max(Y1_INT_trim);
Y1_INT_trim_min = min(Y1_INT_trim_min);
Y1_INT_trim_max = max(Y1_INT_trim_max);

hold off
title('Sample intensity')
xlabel('time (seconds)')
ylabel('Intensity (log10 cps)')
axis([0 max(t) 2 max(max(log_values))+0.5])

if get(handles.chk_windows,'Value')==1 
hold on
rectangle('Position',[BL_xmin Y1_BL_trim_min BL_xmax-BL_xmin Y1_BL_trim_max-Y1_BL_trim_min],'EdgeColor','k','LineWidth',2)
rectangle('Position',[INT_xmin(1,name_idx) Y1_INT_trim_min INT_xmax(1,name_idx)-INT_xmin(1,name_idx) Y1_INT_trim_max-Y1_INT_trim_min],'EdgeColor','k','LineWidth',2)
hold off
end

set(handles.axes_current_intensities,'FontSize',7);

guidata(hObject,handles);

%% CHECKBOX 204Pb %%
function chk_Pb204_Callback(hObject, eventdata, handles)
INT_xmax = handles.INT_xmax;
INT_xmin = handles.INT_xmin;
BL_xmin = str2num(get(handles.BL_min,'String'));
BL_xmax = str2num(get(handles.BL_max,'String'));
threshold_U238 = str2num(get(handles.threshold,'String'));
add_sec = str2num(get(handles.add_int,'String'));
int_time = str2num(get(handles.int_duration,'String'));
name_idx = get(handles.listbox1,'Value');
data_ind = handles.data_ind;
name = handles.name;
t_BL_trim_length = handles.t_BL_trim_length;
t_INT_trim = handles.t_INT_trim;
t_INT_trim_max_idx = handles.t_INT_trim_max_idx;
t_INT_trim_min_idx = handles.t_INT_trim_min_idx;

values = data_ind(:,3:11,name_idx);
values2 = values(any(values,2),:);
log_values = log10(values2);
log_values(~isfinite(log_values))=0;
t = data_ind(1:length(values2(:,1)),2,name_idx);
C = {[0 .5 0],[.5 0 0],[.5 .5 0],[0 .5 .5],[.5 0 .5],[0 0 1],[0 1 1],[1 0 1]}; % Cell array of colors

if get(handles.thick_lines,'Value')==1 
thickness = 1;
else
thickness = 0.5;
end

axes(handles.axes_current_intensities);
cla(handles.axes_current_intensities,'reset');
hold on
if get(handles.chk_Hg201,'Value')==1 
plot(t,log_values(:,1),'linewidth', thickness,'color',C{1});
end
if get(handles.chk_Hg202,'Value')==1 
plot(t,log_values(:,2),'linewidth', thickness,'color',C{2});
end
if get(handles.chk_Pb204,'Value')==1 
plot(t,log_values(:,3),'linewidth', thickness,'color',C{3});
end
if get(handles.chk_Pb206,'Value')==1 
plot(t,log_values(:,4),'linewidth', thickness,'color',C{4});
end
if get(handles.chk_Pb207,'Value')==1 
plot(t,log_values(:,5),'linewidth', thickness,'color',C{5});
end
if get(handles.chk_Pb208,'Value')==1 
plot(t,log_values(:,6),'linewidth', thickness,'color',C{6});
end
if get(handles.chk_Th232,'Value')==1 
plot(t,log_values(:,7),'linewidth', thickness,'color',C{7});
end
if get(handles.chk_U238,'Value')==1 
plot(t,log_values(:,8),'linewidth', thickness, 'color',C{8});
end

Y1_BL_trim = log_values(1:t_BL_trim_length(1,length(name)),:);
Y1_BL_trim_min = min(Y1_BL_trim);
Y1_BL_trim_max = max(Y1_BL_trim);
Y1_BL_trim_min = 2;
Y1_BL_trim_max = max(Y1_BL_trim_max);
t_INT_trim_last = nonzeros(t_INT_trim(:,name_idx));
t_INT_trim_min = min(t_INT_trim_last);
t_INT_trim_min_idx = t_INT_trim_max_idx - length(t_INT_trim_last) + 1;
Y1_INT_trim = log_values(t_INT_trim_min_idx(1,name_idx):t_INT_trim_max_idx(1,name_idx),:);
values_INT_trim = values(t_INT_trim_min_idx:t_INT_trim_max_idx,:);
Y1_INT_trim_min = min(Y1_INT_trim);
Y1_INT_trim_max = max(Y1_INT_trim);
Y1_INT_trim_min = min(Y1_INT_trim_min);
Y1_INT_trim_max = max(Y1_INT_trim_max);

hold off
title('Sample intensity')
xlabel('time (seconds)')
ylabel('Intensity (log10 cps)')
axis([0 max(t) 2 max(max(log_values))+0.5])

if get(handles.chk_windows,'Value')==1 
hold on
rectangle('Position',[BL_xmin Y1_BL_trim_min BL_xmax-BL_xmin Y1_BL_trim_max-Y1_BL_trim_min],'EdgeColor','k','LineWidth',2)
rectangle('Position',[INT_xmin(1,name_idx) Y1_INT_trim_min INT_xmax(1,name_idx)-INT_xmin(1,name_idx) Y1_INT_trim_max-Y1_INT_trim_min],'EdgeColor','k','LineWidth',2)
hold off
end

set(handles.axes_current_intensities,'FontSize',7);

guidata(hObject,handles);

%% CHECKBOX 206Pb %%
function chk_Pb206_Callback(hObject, eventdata, handles)
INT_xmax = handles.INT_xmax;
INT_xmin = handles.INT_xmin;
BL_xmin = str2num(get(handles.BL_min,'String'));
BL_xmax = str2num(get(handles.BL_max,'String'));
threshold_U238 = str2num(get(handles.threshold,'String'));
add_sec = str2num(get(handles.add_int,'String'));
int_time = str2num(get(handles.int_duration,'String'));
name_idx = get(handles.listbox1,'Value');
data_ind = handles.data_ind;
name = handles.name;
t_BL_trim_length = handles.t_BL_trim_length;
t_INT_trim = handles.t_INT_trim;
t_INT_trim_max_idx = handles.t_INT_trim_max_idx;
t_INT_trim_min_idx = handles.t_INT_trim_min_idx;

values = data_ind(:,3:11,name_idx);
values2 = values(any(values,2),:);
log_values = log10(values2);
log_values(~isfinite(log_values))=0;
t = data_ind(1:length(values2(:,1)),2,name_idx);
C = {[0 .5 0],[.5 0 0],[.5 .5 0],[0 .5 .5],[.5 0 .5],[0 0 1],[0 1 1],[1 0 1]}; % Cell array of colors

if get(handles.thick_lines,'Value')==1 
thickness = 1;
else
thickness = 0.5;
end

axes(handles.axes_current_intensities);
cla(handles.axes_current_intensities,'reset');
hold on
if get(handles.chk_Hg201,'Value')==1 
plot(t,log_values(:,1),'linewidth', thickness,'color',C{1});
end
if get(handles.chk_Hg202,'Value')==1 
plot(t,log_values(:,2),'linewidth', thickness,'color',C{2});
end
if get(handles.chk_Pb204,'Value')==1 
plot(t,log_values(:,3),'linewidth', thickness,'color',C{3});
end
if get(handles.chk_Pb206,'Value')==1 
plot(t,log_values(:,4),'linewidth', thickness,'color',C{4});
end
if get(handles.chk_Pb207,'Value')==1 
plot(t,log_values(:,5),'linewidth', thickness,'color',C{5});
end
if get(handles.chk_Pb208,'Value')==1 
plot(t,log_values(:,6),'linewidth', thickness,'color',C{6});
end
if get(handles.chk_Th232,'Value')==1 
plot(t,log_values(:,7),'linewidth', thickness,'color',C{7});
end
if get(handles.chk_U238,'Value')==1 
plot(t,log_values(:,8),'linewidth', thickness, 'color',C{8});
end

Y1_BL_trim = log_values(1:t_BL_trim_length(1,length(name)),:);
Y1_BL_trim_min = min(Y1_BL_trim);
Y1_BL_trim_max = max(Y1_BL_trim);
Y1_BL_trim_min = 2;
Y1_BL_trim_max = max(Y1_BL_trim_max);
t_INT_trim_last = nonzeros(t_INT_trim(:,name_idx));
t_INT_trim_min = min(t_INT_trim_last);
t_INT_trim_min_idx = t_INT_trim_max_idx - length(t_INT_trim_last) + 1;
Y1_INT_trim = log_values(t_INT_trim_min_idx(1,name_idx):t_INT_trim_max_idx(1,name_idx),:);
values_INT_trim = values(t_INT_trim_min_idx:t_INT_trim_max_idx,:);
Y1_INT_trim_min = min(Y1_INT_trim);
Y1_INT_trim_max = max(Y1_INT_trim);
Y1_INT_trim_min = min(Y1_INT_trim_min);
Y1_INT_trim_max = max(Y1_INT_trim_max);

hold off
title('Sample intensity')
xlabel('time (seconds)')
ylabel('Intensity (log10 cps)')
axis([0 max(t) 2 max(max(log_values))+0.5])

if get(handles.chk_windows,'Value')==1 
hold on
rectangle('Position',[BL_xmin Y1_BL_trim_min BL_xmax-BL_xmin Y1_BL_trim_max-Y1_BL_trim_min],'EdgeColor','k','LineWidth',2)
rectangle('Position',[INT_xmin(1,name_idx) Y1_INT_trim_min INT_xmax(1,name_idx)-INT_xmin(1,name_idx) Y1_INT_trim_max-Y1_INT_trim_min],'EdgeColor','k','LineWidth',2)
hold off
end

set(handles.axes_current_intensities,'FontSize',7);

guidata(hObject,handles);

%% CHECKBOX 207Pb %%
function chk_Pb207_Callback(hObject, eventdata, handles)
INT_xmax = handles.INT_xmax;
INT_xmin = handles.INT_xmin;
BL_xmin = str2num(get(handles.BL_min,'String'));
BL_xmax = str2num(get(handles.BL_max,'String'));
threshold_U238 = str2num(get(handles.threshold,'String'));
add_sec = str2num(get(handles.add_int,'String'));
int_time = str2num(get(handles.int_duration,'String'));
name_idx = get(handles.listbox1,'Value');
data_ind = handles.data_ind;
name = handles.name;
t_BL_trim_length = handles.t_BL_trim_length;
t_INT_trim = handles.t_INT_trim;
t_INT_trim_max_idx = handles.t_INT_trim_max_idx;
t_INT_trim_min_idx = handles.t_INT_trim_min_idx;

values = data_ind(:,3:11,name_idx);
values2 = values(any(values,2),:);
log_values = log10(values2);
log_values(~isfinite(log_values))=0;
t = data_ind(1:length(values2(:,1)),2,name_idx);
C = {[0 .5 0],[.5 0 0],[.5 .5 0],[0 .5 .5],[.5 0 .5],[0 0 1],[0 1 1],[1 0 1]}; % Cell array of colors

if get(handles.thick_lines,'Value')==1 
thickness = 1;
else
thickness = 0.5;
end

axes(handles.axes_current_intensities);
cla(handles.axes_current_intensities,'reset');
hold on
if get(handles.chk_Hg201,'Value')==1 
plot(t,log_values(:,1),'linewidth', thickness,'color',C{1});
end
if get(handles.chk_Hg202,'Value')==1 
plot(t,log_values(:,2),'linewidth', thickness,'color',C{2});
end
if get(handles.chk_Pb204,'Value')==1 
plot(t,log_values(:,3),'linewidth', thickness,'color',C{3});
end
if get(handles.chk_Pb206,'Value')==1 
plot(t,log_values(:,4),'linewidth', thickness,'color',C{4});
end
if get(handles.chk_Pb207,'Value')==1 
plot(t,log_values(:,5),'linewidth', thickness,'color',C{5});
end
if get(handles.chk_Pb208,'Value')==1 
plot(t,log_values(:,6),'linewidth', thickness,'color',C{6});
end
if get(handles.chk_Th232,'Value')==1 
plot(t,log_values(:,7),'linewidth', thickness,'color',C{7});
end
if get(handles.chk_U238,'Value')==1 
plot(t,log_values(:,8),'linewidth', thickness, 'color',C{8});
end

Y1_BL_trim = log_values(1:t_BL_trim_length(1,length(name)),:);
Y1_BL_trim_min = min(Y1_BL_trim);
Y1_BL_trim_max = max(Y1_BL_trim);
Y1_BL_trim_min = 2;
Y1_BL_trim_max = max(Y1_BL_trim_max);
t_INT_trim_last = nonzeros(t_INT_trim(:,name_idx));
t_INT_trim_min = min(t_INT_trim_last);
t_INT_trim_min_idx = t_INT_trim_max_idx - length(t_INT_trim_last) + 1;
Y1_INT_trim = log_values(t_INT_trim_min_idx(1,name_idx):t_INT_trim_max_idx(1,name_idx),:);
values_INT_trim = values(t_INT_trim_min_idx:t_INT_trim_max_idx,:);
Y1_INT_trim_min = min(Y1_INT_trim);
Y1_INT_trim_max = max(Y1_INT_trim);
Y1_INT_trim_min = min(Y1_INT_trim_min);
Y1_INT_trim_max = max(Y1_INT_trim_max);

hold off
title('Sample intensity')
xlabel('time (seconds)')
ylabel('Intensity (log10 cps)')
axis([0 max(t) 2 max(max(log_values))+0.5])

if get(handles.chk_windows,'Value')==1 
hold on
rectangle('Position',[BL_xmin Y1_BL_trim_min BL_xmax-BL_xmin Y1_BL_trim_max-Y1_BL_trim_min],'EdgeColor','k','LineWidth',2)
rectangle('Position',[INT_xmin(1,name_idx) Y1_INT_trim_min INT_xmax(1,name_idx)-INT_xmin(1,name_idx) Y1_INT_trim_max-Y1_INT_trim_min],'EdgeColor','k','LineWidth',2)
hold off
end

set(handles.axes_current_intensities,'FontSize',7);

guidata(hObject,handles);

%% CHECKBOX 208Pb %%
function chk_Pb208_Callback(hObject, eventdata, handles)
INT_xmax = handles.INT_xmax;
INT_xmin = handles.INT_xmin;
BL_xmin = str2num(get(handles.BL_min,'String'));
BL_xmax = str2num(get(handles.BL_max,'String'));
threshold_U238 = str2num(get(handles.threshold,'String'));
add_sec = str2num(get(handles.add_int,'String'));
int_time = str2num(get(handles.int_duration,'String'));
name_idx = get(handles.listbox1,'Value');
data_ind = handles.data_ind;
name = handles.name;
t_BL_trim_length = handles.t_BL_trim_length;
t_INT_trim = handles.t_INT_trim;
t_INT_trim_max_idx = handles.t_INT_trim_max_idx;
t_INT_trim_min_idx = handles.t_INT_trim_min_idx;

values = data_ind(:,3:11,name_idx);
values2 = values(any(values,2),:);
log_values = log10(values2);
log_values(~isfinite(log_values))=0;
t = data_ind(1:length(values2(:,1)),2,name_idx);
C = {[0 .5 0],[.5 0 0],[.5 .5 0],[0 .5 .5],[.5 0 .5],[0 0 1],[0 1 1],[1 0 1]}; % Cell array of colors

if get(handles.thick_lines,'Value')==1 
thickness = 1;
else
thickness = 0.5;
end

axes(handles.axes_current_intensities);
cla(handles.axes_current_intensities,'reset');
hold on
if get(handles.chk_Hg201,'Value')==1 
plot(t,log_values(:,1),'linewidth', thickness,'color',C{1});
end
if get(handles.chk_Hg202,'Value')==1 
plot(t,log_values(:,2),'linewidth', thickness,'color',C{2});
end
if get(handles.chk_Pb204,'Value')==1 
plot(t,log_values(:,3),'linewidth', thickness,'color',C{3});
end
if get(handles.chk_Pb206,'Value')==1 
plot(t,log_values(:,4),'linewidth', thickness,'color',C{4});
end
if get(handles.chk_Pb207,'Value')==1 
plot(t,log_values(:,5),'linewidth', thickness,'color',C{5});
end
if get(handles.chk_Pb208,'Value')==1 
plot(t,log_values(:,6),'linewidth', thickness,'color',C{6});
end
if get(handles.chk_Th232,'Value')==1 
plot(t,log_values(:,7),'linewidth', thickness,'color',C{7});
end
if get(handles.chk_U238,'Value')==1 
plot(t,log_values(:,8),'linewidth', thickness, 'color',C{8});
end

Y1_BL_trim = log_values(1:t_BL_trim_length(1,length(name)),:);
Y1_BL_trim_min = min(Y1_BL_trim);
Y1_BL_trim_max = max(Y1_BL_trim);
Y1_BL_trim_min = 2;
Y1_BL_trim_max = max(Y1_BL_trim_max);
t_INT_trim_last = nonzeros(t_INT_trim(:,name_idx));
t_INT_trim_min = min(t_INT_trim_last);
t_INT_trim_min_idx = t_INT_trim_max_idx - length(t_INT_trim_last) + 1;
Y1_INT_trim = log_values(t_INT_trim_min_idx(1,name_idx):t_INT_trim_max_idx(1,name_idx),:);
values_INT_trim = values(t_INT_trim_min_idx:t_INT_trim_max_idx,:);
Y1_INT_trim_min = min(Y1_INT_trim);
Y1_INT_trim_max = max(Y1_INT_trim);
Y1_INT_trim_min = min(Y1_INT_trim_min);
Y1_INT_trim_max = max(Y1_INT_trim_max);

hold off
title('Sample intensity')
xlabel('time (seconds)')
ylabel('Intensity (log10 cps)')
axis([0 max(t) 2 max(max(log_values))+0.5])

if get(handles.chk_windows,'Value')==1 
hold on
rectangle('Position',[BL_xmin Y1_BL_trim_min BL_xmax-BL_xmin Y1_BL_trim_max-Y1_BL_trim_min],'EdgeColor','k','LineWidth',2)
rectangle('Position',[INT_xmin(1,name_idx) Y1_INT_trim_min INT_xmax(1,name_idx)-INT_xmin(1,name_idx) Y1_INT_trim_max-Y1_INT_trim_min],'EdgeColor','k','LineWidth',2)
hold off
end

set(handles.axes_current_intensities,'FontSize',7);

guidata(hObject,handles);

%% CHECKBOX 232Th %%
function chk_Th232_Callback(hObject, eventdata, handles)
INT_xmax = handles.INT_xmax;
INT_xmin = handles.INT_xmin;
BL_xmin = str2num(get(handles.BL_min,'String'));
BL_xmax = str2num(get(handles.BL_max,'String'));
threshold_U238 = str2num(get(handles.threshold,'String'));
add_sec = str2num(get(handles.add_int,'String'));
int_time = str2num(get(handles.int_duration,'String'));
name_idx = get(handles.listbox1,'Value');
data_ind = handles.data_ind;
name = handles.name;
t_BL_trim_length = handles.t_BL_trim_length;
t_INT_trim = handles.t_INT_trim;
t_INT_trim_max_idx = handles.t_INT_trim_max_idx;
t_INT_trim_min_idx = handles.t_INT_trim_min_idx;

values = data_ind(:,3:11,name_idx);
values2 = values(any(values,2),:);
log_values = log10(values2);
log_values(~isfinite(log_values))=0;
t = data_ind(1:length(values2(:,1)),2,name_idx);
C = {[0 .5 0],[.5 0 0],[.5 .5 0],[0 .5 .5],[.5 0 .5],[0 0 1],[0 1 1],[1 0 1]}; % Cell array of colors

if get(handles.thick_lines,'Value')==1 
thickness = 1;
else
thickness = 0.5;
end

axes(handles.axes_current_intensities);
cla(handles.axes_current_intensities,'reset');
hold on
if get(handles.chk_Hg201,'Value')==1 
plot(t,log_values(:,1),'linewidth', thickness,'color',C{1});
end
if get(handles.chk_Hg202,'Value')==1 
plot(t,log_values(:,2),'linewidth', thickness,'color',C{2});
end
if get(handles.chk_Pb204,'Value')==1 
plot(t,log_values(:,3),'linewidth', thickness,'color',C{3});
end
if get(handles.chk_Pb206,'Value')==1 
plot(t,log_values(:,4),'linewidth', thickness,'color',C{4});
end
if get(handles.chk_Pb207,'Value')==1 
plot(t,log_values(:,5),'linewidth', thickness,'color',C{5});
end
if get(handles.chk_Pb208,'Value')==1 
plot(t,log_values(:,6),'linewidth', thickness,'color',C{6});
end
if get(handles.chk_Th232,'Value')==1 
plot(t,log_values(:,7),'linewidth', thickness,'color',C{7});
end
if get(handles.chk_U238,'Value')==1 
plot(t,log_values(:,8),'linewidth', thickness, 'color',C{8});
end

Y1_BL_trim = log_values(1:t_BL_trim_length(1,length(name)),:);
Y1_BL_trim_min = min(Y1_BL_trim);
Y1_BL_trim_max = max(Y1_BL_trim);
Y1_BL_trim_min = 2;
Y1_BL_trim_max = max(Y1_BL_trim_max);
t_INT_trim_last = nonzeros(t_INT_trim(:,name_idx));
t_INT_trim_min = min(t_INT_trim_last);
t_INT_trim_min_idx = t_INT_trim_max_idx - length(t_INT_trim_last) + 1;
Y1_INT_trim = log_values(t_INT_trim_min_idx(1,name_idx):t_INT_trim_max_idx(1,name_idx),:);
values_INT_trim = values(t_INT_trim_min_idx:t_INT_trim_max_idx,:);
Y1_INT_trim_min = min(Y1_INT_trim);
Y1_INT_trim_max = max(Y1_INT_trim);
Y1_INT_trim_min = min(Y1_INT_trim_min);
Y1_INT_trim_max = max(Y1_INT_trim_max);

hold off
title('Sample intensity')
xlabel('time (seconds)')
ylabel('Intensity (log10 cps)')
axis([0 max(t) 2 max(max(log_values))+0.5])

if get(handles.chk_windows,'Value')==1 
hold on
rectangle('Position',[BL_xmin Y1_BL_trim_min BL_xmax-BL_xmin Y1_BL_trim_max-Y1_BL_trim_min],'EdgeColor','k','LineWidth',2)
rectangle('Position',[INT_xmin(1,name_idx) Y1_INT_trim_min INT_xmax(1,name_idx)-INT_xmin(1,name_idx) Y1_INT_trim_max-Y1_INT_trim_min],'EdgeColor','k','LineWidth',2)
hold off
end

set(handles.axes_current_intensities,'FontSize',7);

guidata(hObject,handles);

%% CHECKBOX 238U %%.
function chk_U238_Callback(hObject, eventdata, handles)
INT_xmax = handles.INT_xmax;
INT_xmin = handles.INT_xmin;
BL_xmin = str2num(get(handles.BL_min,'String'));
BL_xmax = str2num(get(handles.BL_max,'String'));
threshold_U238 = str2num(get(handles.threshold,'String'));
add_sec = str2num(get(handles.add_int,'String'));
int_time = str2num(get(handles.int_duration,'String'));
name_idx = get(handles.listbox1,'Value');
data_ind = handles.data_ind;
name = handles.name;
t_BL_trim_length = handles.t_BL_trim_length;
t_INT_trim = handles.t_INT_trim;
t_INT_trim_max_idx = handles.t_INT_trim_max_idx;
t_INT_trim_min_idx = handles.t_INT_trim_min_idx;

values = data_ind(:,3:11,name_idx);
values2 = values(any(values,2),:);
log_values = log10(values2);
log_values(~isfinite(log_values))=0;
t = data_ind(1:length(values2(:,1)),2,name_idx);
C = {[0 .5 0],[.5 0 0],[.5 .5 0],[0 .5 .5],[.5 0 .5],[0 0 1],[0 1 1],[1 0 1]}; % Cell array of colors

if get(handles.thick_lines,'Value')==1 
thickness = 1;
else
thickness = 0.5;
end

axes(handles.axes_current_intensities);
cla(handles.axes_current_intensities,'reset');
hold on
if get(handles.chk_Hg201,'Value')==1 
plot(t,log_values(:,1),'linewidth', thickness,'color',C{1});
end
if get(handles.chk_Hg202,'Value')==1 
plot(t,log_values(:,2),'linewidth', thickness,'color',C{2});
end
if get(handles.chk_Pb204,'Value')==1 
plot(t,log_values(:,3),'linewidth', thickness,'color',C{3});
end
if get(handles.chk_Pb206,'Value')==1 
plot(t,log_values(:,4),'linewidth', thickness,'color',C{4});
end
if get(handles.chk_Pb207,'Value')==1 
plot(t,log_values(:,5),'linewidth', thickness,'color',C{5});
end
if get(handles.chk_Pb208,'Value')==1 
plot(t,log_values(:,6),'linewidth', thickness,'color',C{6});
end
if get(handles.chk_Th232,'Value')==1 
plot(t,log_values(:,7),'linewidth', thickness,'color',C{7});
end
if get(handles.chk_U238,'Value')==1 
plot(t,log_values(:,8),'linewidth', thickness, 'color',C{8});
end

Y1_BL_trim = log_values(1:t_BL_trim_length(1,length(name)),:);
Y1_BL_trim_min = min(Y1_BL_trim);
Y1_BL_trim_max = max(Y1_BL_trim);
Y1_BL_trim_min = 2;
Y1_BL_trim_max = max(Y1_BL_trim_max);
t_INT_trim_last = nonzeros(t_INT_trim(:,name_idx));
t_INT_trim_min = min(t_INT_trim_last);
t_INT_trim_min_idx = t_INT_trim_max_idx - length(t_INT_trim_last) + 1;
Y1_INT_trim = log_values(t_INT_trim_min_idx(1,name_idx):t_INT_trim_max_idx(1,name_idx),:);
values_INT_trim = values(t_INT_trim_min_idx:t_INT_trim_max_idx,:);
Y1_INT_trim_min = min(Y1_INT_trim);
Y1_INT_trim_max = max(Y1_INT_trim);
Y1_INT_trim_min = min(Y1_INT_trim_min);
Y1_INT_trim_max = max(Y1_INT_trim_max);

hold off
title('Sample intensity')
xlabel('time (seconds)')
ylabel('Intensity (log10 cps)')
axis([0 max(t) 2 max(max(log_values))+0.5])

if get(handles.chk_windows,'Value')==1 
hold on
rectangle('Position',[BL_xmin Y1_BL_trim_min BL_xmax-BL_xmin Y1_BL_trim_max-Y1_BL_trim_min],'EdgeColor','k','LineWidth',2)
rectangle('Position',[INT_xmin(1,name_idx) Y1_INT_trim_min INT_xmax(1,name_idx)-INT_xmin(1,name_idx) Y1_INT_trim_max-Y1_INT_trim_min],'EdgeColor','k','LineWidth',2)
hold off
end

set(handles.axes_current_intensities,'FontSize',7);

guidata(hObject,handles);

%% REPLOT DISTRIBUTION %%
function replot_Callback(hObject, eventdata, handles)
cla(handles.axes_distribution,'reset'); 
set(handles.n_plotted,'String','?');
set(handles.optimize_text,'String','');
cla reset
set(gca,'xtick',[],'ytick',[],'Xcolor','w','Ycolor','w')
data1 = handles.data1;
data2 = handles.data2;
axes(handles.axes_distribution); 

rad_on_plot=get(handles.uipanel_plot,'selectedobject');
	switch rad_on_plot
    case handles.filt_data
dist_data = data1;
    case handles.rej_data
dist_data = data2;
    case handles.all_data
dist_data = vertcat(data1,data2);
	end

cla reset
set(gca,'xtick',[],'ytick',[],'Xcolor','w','Ycolor','w')
xmin = str2num(get(handles.xmin,'String'));
xmax = str2num(get(handles.xmax,'String'));
xint = str2num(get(handles.xint,'String'));
hist_ymin = str2num(get(handles.ymin,'String'));
hist_ymax = str2num(get(handles.ymax,'String'));
bins = str2num(get(handles.bins,'String'));

	rad_on_dist=get(handles.uipanel_distribution,'selectedobject');
	switch rad_on_dist
    case handles.radio_hist
	axes(handles.axes_distribution);    
	hist(dist_data(:,1), bins);
	set(gca,'box','off')
	axis([xmin xmax hist_ymin hist_ymax])
	ax1 = gca;
	set(ax1,'XColor','k','YColor','k')
	set(get(ax1,'Ylabel'),'String','frequency', 'FontSize', 7)    
	set(get(ax1,'Xlabel'),'String','Age (Ma)', 'FontSize', 7)

    case handles.radio_pdp
	axes(handles.axes_distribution);     
	x=xmin:xint:xmax;
	pdp=pdp5_2sig(dist_data(:,1),dist_data(:,2),xmin,xmax,xint);    
	hl1 = plot(x,pdp,'Color',[0.1 0.8 0.1]);
	ax1 = gca;
	set(ax1,'XColor','k','YColor','k')
	pdpmax = max(pdp);
	axis([xmin xmax 0 pdpmax+0.1*pdpmax])
	lgnd=legend('Probability Density Plot');
	set(hl1,'linewidth',2)
	set(gca,'box','off')
	ax1 = gca;
	set(ax1,'XColor','k','YColor','k')
	set(get(ax1,'Ylabel'),'String','probability', 'FontSize', 7)    
	set(get(ax1,'Xlabel'),'String','Age (Ma)', 'FontSize', 7)
	set(lgnd,'color','w');
	legend boxoff

    case handles.radio_kde
	axes(handles.axes_distribution);     

		rad_on_kernel=get(handles.uipanel_kernel,'selectedobject');
		switch rad_on_kernel
		case handles.optimize
		x=xmin:xint:xmax;
		a=xmin;
		b=xmax;
		c=xint;
		xA = a:c:b;
		xA = transpose(xA);
		tin=linspace(1,length(xA),length(xA));
		A = dist_data(:,1);
		n = length(A);
		[bandwidth,kdeA,xmesh1,cdf]=kde(A,length(tin),a,b);
		kdeA=transpose(interp1(xmesh1, kdeA, xA));
		hl1 = plot(tin,kdeA,'Color',[1 0 0]);
		ax1 = gca;
		set(ax1,'XColor','k','YColor','k')
		kdemax = max(kdeA);
		axis([xmin xmax 0 kdemax+0.2*kdemax])
		lgnd=legend('Kernel Density Estimate');
		set(hl1,'linewidth',2)
		set(gca,'box','off')
		ax1 = gca;
		set(ax1,'XColor','k','YColor','k')
		set(get(ax1,'Ylabel'),'String','probability', 'FontSize', 7)    
		set(get(ax1,'Xlabel'),'String','Age (Ma)', 'FontSize', 7) 
		set(handles.optimize_text, 'String', bandwidth); 
		set(lgnd,'color','w');
		legend boxoff

		case handles.Myr_kernel

		x=xmin:xint:xmax;
		kernel = str2num(get(handles.Myr_Kernel_text,'String'));
		kernel_dist_data(1:length(dist_data(:,1)),1) = kernel;
		kde1=pdp5_2sig(dist_data(:,1),kernel_dist_data,xmin,xmax,xint);    
		hl1 = plot(x,kde1,'Color',[1 0 0]);
		ax1 = gca;
		set(ax1,'XColor','k','YColor','k')
		pdpmax = max(kde1);
		axis([xmin xmax 0 pdpmax+0.2*pdpmax])
		lgnd=legend('Kernel Density Estimate');
		set(hl1,'linewidth',2)
		set(gca,'box','off')
		ax1 = gca;
		set(ax1,'XColor','k','YColor','k')
		set(get(ax1,'Ylabel'),'String','probability', 'FontSize', 7)    
		set(get(ax1,'Xlabel'),'String','Age (Ma)', 'FontSize', 7)
		set(lgnd,'color','w');
		legend boxoff
		end

    case handles.radio_hist_pdp
	axes(handles.axes_distribution);        
	x=xmin:xint:xmax;
	pdp=pdp5_2sig(dist_data(:,1),dist_data(:,2),xmin,xmax,xint);
	hist(dist_data(:,1), bins);
	set(gca,'box','off')
	axis([xmin xmax hist_ymin hist_ymax])
	ax1 = gca;
	set(ax1,'XColor','k','YColor','k')
	set(get(ax1,'Ylabel'),'String','frequency', 'FontSize', 7)
	xlabel('Age (Ma)', 'FontSize', 7)
	ax2 = axes('Units', 'character'); %create a new axis and set units to be character
	set(ax2, 'Position',get(ax1,'Position'),...
    'XAxisLocation','top',...
    'YAxisLocation','right',...
    'Color','none',...
    'XColor','k','YColor','k');
	hold on
	pdp=pdp5_2sig(dist_data(:,1),dist_data(:,2),xmin,xmax,xint);
	hl1 = plot(x,pdp,'Color',[0.1 0.8 0.1]);
	ax1 = gca;
	set(ax1,'XColor','k','YColor','k')
	pdpmax = max(pdp);
	axis([xmin xmax 0 pdpmax+0.1*pdpmax])
	set(gca,'xtick',[])
	set(get(ax2,'Ylabel'),'String','probability')
	lgnd=legend('Probability Density Plot');
	set(hl1,'linewidth',2)			
	set(lgnd,'color','w');
	legend boxoff

    case handles.radio_hist_kde
	axes(handles.axes_distribution);
 
 		rad_on_kernel=get(handles.uipanel_kernel,'selectedobject');
		switch rad_on_kernel
		case handles.optimize      

		hist(dist_data(:,1), bins);
		set(gca,'box','off')
		axis([xmin xmax hist_ymin hist_ymax])
		ax1 = gca;
		set(ax1,'XColor','k','YColor','k')
		set(get(ax1,'Ylabel'),'String','frequency', 'FontSize', 7)
		xlabel('Age (Ma)', 'FontSize', 7)
		ax2 = axes('Units', 'character'); %create a new axis and set units to be character
		set(ax2, 'Position',get(ax1,'Position'),...
        'XAxisLocation','top',...
        'YAxisLocation','right',...
        'Color','none',...
        'XColor','k','YColor','k');
		hold on
		a=xmin;
		b=xmax;
		c=xint;
		xA = a:c:b;
		xA = transpose(xA);
		tin=linspace(1,length(xA),length(xA));
		A = dist_data(:,1);
		n = length(A);
		[bandwidth,kdeA,xmesh1,cdf]=kde(A,length(tin),a,b);
		kdeA=transpose(interp1(xmesh1, kdeA, xA));
		hl2 = plot(xA,kdeA,'Color',[1 0 0]);
		ax1 = gca;
		set(ax1,'XColor','k','YColor','k')
		kdemax = max(kdeA);
		axis([xmin xmax 0 kdemax+0.2*kdemax])
		set(gca,'xtick',[])
		set(get(ax2,'Ylabel'),'String','probability')
		lgnd=legend('Kernel Density Estimate');
		set(hl2,'linewidth',2) 
		set(handles.optimize_text, 'String', bandwidth); 
		set(lgnd,'color','w');
		legend boxoff

		case handles.Myr_kernel

		hist(dist_data(:,1), bins);
		set(gca,'box','off')
		axis([xmin xmax hist_ymin hist_ymax])
		ax1 = gca;
		set(ax1,'XColor','k','YColor','k')
		set(get(ax1,'Ylabel'),'String','frequency', 'FontSize', 7)
		xlabel('Age (Ma)', 'FontSize', 7)
		ax2 = axes('Units', 'character'); %create a new axis and set units to be character
		set(ax2, 'Position',get(ax1,'Position'),...
        'XAxisLocation','top',...
        'YAxisLocation','right',...
        'Color','none',...
        'XColor','k','YColor','k');
		hold on
		x=xmin:xint:xmax;
		kernel = str2num(get(handles.Myr_Kernel_text,'String'));
		kernel_dist_data(1:length(dist_data(:,1)),1) = kernel;
		kde1=pdp5_2sig(dist_data(:,1),kernel_dist_data,xmin,xmax,xint);    
		hl2 = plot(x,kde1,'Color',[1 0 0]);
		ax1 = gca;
		set(ax1,'XColor','k','YColor','k')
		kdemax = max(kde1);
		axis([xmin xmax 0 kdemax+0.2*kdemax])
		set(gca,'xtick',[])
		set(get(ax2,'Ylabel'),'String','probability')
		lgnd=legend('Kernel Density Estimate');
		set(hl2,'linewidth',2) 
		set(lgnd,'color','w');
		legend boxoff
		end

    case handles.radio_hist_pdp_kde
	axes(handles.axes_distribution);        
	x=xmin:xint:xmax;
	pdp=pdp5_2sig(dist_data(:,1),dist_data(:,2),xmin,xmax,xint);
	hist(dist_data(:,1), bins);
	set(gca,'box','off')
	xlabel('Age (Ma)', 'FontSize', 7)
	axis([xmin xmax hist_ymin hist_ymax])
	ax1 = gca;
	set(ax1,'XColor','k','YColor','k')
	set(get(ax1,'Ylabel'),'String','frequency')
	ax2 = axes('Units', 'character'); %create a new axis and set units to be character
	set(ax2, 'Position',get(ax1,'Position'),...
    'XAxisLocation','top',...
    'YAxisLocation','right',...
    'Color','none',...
    'XColor','k','YColor','k');
	hold on

 		rad_on_kernel=get(handles.uipanel_kernel,'selectedobject');
		switch rad_on_kernel
		case handles.optimize

		a=xmin;
		b=xmax;
		c=xint;
		xA = a:c:b;
		xA = transpose(xA);
		tin=linspace(1,length(xA),length(xA));
		A = dist_data(:,1);
		n = length(A);
		[bandwidth,kdeA,xmesh1,cdf]=kde(A,length(tin),a,b);
		kdeA=transpose(interp1(xmesh1, kdeA, xA));
		pdp=pdp5_2sig(dist_data(:,1),dist_data(:,2),xmin,xmax,xint);
		x=xmin:xint:xmax;
		hl1 = plot(x,pdp,'Color',[0.1 0.8 0.1]);
		hl2 = plot(xA,kdeA,'Color',[1 0 0]);
		ax1 = gca;
		set(ax1,'XColor','k','YColor','k')
		pdpmax = max(pdp);
		kdemax = max(kdeA);
		maxboth = [pdpmax,kdemax];
		maxboth = max(maxboth);
		axis([xmin xmax 0 maxboth+0.1*maxboth])
		set(gca,'xtick',[])
		set(get(ax2,'Ylabel'),'String','probability')
		lgnd=legend('Probability Density Plot','Kernel Density Estimate');
		set(hl1,'linewidth',2)
		set(hl2,'linewidth',2)     
   		set(handles.optimize_text, 'String', bandwidth); 
		set(lgnd,'color','w');
		legend boxoff
		
		case handles.Myr_kernel

		a=xmin;
		b=xmax;
		c=xint;
		xA = a:c:b;
		xA = transpose(xA);
		tin=linspace(1,length(xA),length(xA));
		A = dist_data(:,1);
		n = length(A);
		[bandwidth,kdeA,xmesh1,cdf]=kde(A,length(tin),a,b);
		kdeA=transpose(interp1(xmesh1, kdeA, xA));
		pdp=pdp5_2sig(dist_data(:,1),dist_data(:,2),xmin,xmax,xint);
		x=xmin:xint:xmax;
		hl1 = plot(x,pdp,'Color',[0.1 0.8 0.1]);
		x=xmin:xint:xmax;
		kernel = str2num(get(handles.Myr_Kernel_text,'String'));
		kernel_dist_data(1:length(dist_data(:,1)),1) = kernel;
		kde1=pdp5_2sig(dist_data(:,1),kernel_dist_data,xmin,xmax,xint);    
		hl2 = plot(x,kde1,'Color',[1 0 0]);		
		ax1 = gca;
		set(ax1,'XColor','k','YColor','k')
		pdpmax = max(pdp);
		kdemax = max(kde1);
		maxboth = [pdpmax,kdemax];
		maxboth = max(maxboth);
		axis([xmin xmax 0 maxboth+0.1*maxboth])
		set(gca,'xtick',[])
		set(get(ax2,'Ylabel'),'String','probability')
		lgnd=legend('Probability Density Plot','Kernel Density Estimate');
		set(hl1,'linewidth',2)
		set(hl2,'linewidth',2)  
		set(lgnd,'color','w');
		legend boxoff
		end
	end

nsamp = num2str(length(dist_data));
set(handles.n_plotted,'String',nsamp);
guidata(hObject,handles);

%% CLEAR ALL %%
function clear_all_Callback(hObject, eventdata, handles)
cla(handles.axes_distribution,'reset'); 
set(handles.n_plotted,'String','?');
set(handles.optimize_text,'String','');
cla reset
set(gca,'xtick',[],'ytick',[],'Xcolor','w','Ycolor','w')
cla(handles.axes_bias,'reset');
cla(handles.axes_primary,'reset');
cla(handles.axes_secondary,'reset');
cla(handles.axes_current_intensities,'reset');
cla(handles.axes_current_concordia,'reset');
cla(handles.axes_distribution,'reset'); 
set(handles.n_plotted,'String','?');
set(handles.standards_rejected,'String','0');
set(handles.text141,'String','');
set(handles.text139,'String','');
set(handles.listbox1,'String','');
set(handles.listbox1,'String','');
set(handles.optimize_text,'String','');
cla reset
set(gca,'xtick',[],'ytick',[],'Xcolor','w','Ycolor','w')
guidata(hObject,handles);

%% EXPORT REDUCED DATA %%
function export_data_Callback(hObject, eventdata, handles)
data1 = handles.data1;
final_sample_num = handles.final_sample_num;
samples = handles.samples;
concordant_samples_sort = handles.concordant_samples_sort;
discordant_samples_sort = handles.discordant_samples_sort;
analysis_num = handles.analysis_num;
fc5z= handles.fc5z;
pleis= handles.pleis;
final_fc5z = handles.final_fc5z;
final_pleis = handles.final_pleis;
fc5z_time = handles.fc5z_time;
pleis_time = handles.pleis_time;

for i = 1:length(samples)
if samples(i,1) > 0
	samples_ascribe1(i,1) = analysis_num(i,1);
else 
	samples_ascribe1(i,1) = {''};
end
end

samples_ascribe = samples_ascribe1(~cellfun(@isempty, samples_ascribe1));
name_reduced_samples = samples_ascribe(concordant_samples_sort(:,1),1);
name_reduced_samples2 = samples_ascribe(discordant_samples_sort(:,1),1);

dat_concordant = {'Filtered data', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''; ...
    'Analysis_name', 'bias_corr_samples_Pb207_Pb206', 'bias_corr_samples_Pb207_Pb206_err', ...
    'bias_corr_samples_Pb207_U235', 'bias_corr_samples_Pb207_U235_err', 'bias_corr_samples_Pb206_U238', 'bias_corr_samples_Pb206_U238_err' ...
    'rho', 'bias_corr_samples_Pb208_Th232', 'bias_corr_samples_Pb208_Th232_err', 'samples_Pb206_U238_age,', 'samples_Pb206_U238_age_err' ...
    'samples_Pb207_U235_age', 'samples_Pb207_U235_age_err', 'samples_Pb207_Pb206_age', 'samples_Pb207_Pb206_age_err', 'samples_Pb208_Th232_age', ...
    'samples_Pb208_Th232_age_err', 'discordance_Pb206U238_Pb207Pb206', 'discordance_Pb206U238_Pb207U235', 'best_age', 'best_age_err'};

dat_concordant(3:length(concordant_samples_sort(:,1))+2,:) = num2cell(concordant_samples_sort);
dat_concordant(3:length(concordant_samples_sort(:,1))+2,1) = name_reduced_samples;

dat_discordant(1:2,:) = {'', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''; ...
    'Rejected data', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''};
dat_discordant(3,:) = {'Analysis_name', 'bias_corr_samples_Pb207_Pb206', 'bias_corr_samples_Pb207_Pb206_err', ...
    'bias_corr_samples_Pb207_U235', 'bias_corr_samples_Pb207_U235_err', 'bias_corr_samples_Pb206_U238', 'bias_corr_samples_Pb206_U238_err' ...
    'rho', 'bias_corr_samples_Pb208_Th232', 'bias_corr_samples_Pb208_Th232_err', 'samples_Pb206_U238_age,', 'samples_Pb206_U238_age_err' ...
    'samples_Pb207_U235_age', 'samples_Pb207_U235_age_err', 'samples_Pb207_Pb206_age', 'samples_Pb207_Pb206_age_err', 'samples_Pb208_Th232_age', ...
    'samples_Pb208_Th232_age_err', 'discordance_Pb206U238_Pb207Pb206', 'discordance_Pb206U238_Pb207U235', 'best_age', 'best_age_err'};

dat_discordant(4:length(discordant_samples_sort(:,1))+3,:) = num2cell(discordant_samples_sort);
dat_discordant(4:length(discordant_samples_sort(:,1))+3,1) = name_reduced_samples2;

for i = 1:length(pleis)
if pleis(i,1) > 0
    pleis_ascribe1(i,1) = analysis_num(i,1);
else 
    pleis_ascribe1(i,1) = {''};
end
end
 
pleis_ascribe = pleis_ascribe1(~cellfun(@isempty, pleis_ascribe1));
name_reduced_pleis = pleis_ascribe(final_pleis(:,1),1);

dat_pleis = {'', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''; ...
	'Primary reference material', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''; ...
	'Analysis_name', 'bias_corr_pleis_Pb207_Pb206', 'bias_corr_pleis_Pb207_Pb206_err', ...
    'bias_corr_pleis_Pb207_U235', 'bias_corr_pleis_Pb207_U235_err', 'bias_corr_pleis_Pb206_U238', 'bias_corr_pleis_Pb206_U238_err' ...
    'rho', 'bias_corr_pleis_Pb208_Th232', 'bias_corr_pleis_Pb208_Th232_err', 'pleis_Pb206_U238_age,', 'pleis_Pb206_U238_age_err' ...
    'pleis_Pb207_U235_age', 'pleis_Pb207_U235_age_err', 'pleis_Pb207_Pb206_age', 'pleis_Pb207_Pb206_age_err', 'pleis_Pb208_Th232_age', ...
    'pleis_Pb208_Th232_age_err', 'discordance_Pb206U238_Pb207Pb206', 'discordance_Pb206U238_Pb207U235', '', ''};

dat_pleis(4:length(final_pleis(:,1))+3,2:20) = num2cell(final_pleis(:,2:end));
dat_pleis(4:length(final_pleis(:,1))+3,1) = name_reduced_pleis;

for i = 1:length(fc5z)
if fc5z(i,1) > 0
	fc5z_ascribe1(i,1) = analysis_num(i,1);
else 
	fc5z_ascribe1(i,1) = {''};
end
end

fc5z_ascribe = fc5z_ascribe1(~cellfun(@isempty, fc5z_ascribe1));
name_reduced_fc5z = fc5z_ascribe(final_fc5z(:,1),1);

dat_fc5z = {'', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''; ...
	'Secondary reference material', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''; ...
	'Analysis_name', 'bias_corr_fc5z_Pb207_Pb206', 'bias_corr_fc5z_Pb207_Pb206_err', ...
    'bias_corr_fc5z_Pb207_U235', 'bias_corr_fc5z_Pb207_U235_err', 'bias_corr_fc5z_Pb206_U238', 'bias_corr_fc5z_Pb206_U238_err' ...
    'rho', 'bias_corr_fc5z_Pb208_Th232', 'bias_corr_fc5z_Pb208_Th232_err', 'fc5z_Pb206_U238_age,', 'fc5z_Pb206_U238_age_err' ...
    'fc5z_Pb207_U235_age', 'fc5z_Pb207_U235_age_err', 'fc5z_Pb207_Pb206_age', 'fc5z_Pb207_Pb206_age_err', 'fc5z_Pb208_Th232_age', ...
    'fc5z_Pb208_Th232_age_err', 'discordance_Pb206U238_Pb207Pb206', 'discordance_Pb206U238_Pb207U235', '', ''};

dat_fc5z(4:length(final_fc5z(:,1))+3,2:20) = num2cell(final_fc5z(:,2:end));
dat_fc5z(4:length(final_fc5z(:,1))+3,1) = name_reduced_fc5z;

%%%%% User-defined inputs %%%%%
pleis_Pb206_U238_known = str2num(get(handles.known_p68,'String'));
pleis_Pb207_Pb206_known = str2num(get(handles.known_p76,'String'));
pleis_Pb207_U235_known = str2num(get(handles.known_p75,'String'));
pleis_Pb208_Th232_known = str2num(get(handles.known_p82,'String'));
pleis_Pb206_U238_known_err = str2num(get(handles.known_p68err,'String'));
pleis_Pb207_Pb206_known_err = str2num(get(handles.known_p76err,'String'));
pleis_Pb207_U235_known_err = str2num(get(handles.known_p75err,'String'));
pleis_Pb208_Th232_known_err = str2num(get(handles.known_p82err,'String'));
fc5z_Pb206_U238_known = str2num(get(handles.known_s68,'String'));
fc5z_Pb207_Pb206_known = str2num(get(handles.known_s76,'String'));
fc5z_Pb207_U235_known = str2num(get(handles.known_s75,'String'));
fc5z_Pb208_Th232_known = str2num(get(handles.known_s82,'String'));
fc5z_Pb206_U238_known_err = str2num(get(handles.known_s68err,'String'));
fc5z_Pb207_Pb206_known_err = str2num(get(handles.known_s76err,'String'));
fc5z_Pb207_U235_known_err = str2num(get(handles.known_s75err,'String'));
fc5z_Pb208_Th232_known_err = str2num(get(handles.known_s82err,'String'));
reject_poly_order = str2num(get(handles.reject_poly_order,'String'));
reject_spline_breaks = str2num(get(handles.reject_spline_breaks,'String'));
outlier_cutoff_68 = str2num(get(handles.outlier_cutoff_68,'String'));
outlier_cutoff_76 = str2num(get(handles.outlier_cutoff_76,'String'));
outlier_cutoff_75 = str2num(get(handles.outlier_cutoff_75,'String'));
outlier_cutoff_82 = str2num(get(handles.outlier_cutoff_82,'String'));
replace_bad_rho = str2num(get(handles.replace_bad_rho,'String'));
poly_order = str2num(get(handles.poly_order,'String'));
breaks = str2num(get(handles.spline_breaks,'String'));
BL_xmin = str2num(get(handles.BL_min,'String'));
BL_xmax = str2num(get(handles.BL_max,'String'));
threshold_U238 = str2num(get(handles.threshold,'String'));
add_sec = str2num(get(handles.add_int,'String'));
int_time = str2num(get(handles.int_duration,'String'));
filter_unc_cutoff = str2num(get(handles.filter_unc_cutoff,'String'));
filter_transition_68_76 = str2num(get(handles.filter_transition_68_76,'String'));
filter_disc_transition = str2num(get(handles.filter_disc_transition,'String'));
filter_disc_young = str2num(get(handles.filter_disc_young,'String'));
filter_disc_old = str2num(get(handles.filter_disc_old,'String'));
filter_disc_rev = str2num(get(handles.filter_disc_rev,'String'));

dat_params(1:2,:) = {'', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''; ...
    'User-defined input parameters', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''};
dat_params(3:36,:) = {'pleis_Pb206_U238_known', pleis_Pb206_U238_known, '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''; ...
'pleis_Pb207_Pb206_known', pleis_Pb207_Pb206_known, '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''; ...
'pleis_Pb207_U235_known',pleis_Pb207_U235_known, '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''; ...
'pleis_Pb208_Th232_known',pleis_Pb208_Th232_known, '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''; ...
'pleis_Pb206_U238_known_err', pleis_Pb206_U238_known_err, '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''; ...
'pleis_Pb207_Pb206_known_err', pleis_Pb207_Pb206_known_err, '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''; ...
'pleis_Pb207_U235_known_err', pleis_Pb207_U235_known_err, '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''; ...
'pleis_Pb208_Th232_known_err', pleis_Pb208_Th232_known_err, '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''; ...
'fc5z_Pb206_U238_known', fc5z_Pb206_U238_known, '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''; ...
'fc5z_Pb207_Pb206_known', fc5z_Pb207_Pb206_known, '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''; ...
'fc5z_Pb207_U235_known', fc5z_Pb207_U235_known, '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''; ...
'fc5z_Pb208_Th232_known', fc5z_Pb208_Th232_known, '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''; ...
'fc5z_Pb206_U238_known_err', fc5z_Pb206_U238_known_err, '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''; ...
'fc5z_Pb207_Pb206_known_err', fc5z_Pb207_Pb206_known_err, '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''; ...
'fc5z_Pb207_U235_known_err', fc5z_Pb207_U235_known_err, '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''; ...
'fc5z_Pb208_Th232_known_err', fc5z_Pb208_Th232_known_err, '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''; ...
'reject_poly_order', reject_poly_order, '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''; ...
'reject_spline_breaks', reject_spline_breaks, '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''; ...
'outlier_cutoff_68', outlier_cutoff_68, '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''; ...
'outlier_cutoff_76', outlier_cutoff_76, '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''; ...
'outlier_cutoff_75', outlier_cutoff_75, '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''; ...
'outlier_cutoff_82', outlier_cutoff_82, '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''; ...
'replace_bad_rho', replace_bad_rho, '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''; ...
'BL_xmin', BL_xmin, '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''; ...
'BL_xmax', BL_xmax, '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''; ...
'threshold_U238', threshold_U238 , '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''; ...
'add_sec', add_sec, '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''; ...
'int_time', int_time, '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''; ...
'filter_unc_cutoff', filter_unc_cutoff, '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''; ...
'filter_transition_68_76', filter_transition_68_76, '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''; ...
'filter_disc_transition', filter_disc_transition, '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''; ...
'filter_disc_young', filter_disc_young, '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''; ...
'filter_disc_old', filter_disc_old, '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''; ...
'filter_disc_rev', filter_disc_rev, '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''};

		rad_on_fit=get(handles.uipanel_fit_type,'selectedobject');
		switch rad_on_fit
        case handles.radio_mean
        case handles.radio_linear
        case handles.radio_polynomial
dat_params(37,:) = {'poly_order', poly_order, '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''};
        case handles.radio_cubicspline
dat_params(37,:) = {'breaks', breaks, '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''};
        case handles.radio_smoothingspline     
 		end

dat_out = [dat_concordant;dat_discordant;dat_pleis;dat_fc5z;dat_params];

[file,path] = uiputfile('*.xls','Save file');
xlswrite([path file], dat_out);
guidata(hObject,handles);

%% EXPORT REDUCED STANDARDS ONLY %%
function export_standards_Callback(hObject, eventdata, handles)
fc5z= handles.fc5z;
pleis= handles.pleis;
analysis_num = handles.analysis_num;
final_fc5z = handles.final_fc5z;
final_pleis = handles.final_pleis;
fc5z_time = handles.fc5z_time;
pleis_time = handles.pleis_time;

for i = 1:length(fc5z)
if fc5z(i,1) > 0
	fc5z_ascribe1(i,1) = analysis_num(i,1);
else 
	fc5z_ascribe1(i,1) = {''};
end
end

fc5z_ascribe = fc5z_ascribe1(~cellfun(@isempty, fc5z_ascribe1));
name_reduced_fc5z = fc5z_ascribe(final_fc5z(:,1),1);

for i = 1:length(pleis)
if pleis(i,1) > 0
    pleis_ascribe1(i,1) = analysis_num(i,1);
else 
    pleis_ascribe1(i,1) = {''};
end
end
 
pleis_ascribe = pleis_ascribe1(~cellfun(@isempty, pleis_ascribe1));
name_reduced_pleis = pleis_ascribe(final_pleis(:,1),1);

dat1 = {'Analysis_name', 'fc5z_time', 'bias_corr_fc5z_Pb207_Pb206', 'bias_corr_fc5z_Pb207_Pb206_err', ...
    'bias_corr_fc5z_Pb207_U235', 'bias_corr_fc5z_Pb207_U235_err', 'bias_corr_fc5z_Pb206_U238', 'bias_corr_fc5z_Pb206_U238_err' ...
    'rho', 'bias_corr_fc5z_Pb208_Th232', 'bias_corr_fc5z_Pb208_Th232_err', 'fc5z_Pb206_U238_age,', 'fc5z_Pb206_U238_age_err' ...
    'fc5z_Pb207_U235_age', 'fc5z_Pb207_U235_age_err', 'fc5z_Pb207_Pb206_age', 'fc5z_Pb207_Pb206_age_err', 'fc5z_Pb208_Th232_age', ...
    'fc5z_Pb208_Th232_age_err', 'discordance_Pb206U238_Pb207Pb206', 'discordance_Pb206U238_Pb207U235'};

dat2 = {'Analysis_name', 'pleis_time', 'bias_corr_pleis_Pb207_Pb206', 'bias_corr_pleis_Pb207_Pb206_err', ...
    'bias_corr_pleis_Pb207_U235', 'bias_corr_pleis_Pb207_U235_err', 'bias_corr_pleis_Pb206_U238', 'bias_corr_pleis_Pb206_U238_err' ...
    'rho', 'bias_corr_pleis_Pb208_Th232', 'bias_corr_pleis_Pb208_Th232_err', 'pleis_Pb206_U238_age,', 'pleis_Pb206_U238_age_err' ...
    'pleis_Pb207_U235_age', 'pleis_Pb207_U235_age_err', 'pleis_Pb207_Pb206_age', 'pleis_Pb207_Pb206_age_err', 'pleis_Pb208_Th232_age', ...
    'pleis_Pb208_Th232_age_err', 'discordance_Pb206U238_Pb207Pb206', 'discordance_Pb206U238_Pb207U235'};

dat1(2:length(final_fc5z(:,1))+1,2:21) = num2cell(final_fc5z);
dat1(2:length(final_fc5z(:,1))+1,1) = name_reduced_fc5z;
dat1(2:length(final_fc5z(:,1))+1,2) = num2cell(fc5z_time);

dat2(2:length(final_pleis(:,1))+1,2:21) = num2cell(final_pleis);
dat2(2:length(final_pleis(:,1))+1,1) = name_reduced_pleis;
dat2(2:length(final_pleis(:,1))+1,2) = num2cell(pleis_time);

dat = vertcat(dat1,dat2);

[file,path] = uiputfile('*.xls','Save file');
xlswrite([path file], dat);
guidata(hObject,handles);

%% EXPORT PDP %%
function export_pdp_Callback(hObject, eventdata, handles)
data1 = handles.data1;
data2 = handles.data2;
data3 = vertcat(data1,data2);

xmin = str2num(get(handles.xmin,'String'));
xmax = str2num(get(handles.xmax,'String'));
xint = str2num(get(handles.xint,'String'));

x=xmin:xint:xmax;
pdp1=pdp5_2sig(data1(:,1),data1(:,2),xmin,xmax,xint); 
pdp2=pdp5_2sig(data2(:,1),data2(:,2),xmin,xmax,xint); 
pdp3=pdp5_2sig(data3(:,1),data3(:,2),xmin,xmax,xint); 

pdp_out(:,1) = x;
pdp_out(:,2) = pdp1;
pdp_out(:,3) = pdp2;
pdp_out(:,4) = pdp3;

dat = {'x', 'Accepted data', 'Rejected data', 'All data'};
dat(2:length(pdp_out)+1,1:4) = num2cell(pdp_out);

[file,path] = uiputfile('*.xls','Save file');
xlswrite([path file], dat);
guidata(hObject,handles);

%% EXPORT KDE %%
function export_kde_Callback(hObject, eventdata, handles)
data1 = handles.data1;
data2 = handles.data2;
data3 = vertcat(data1,data2);

xmin = str2num(get(handles.xmin,'String'));
xmax = str2num(get(handles.xmax,'String'));
xint = str2num(get(handles.xint,'String'));

x=xmin:xint:xmax;
a=xmin;
b=xmax;
c=xint;
xA = a:c:b;
xA = transpose(xA);
tin=linspace(1,length(xA),length(xA));

		rad_on_kernel=get(handles.uipanel_kernel,'selectedobject');
		switch rad_on_kernel
		case handles.optimize

A = data1(:,1);
n = length(A);
[bandwidth,kdeA,xmesh1,cdf]=kde(A,length(tin),a,b);
kde1=transpose(interp1(xmesh1, kdeA, xA));

A = data2(:,1);
n = length(A);
[bandwidth,kdeA,xmesh1,cdf]=kde(A,length(tin),a,b);
kde2=transpose(interp1(xmesh1, kdeA, xA));

A = data3(:,1);
n = length(A);
[bandwidth,kdeA,xmesh1,cdf]=kde(A,length(tin),a,b);
kde3=transpose(interp1(xmesh1, kdeA, xA));

kde_out(:,1) = x;
kde_out(:,2) = kde1;
kde_out(:,3) = kde2;
kde_out(:,4) = kde3;

		case handles.Myr_kernel

A = data1(:,1);

		x=xmin:xint:xmax;
		kernel = str2num(get(handles.Myr_Kernel_text,'String'));
		kernel_dist_data1(1:length(A),1) = kernel;
		kde1=pdp5_2sig(A,kernel_dist_data1,xmin,xmax,xint); 

B = data2(:,1);

		x=xmin:xint:xmax;
		kernel = str2num(get(handles.Myr_Kernel_text,'String'));
		kernel_dist_data2(1:length(B),1) = kernel;
		kde2=pdp5_2sig(B,kernel_dist_data2,xmin,xmax,xint); 

C = data3(:,1);

		x=xmin:xint:xmax;
		kernel = str2num(get(handles.Myr_Kernel_text,'String'));
		kernel_dist_data3(1:length(C),1) = kernel;
		kde3=pdp5_2sig(C,kernel_dist_data3,xmin,xmax,xint); 

		end

kde_out(:,1) = x;
kde_out(:,2) = kde1;
kde_out(:,3) = kde2;
kde_out(:,4) = kde3;

dat = {'x', 'Accepted data', 'Rejected data', 'All data'};
dat(2:length(kde_out)+1,1:4) = num2cell(kde_out);

[file,path] = uiputfile('*.xls','Save file');
xlswrite([path file], dat);

%% EXPORT CONCORDIA FIGURES %%
function export_sample_concordias_Callback(hObject, eventdata, handles)
xmin = 0;
xmax = 12;
ymin = 0;
ymax = 0.5;
agelabelmin = 0;
agelabelmax = 4.5;
agelabelint = 0.5;

concordant_samples_sort = handles.concordant_samples_sort;
discordant_samples_sort = handles.discordant_samples_sort;

concordant_data = [concordant_samples_sort(:,2),concordant_samples_sort(:,3), ...
	concordant_samples_sort(:,4),concordant_samples_sort(:,5),...
	concordant_samples_sort(:,6),concordant_samples_sort(:,7)];

concordant_data_rho = concordant_samples_sort(:,8);

concordant_data_center=[concordant_data(:,3),concordant_data(:,5)];

concordant_data_sigx_abs = concordant_data(:,3).*concordant_data(:,4).*0.01;
concordant_data_sigy_abs = concordant_data(:,5).*concordant_data(:,6).*0.01;

concordant_data_sigx_sq = concordant_data_sigx_abs.*concordant_data_sigx_abs;
concordant_data_sigy_sq = concordant_data_sigy_abs.*concordant_data_sigy_abs;
concordant_data_rho_sigx_sigy = concordant_data_sigx_abs.*concordant_data_sigy_abs.*concordant_data_rho;
sigmarule=1.25;
numpoints=50;

f = figure; %create new figure

for i = 1:length(concordant_data_rho);

concordant_data_covmat=[concordant_data_sigx_sq(i,1),concordant_data_rho_sigx_sigy(i,1);concordant_data_rho_sigx_sigy(i,1), ...
	concordant_data_sigy_sq(i,1)];
[concordant_data_PD,concordant_data_PV]=eig(concordant_data_covmat);
concordant_data_PV=diag(concordant_data_PV).^.5;
concordant_data_theta=linspace(0,2.*pi,numpoints)';
concordant_data_elpt=[cos(concordant_data_theta),sin(concordant_data_theta)]*diag(concordant_data_PV)*concordant_data_PD';
numsigma=length(sigmarule);
concordant_data_elpt=repmat(concordant_data_elpt,1,numsigma).*repmat(sigmarule(floor(1:.5:numsigma+.5)),numpoints,1);
concordant_data_elpt=concordant_data_elpt+repmat(concordant_data_center(i,1:2),numpoints,numsigma);
plot(concordant_data_elpt(:,1:2:end),concordant_data_elpt(:,2:2:end),'b','LineWidth',1.2);
hold on
end

timemin = 0;
timemax = 4500000000;
timeinterval = 50000000;
time = timemin:timeinterval:timemax;

x = exp(0.00000000098485.*time)-1;
y = exp(0.000000000155125.*time)-1;

age_label_num = [agelabelmin+agelabelint:agelabelint:agelabelmax];
for i=1:length(age_label_num)
age_label(i,1) = {sprintf('%.1f',age_label_num(1,i))};
age_label2(i,1) = strcat(age_label(i,1),' Ga');
end
age_label_num = age_label_num.*1000000000;
age_label_x = exp(0.00000000098485.*age_label_num)-1;
age_label_y = exp(0.000000000155125.*age_label_num)-1;

plot(x,y,'k','LineWidth',1.4)
hold on
scatter(age_label_x, age_label_y,20,'MarkerEdgeColor','k','MarkerFaceColor','y','LineWidth',1.5)
labelpoints (age_label_x, age_label_y, age_label2, 'SE');

axis([xmin xmax ymin ymax]);
xlabel('207Pb/235U');
ylabel('206Pb/238U');
title('Filtered data')

discordant_data = [discordant_samples_sort(:,2),discordant_samples_sort(:,3), ...
	discordant_samples_sort(:,4),discordant_samples_sort(:,5),...
	discordant_samples_sort(:,6),discordant_samples_sort(:,7)];

discordant_data_rho = discordant_samples_sort(:,8);

discordant_data_center=[discordant_data(:,3),discordant_data(:,5)];

discordant_data_sigx_abs = discordant_data(:,3).*discordant_data(:,4).*0.01;
discordant_data_sigy_abs = discordant_data(:,5).*discordant_data(:,6).*0.01;

discordant_data_sigx_sq = discordant_data_sigx_abs.*discordant_data_sigx_abs;
discordant_data_sigy_sq = discordant_data_sigy_abs.*discordant_data_sigy_abs;
discordant_data_rho_sigx_sigy = discordant_data_sigx_abs.*discordant_data_sigy_abs.*discordant_data_rho;
sigmarule=1.25;
numpoints=50;

f2 = figure; %create new figure

for i = 1:length(discordant_data_rho);

discordant_data_covmat=[discordant_data_sigx_sq(i,1),discordant_data_rho_sigx_sigy(i,1);discordant_data_rho_sigx_sigy(i,1), ...
	discordant_data_sigy_sq(i,1)];
[discordant_data_PD,discordant_data_PV]=eig(discordant_data_covmat);
discordant_data_PV=diag(discordant_data_PV).^.5;
discordant_data_theta=linspace(0,2.*pi,numpoints)';
discordant_data_elpt=[cos(discordant_data_theta),sin(discordant_data_theta)]*diag(discordant_data_PV)*discordant_data_PD';
numsigma=length(sigmarule);
discordant_data_elpt=repmat(discordant_data_elpt,1,numsigma).*repmat(sigmarule(floor(1:.5:numsigma+.5)),numpoints,1);
discordant_data_elpt=discordant_data_elpt+repmat(discordant_data_center(i,1:2),numpoints,numsigma);
plot(discordant_data_elpt(:,1:2:end),discordant_data_elpt(:,2:2:end),'r','LineWidth',1.2);
hold on
end

timemin = 0;
timemax = 4500000000;
timeinterval = 50000000;
time = timemin:timeinterval:timemax;

x = exp(0.00000000098485.*time)-1;
y = exp(0.000000000155125.*time)-1;

plot(x,y,'k','LineWidth',1.4)
hold on
scatter(age_label_x, age_label_y,20,'MarkerEdgeColor','k','MarkerFaceColor','y','LineWidth',1.5)
labelpoints (age_label_x, age_label_y, age_label2, 'SE');

axis([xmin xmax ymin ymax]);
xlabel('207Pb/235U');
ylabel('206Pb/238U');
title('Rejected data')
guidata(hObject,handles);

%% EXPORT STANDARD CONCORDIAS %%
function export_standard_concordias_Callback(hObject, eventdata, handles)
bias_corr_pleis_Pb207_Pb206 = handles.bias_corr_pleis_Pb207_Pb206;
bias_corr_fc5z_Pb207_Pb206 = handles.bias_corr_fc5z_Pb207_Pb206;
pleis_data = handles.pleis_data;
fc5z_data = handles.fc5z_data;
pleis_rho = handles.pleis_rho;
fc5z_rho = handles.fc5z_rho;

center=[pleis_data(:,3),pleis_data(:,5)];

sigx_abs = pleis_data(:,3).*pleis_data(:,4).*0.01;
sigy_abs = pleis_data(:,5).*pleis_data(:,6).*0.01;

sigx_sq = sigx_abs.*sigx_abs;
sigy_sq = sigy_abs.*sigy_abs;
rho_sigx_sigy = sigx_abs.*sigy_abs.*pleis_rho;
sigmarule=1.25;
numpoints=50;


f = figure; %create new figure

for i = 1:length(nonzeros(bias_corr_pleis_Pb207_Pb206));

covmat=[sigx_sq(i,1),rho_sigx_sigy(i,1);rho_sigx_sigy(i,1),sigy_sq(i,1)];
[PD,PV]=eig(covmat);
PV=diag(PV).^.5;
theta=linspace(0,2.*pi,numpoints)';
elpt=[cos(theta),sin(theta)]*diag(PV)*PD';
numsigma=length(sigmarule);
elpt=repmat(elpt,1,numsigma).*repmat(sigmarule(floor(1:.5:numsigma+.5)),numpoints,1);
elpt=elpt+repmat(center(i,1:2),numpoints,numsigma);
plot(elpt(:,1:2:end),elpt(:,2:2:end),'b','LineWidth',1.2);
hold on
end

timemin = 0;
timemax = 4500000000;
timeinterval = 50000000;
time = timemin:timeinterval:timemax;

x = exp(0.00000000098485.*time)-1;
y = exp(0.000000000155125.*time)-1;

age_label_x = [0.3437; 0.4828];
age_label_y = [0.0476; 0.0640];
age_label = {'300 Ma'; '400 Ma'};

age_label2_x = 0.3937;
age_label2_y = 0.0537;
age_label2 = {'337.1 Ma'};

plot(x,y,'k','LineWidth',1.4)
hold on
p1 = scatter(age_label2_x, age_label2_y,40,'MarkerEdgeColor','k','MarkerFaceColor','g','LineWidth',1.5);
labelpoints (age_label2_x, age_label2_y, age_label2, 'SE', .001);
legend([p1],'accepted age','Location','northwest');

scatter(age_label_x, age_label_y,20,'MarkerEdgeColor','k','MarkerFaceColor','y','LineWidth',1.5)
labelpoints (age_label_x, age_label_y, age_label, 'SE', .001);



axis([.27 .54 .041 .07]);
xlabel('207Pb/235U');
ylabel('206Pb/238U');

%%%%%%


center=[fc5z_data(:,3),fc5z_data(:,5)];

sigx_abs = fc5z_data(:,3).*fc5z_data(:,4).*0.01;
sigy_abs = fc5z_data(:,5).*fc5z_data(:,6).*0.01;

sigx_sq = sigx_abs.*sigx_abs;
sigy_sq = sigy_abs.*sigy_abs;
rho_sigx_sigy = sigx_abs.*sigy_abs.*fc5z_rho;
sigmarule=1.25;
numpoints=50;

f1 = figure; %create new figure

for i = 1:length(nonzeros(bias_corr_fc5z_Pb207_Pb206));

covmat=[sigx_sq(i,1),rho_sigx_sigy(i,1);rho_sigx_sigy(i,1),sigy_sq(i,1)];
[PD,PV]=eig(covmat);
PV=diag(PV).^.5;
theta=linspace(0,2.*pi,numpoints)';
elpt=[cos(theta),sin(theta)]*diag(PV)*PD';
numsigma=length(sigmarule);
elpt=repmat(elpt,1,numsigma).*repmat(sigmarule(floor(1:.5:numsigma+.5)),numpoints,1);
elpt=elpt+repmat(center(i,1:2),numpoints,numsigma);
plot(elpt(:,1:2:end),elpt(:,2:2:end),'b','LineWidth',1.2);
hold on
end

timemin = 0;
timemax = 4500000000;
timeinterval = 50000000;
time = timemin:timeinterval:timemax;

x = exp(0.00000000098485.*time)-1;
y = exp(0.000000000155125.*time)-1;

age_label_x = [1.7307; 1.8404; 2.0732];
age_label_y = [0.1714; 0.1787; 0.1934];
age_label = {'1020 Ma'; '1060 Ma'; '1140 Ma'};

age_label3_x = 1.9429;
age_label3_y = 0.1853;
age_label3 = {'1099.1 Ma'};

plot(x,y,'k','LineWidth',1.4)
hold on

p2 = scatter(age_label3_x, age_label3_y,40,'MarkerEdgeColor','k','MarkerFaceColor','g','LineWidth',1.5);
labelpoints (age_label3_x, age_label3_y, age_label3, 'SE', .001);
legend([p2],'accepted age','Location','northwest');

scatter(age_label_x, age_label_y,20,'MarkerEdgeColor','k','MarkerFaceColor','y','LineWidth',1.5)
labelpoints (age_label_x, age_label_y, age_label, 'SE', .001);

axis([1.5 2.5 .15 .22]);
xlabel('207Pb/235U');
ylabel('206Pb/238U');

%% EXPORT DISTRIBUTION PLOTS %%
function export_distribution_plot_Callback(hObject, eventdata, handles)







data1 = handles.data1;
data2 = handles.data2;
data3 = vertcat(data1,data2);
numsamples1 = length(data1);
numsamples2 = length(data2);
numsamples3 = length(data3);

xmin = str2num(get(handles.xmin,'String'));
xmax = str2num(get(handles.xmax,'String'));
xint = str2num(get(handles.xint,'String'));
hist_ymin = str2num(get(handles.ymin,'String'));
hist_ymax = str2num(get(handles.ymax,'String'));
bins = str2num(get(handles.bins,'String'));

	rad_on_dist=get(handles.uipanel_distribution,'selectedobject');
	switch rad_on_dist
    case handles.radio_hist

	f1 = figure;
	hist(data1(:,1), bins);
	set(gca,'box','off')
	axis([xmin xmax hist_ymin hist_ymax])
	ax1 = gca;
	set(ax1,'XColor','k','YColor','k')
	set(get(ax1,'Ylabel'),'String','frequency', 'FontSize', 7)    
	set(get(ax1,'Xlabel'),'String','Age (Ma)', 'FontSize', 7)
	title('Filtered data')
	dim = [.75 .5 .3 .3];
	str = {'n = ', numsamples1};
	annotation('textbox',dim,'String',str,'FitBoxToText','on');

	f2 = figure;
	hist(data2(:,1), bins);
	set(gca,'box','off')
	axis([xmin xmax hist_ymin hist_ymax])
	ax1 = gca;
	set(ax1,'XColor','k','YColor','k')
	set(get(ax1,'Ylabel'),'String','frequency', 'FontSize', 7)    
	set(get(ax1,'Xlabel'),'String','Age (Ma)', 'FontSize', 7)
	title('Rejected data')
	dim = [.75 .5 .3 .3];
	str = {'n = ', numsamples2};
	annotation('textbox',dim,'String',str,'FitBoxToText','on');

	f3 = figure;
	hist(data3(:,1), bins);
	set(gca,'box','off')
	axis([xmin xmax hist_ymin hist_ymax])
	ax1 = gca;
	set(ax1,'XColor','k','YColor','k')
	set(get(ax1,'Ylabel'),'String','frequency', 'FontSize', 7)    
	set(get(ax1,'Xlabel'),'String','Age (Ma)', 'FontSize', 7)
	title('All data')
	dim = [.75 .5 .3 .3];
	str = {'n = ', numsamples3};
	annotation('textbox',dim,'String',str,'FitBoxToText','on');

    case handles.radio_pdp

	f1 = figure;
    x=xmin:xint:xmax;
	pdp=pdp5_2sig(data1(:,1),data1(:,2),xmin,xmax,xint);    
	hl1 = plot(x,pdp,'Color',[0.1 0.8 0.1]);
	ax1 = gca;
	set(ax1,'XColor','k','YColor','k')
	pdpmax = max(pdp);
	axis([xmin xmax 0 pdpmax+0.1*pdpmax])
	lgnd=legend('Probability Density Plot');
	set(hl1,'linewidth',2)
	set(gca,'box','off')
	ax1 = gca;
	set(ax1,'XColor','k','YColor','k')
	set(get(ax1,'Ylabel'),'String','probability', 'FontSize', 7)    
	set(get(ax1,'Xlabel'),'String','Age (Ma)', 'FontSize', 7)
	set(lgnd,'color','w');
	legend boxoff
	title('Filtered data')
	dim = [.75 .5 .3 .3];
	str = {'n = ', numsamples1};
	annotation('textbox',dim,'String',str,'FitBoxToText','on');

	f2 = figure;
    x=xmin:xint:xmax;
	pdp=pdp5_2sig(data2(:,1),data2(:,2),xmin,xmax,xint);    
	hl1 = plot(x,pdp,'Color',[0.1 0.8 0.1]);
	ax1 = gca;
	set(ax1,'XColor','k','YColor','k')
	pdpmax = max(pdp);
	axis([xmin xmax 0 pdpmax+0.1*pdpmax])
	lgnd=legend('Probability Density Plot');
	set(hl1,'linewidth',2)
	set(gca,'box','off')
	ax1 = gca;
	set(ax1,'XColor','k','YColor','k')
	set(get(ax1,'Ylabel'),'String','probability', 'FontSize', 7)    
	set(get(ax1,'Xlabel'),'String','Age (Ma)', 'FontSize', 7)
	set(lgnd,'color','w');
	legend boxoff
	title('Rejected data')
	dim = [.75 .5 .3 .3];
	str = {'n = ', numsamples2};
	annotation('textbox',dim,'String',str,'FitBoxToText','on');

	f3 = figure;
    x=xmin:xint:xmax;
	pdp=pdp5_2sig(data3(:,1),data3(:,2),xmin,xmax,xint);    
	hl1 = plot(x,pdp,'Color',[0.1 0.8 0.1]);
	ax1 = gca;
	set(ax1,'XColor','k','YColor','k')
	pdpmax = max(pdp);
	axis([xmin xmax 0 pdpmax+0.1*pdpmax])
	lgnd=legend('Probability Density Plot');
	set(hl1,'linewidth',2)
	set(gca,'box','off')
	ax1 = gca;
	set(ax1,'XColor','k','YColor','k')
	set(get(ax1,'Ylabel'),'String','probability', 'FontSize', 7)    
	set(get(ax1,'Xlabel'),'String','Age (Ma)', 'FontSize', 7)
	set(lgnd,'color','w');
	legend boxoff
	title('All data')
	dim = [.75 .5 .3 .3];
	str = {'n = ', numsamples3};
	annotation('textbox',dim,'String',str,'FitBoxToText','on');

    case handles.radio_kde     
	
		f1 = figure; 
		rad_on_kernel=get(handles.uipanel_kernel,'selectedobject');
		switch rad_on_kernel
		case handles.optimize
		x=xmin:xint:xmax;
		a=xmin;
		b=xmax;
		c=xint;
		xA = a:c:b;
		xA = transpose(xA);
		tin=linspace(1,length(xA),length(xA));
		A = data1(:,1);
		n = length(A);
		[bandwidth,kdeA,xmesh1,cdf]=kde(A,length(tin),a,b);
		kdeA=transpose(interp1(xmesh1, kdeA, xA));
		hl1 = plot(tin,kdeA,'Color',[1 0 0]);
		ax1 = gca;
		set(ax1,'XColor','k','YColor','k')
		kdemax = max(kdeA);
		axis([xmin xmax 0 kdemax+0.2*kdemax])
		lgnd=legend('Kernel Density Estimate');
		set(hl1,'linewidth',2)
		set(gca,'box','off')
		ax1 = gca;
		set(ax1,'XColor','k','YColor','k')
		set(get(ax1,'Ylabel'),'String','probability', 'FontSize', 7)    
		set(get(ax1,'Xlabel'),'String','Age (Ma)', 'FontSize', 7) 
		set(handles.optimize_text, 'String', bandwidth);
		set(lgnd,'color','w');
		legend boxoff
		title('Filtered data')
		dim = [.75 .5 .3 .3];
		str = {'n = ', numsamples1};
		annotation('textbox',dim,'String',str,'FitBoxToText','on');

		case handles.Myr_kernel

		x=xmin:xint:xmax;
		kernel = str2num(get(handles.Myr_Kernel_text,'String'));
		kernel_dist_data(1:length(data1(:,1)),1) = kernel;
		kde1=pdp5_2sig(data1(:,1),kernel_dist_data,xmin,xmax,xint);    
		hl1 = plot(x,kde1,'Color',[1 0 0]);
		ax1 = gca;
		set(ax1,'XColor','k','YColor','k')
		pdpmax = max(kde1);
		axis([xmin xmax 0 pdpmax+0.2*pdpmax])
		lgnd=legend('Kernel Density Estimate');
		set(hl1,'linewidth',2)
		set(gca,'box','off')
		ax1 = gca;
		set(ax1,'XColor','k','YColor','k')
		set(get(ax1,'Ylabel'),'String','probability', 'FontSize', 7)    
		set(get(ax1,'Xlabel'),'String','Age (Ma)', 'FontSize', 7)		
		end
		set(lgnd,'color','w');
		legend boxoff
		title('Filtered data')
		dim = [.75 .5 .3 .3];
		str = {'n = ', numsamples1};
		annotation('textbox',dim,'String',str,'FitBoxToText','on');

		f2 = figure; 
		rad_on_kernel=get(handles.uipanel_kernel,'selectedobject');
		switch rad_on_kernel
		case handles.optimize
		x=xmin:xint:xmax;
		a=xmin;
		b=xmax;
		c=xint;
		xA = a:c:b;
		xA = transpose(xA);
		tin=linspace(1,length(xA),length(xA));
		A = data2(:,1);
		n = length(A);
		[bandwidth,kdeA,xmesh1,cdf]=kde(A,length(tin),a,b);
		kdeA=transpose(interp1(xmesh1, kdeA, xA));
		hl1 = plot(tin,kdeA,'Color',[1 0 0]);
		ax1 = gca;
		set(ax1,'XColor','k','YColor','k')
		kdemax = max(kdeA);
		axis([xmin xmax 0 kdemax+0.2*kdemax])
		lgnd=legend('Kernel Density Estimate');
		set(hl1,'linewidth',2)
		set(gca,'box','off')
		ax1 = gca;
		set(ax1,'XColor','k','YColor','k')
		set(get(ax1,'Ylabel'),'String','probability', 'FontSize', 7)    
		set(get(ax1,'Xlabel'),'String','Age (Ma)', 'FontSize', 7) 
		set(handles.optimize_text, 'String', bandwidth);
		set(lgnd,'color','w');
		legend boxoff
		title('Rejected data')
		dim = [.75 .5 .3 .3];
		str = {'n = ', numsamples2};
		annotation('textbox',dim,'String',str,'FitBoxToText','on');

		case handles.Myr_kernel

		x=xmin:xint:xmax;
		kernel = str2num(get(handles.Myr_Kernel_text,'String'));
		kernel_dist_data(1:length(data2(:,1)),1) = kernel;
		kde1=pdp5_2sig(data2(:,1),kernel_dist_data,xmin,xmax,xint);    
		hl1 = plot(x,kde1,'Color',[1 0 0]);
		ax1 = gca;
		set(ax1,'XColor','k','YColor','k')
		pdpmax = max(kde1);
		axis([xmin xmax 0 pdpmax+0.2*pdpmax])
		lgnd=legend('Kernel Density Estimate');
		set(hl1,'linewidth',2)
		set(gca,'box','off')
		ax1 = gca;
		set(ax1,'XColor','k','YColor','k')
		set(get(ax1,'Ylabel'),'String','probability', 'FontSize', 7)    
		set(get(ax1,'Xlabel'),'String','Age (Ma)', 'FontSize', 7)		
		end
		set(lgnd,'color','w');
		legend boxoff
		title('Rejected data')
		dim = [.75 .5 .3 .3];
		str = {'n = ', numsamples2};
		annotation('textbox',dim,'String',str,'FitBoxToText','on');

		f3 = figure; 
		rad_on_kernel=get(handles.uipanel_kernel,'selectedobject');
		switch rad_on_kernel
		case handles.optimize
		x=xmin:xint:xmax;
		a=xmin;
		b=xmax;
		c=xint;
		xA = a:c:b;
		xA = transpose(xA);
		tin=linspace(1,length(xA),length(xA));
		A = data3(:,1);
		n = length(A);
		[bandwidth,kdeA,xmesh1,cdf]=kde(A,length(tin),a,b);
		kdeA=transpose(interp1(xmesh1, kdeA, xA));
		hl1 = plot(tin,kdeA,'Color',[1 0 0]);
		ax1 = gca;
		set(ax1,'XColor','k','YColor','k')
		kdemax = max(kdeA);
		axis([xmin xmax 0 kdemax+0.2*kdemax])
		lgnd=legend('Kernel Density Estimate');
		set(hl1,'linewidth',2)
		set(gca,'box','off')
		ax1 = gca;
		set(ax1,'XColor','k','YColor','k')
		set(get(ax1,'Ylabel'),'String','probability', 'FontSize', 7)    
		set(get(ax1,'Xlabel'),'String','Age (Ma)', 'FontSize', 7) 
		set(handles.optimize_text, 'String', bandwidth);
		set(lgnd,'color','w');
		legend boxoff
		title('All data')
		dim = [.75 .5 .3 .3];
		str = {'n = ', numsamples3};
		annotation('textbox',dim,'String',str,'FitBoxToText','on');

		case handles.Myr_kernel

		x=xmin:xint:xmax;
		kernel = str2num(get(handles.Myr_Kernel_text,'String'));
		kernel_dist_data(1:length(data3(:,1)),1) = kernel;
		kde1=pdp5_2sig(data3(:,1),kernel_dist_data,xmin,xmax,xint);    
		hl1 = plot(x,kde1,'Color',[1 0 0]);
		ax1 = gca;
		set(ax1,'XColor','k','YColor','k')
		pdpmax = max(kde1);
		axis([xmin xmax 0 pdpmax+0.2*pdpmax])
		lgnd=legend('Kernel Density Estimate');
		set(hl1,'linewidth',2)
		set(gca,'box','off')
		ax1 = gca;
		set(ax1,'XColor','k','YColor','k')
		set(get(ax1,'Ylabel'),'String','probability', 'FontSize', 7)    
		set(get(ax1,'Xlabel'),'String','Age (Ma)', 'FontSize', 7)		
		end
		set(lgnd,'color','w');
		legend boxoff
		title('All data')
		dim = [.75 .5 .3 .3];
		str = {'n = ', numsamples3};
		annotation('textbox',dim,'String',str,'FitBoxToText','on');	

    case handles.radio_hist_pdp

f1 = figure;        
x=xmin:xint:xmax;
pdp=pdp5_2sig(data1(:,1),data1(:,2),xmin,xmax,xint);
hist(data1(:,1), bins);
xlabel('Age (Ma)')
set(gca,'box','off')
axis([xmin xmax hist_ymin hist_ymax])
ax1 = gca;
set(ax1,'XColor','k','YColor','k')
set(get(ax1,'Ylabel'),'String','frequency')
ax2 = axes('Position',get(ax1,'Position'),...
'XAxisLocation','top',...
'YAxisLocation','right',...
'Color','none',...
'XColor','b','YColor','b');
hold on
a=xmin;
b=xmax;
c=xint;
xA = a:c:b;
xA = transpose(xA);
tin=linspace(1,length(xA),length(xA));
A = data1(:,1);
n = length(A);
[bandwidth,kdeA,xmesh1,cdf]=kde(A,length(tin),a,b);
kdeA=transpose(interp1(xmesh1, kdeA, xA));
pdp=pdp5_2sig(data1(:,1),data1(:,2),xmin,xmax,xint);
x=xmin:xint:xmax;
hl1 = plot(x,pdp,'Color',[0.1 0.8 0.1]);
ax1 = gca;
set(ax1,'XColor','k','YColor','k')
pdpmax = max(pdp);
axis([xmin xmax 0 pdpmax+0.1*pdpmax])
set(hl1,'linewidth',2)
set(gca,'xtick',[])
set(get(ax2,'Ylabel'),'String','probability')
legend('Probability Density Plot');
title('Filtered data');
		dim = [.75 .5 .3 .3];
		str = {'n = ', numsamples1};
		annotation('textbox',dim,'String',str,'FitBoxToText','on');

f2 = figure;        
x=xmin:xint:xmax;
pdp=pdp5_2sig(data2(:,1),data2(:,2),xmin,xmax,xint);
hist(data2(:,1), bins);
xlabel('Age (Ma)')
set(gca,'box','off')
axis([xmin xmax hist_ymin hist_ymax])
ax1 = gca;
set(ax1,'XColor','k','YColor','k')
set(get(ax1,'Ylabel'),'String','frequency')
ax2 = axes('Position',get(ax1,'Position'),...
'XAxisLocation','top',...
'YAxisLocation','right',...
'Color','none',...
'XColor','b','YColor','b');
hold on
a=xmin;
b=xmax;
c=xint;
xA = a:c:b;
xA = transpose(xA);
tin=linspace(1,length(xA),length(xA));
A = data2(:,1);
n = length(A);
[bandwidth,kdeA,xmesh1,cdf]=kde(A,length(tin),a,b);
kdeA=transpose(interp1(xmesh1, kdeA, xA));
pdp=pdp5_2sig(data2(:,1),data2(:,2),xmin,xmax,xint);
x=xmin:xint:xmax;
hl1 = plot(x,pdp,'Color',[0.1 0.8 0.1]);
ax1 = gca;
set(ax1,'XColor','k','YColor','k')
pdpmax = max(pdp);
axis([xmin xmax 0 pdpmax+0.1*pdpmax])
set(hl1,'linewidth',2)
set(gca,'xtick',[])
set(get(ax2,'Ylabel'),'String','probability')
legend('Probability Density Plot');
title('Rejected data');
		dim = [.75 .5 .3 .3];
		str = {'n = ', numsamples2};
		annotation('textbox',dim,'String',str,'FitBoxToText','on');

f3 = figure;        
x=xmin:xint:xmax;
pdp=pdp5_2sig(data3(:,1),data3(:,2),xmin,xmax,xint);
hist(data3(:,1), bins);
xlabel('Age (Ma)')
set(gca,'box','off')
axis([xmin xmax hist_ymin hist_ymax])
ax1 = gca;
set(ax1,'XColor','k','YColor','k')
set(get(ax1,'Ylabel'),'String','frequency')
ax2 = axes('Position',get(ax1,'Position'),...
'XAxisLocation','top',...
'YAxisLocation','right',...
'Color','none',...
'XColor','b','YColor','b');
hold on
a=xmin;
b=xmax;
c=xint;
xA = a:c:b;
xA = transpose(xA);
tin=linspace(1,length(xA),length(xA));
A = data3(:,1);
n = length(A);
[bandwidth,kdeA,xmesh1,cdf]=kde(A,length(tin),a,b);
kdeA=transpose(interp1(xmesh1, kdeA, xA));
pdp=pdp5_2sig(data1(:,1),data1(:,2),xmin,xmax,xint);
x=xmin:xint:xmax;
hl1 = plot(x,pdp,'Color',[0.1 0.8 0.1]);
ax1 = gca;
set(ax1,'XColor','k','YColor','k')
pdpmax = max(pdp);
axis([xmin xmax 0 pdpmax+0.1*pdpmax])
set(hl1,'linewidth',2)
set(gca,'xtick',[])
set(get(ax2,'Ylabel'),'String','probability')
legend('Probability Density Plot');
title('All data');
		dim = [.75 .5 .3 .3];
		str = {'n = ', numsamples3};
		annotation('textbox',dim,'String',str,'FitBoxToText','on');	



    case handles.radio_hist_kde

f1 = figure;
 
 		rad_on_kernel=get(handles.uipanel_kernel,'selectedobject');
		switch rad_on_kernel
		case handles.optimize      

		hist(data1(:,1), bins);
		set(gca,'box','off')
		axis([xmin xmax hist_ymin hist_ymax])
		ax1 = gca;
		set(ax1,'XColor','k','YColor','k')
		set(get(ax1,'Ylabel'),'String','frequency', 'FontSize', 7)
		xlabel('Age (Ma)', 'FontSize', 7)
		ax2 = axes('Units', 'character'); %create a new axis and set units to be character
		set(ax2, 'Position',get(ax1,'Position'),...
        'XAxisLocation','top',...
        'YAxisLocation','right',...
        'Color','none',...
        'XColor','k','YColor','k');
		hold on
		a=xmin;
		b=xmax;
		c=xint;
		xA = a:c:b;
		xA = transpose(xA);
		tin=linspace(1,length(xA),length(xA));
		A = data1(:,1);
		n = length(A);
		[bandwidth,kdeA,xmesh1,cdf]=kde(A,length(tin),a,b);
		kdeA=transpose(interp1(xmesh1, kdeA, xA));
		hl2 = plot(xA,kdeA,'Color',[1 0 0]);
		ax1 = gca;
		set(ax1,'XColor','k','YColor','k')
		kdemax = max(kdeA);
		axis([xmin xmax 0 kdemax+0.2*kdemax])
		set(gca,'xtick',[])
		set(get(ax2,'Ylabel'),'String','probability')
		lgnd=legend('Kernel Density Estimate');
		set(hl2,'linewidth',2) 
		set(handles.optimize_text, 'String', bandwidth); 
		set(lgnd,'color','w');
		legend boxoff

		case handles.Myr_kernel

		hist(data1(:,1), bins);
		set(gca,'box','off')
		axis([xmin xmax hist_ymin hist_ymax])
		ax1 = gca;
		set(ax1,'XColor','k','YColor','k')
		set(get(ax1,'Ylabel'),'String','frequency', 'FontSize', 7)
		xlabel('Age (Ma)', 'FontSize', 7)
		ax2 = axes('Units', 'character'); %create a new axis and set units to be character
		set(ax2, 'Position',get(ax1,'Position'),...
        'XAxisLocation','top',...
        'YAxisLocation','right',...
        'Color','none',...
        'XColor','k','YColor','k');
		hold on
		x=xmin:xint:xmax;
		kernel = str2num(get(handles.Myr_Kernel_text,'String'));
		kernel_data1(1:length(data1(:,1)),1) = kernel;
		kde1=pdp5_2sig(data1(:,1),kernel_data1,xmin,xmax,xint);    
		hl2 = plot(x,kde1,'Color',[1 0 0]);
		ax1 = gca;
		set(ax1,'XColor','k','YColor','k')
		kdemax = max(kde1);
		axis([xmin xmax 0 kdemax+0.2*kdemax])
		set(gca,'xtick',[])
		set(get(ax2,'Ylabel'),'String','probability')
		lgnd=legend('Kernel Density Estimate');
		set(hl2,'linewidth',2) 
		set(lgnd,'color','w');
		legend boxoff
		end

    case handles.radio_hist_pdp_kde
	axes(handles.axes_distribution);        
	x=xmin:xint:xmax;
	pdp=pdp5_2sig(data1(:,1),data1(:,2),xmin,xmax,xint);
	hist(data1(:,1), bins);
	set(gca,'box','off')
	xlabel('Age (Ma)', 'FontSize', 7)
	axis([xmin xmax hist_ymin hist_ymax])
	ax1 = gca;
	set(ax1,'XColor','k','YColor','k')
	set(get(ax1,'Ylabel'),'String','frequency')
	ax2 = axes('Units', 'character'); %create a new axis and set units to be character
	set(ax2, 'Position',get(ax1,'Position'),...
    'XAxisLocation','top',...
    'YAxisLocation','right',...
    'Color','none',...
    'XColor','k','YColor','k');
	hold on

 		rad_on_kernel=get(handles.uipanel_kernel,'selectedobject');
		switch rad_on_kernel
		case handles.optimize

		a=xmin;
		b=xmax;
		c=xint;
		xA = a:c:b;
		xA = transpose(xA);
		tin=linspace(1,length(xA),length(xA));
		A = data1(:,1);
		n = length(A);
		[bandwidth,kdeA,xmesh1,cdf]=kde(A,length(tin),a,b);
		kdeA=transpose(interp1(xmesh1, kdeA, xA));
		pdp=pdp5_2sig(data1(:,1),data1(:,2),xmin,xmax,xint);
		x=xmin:xint:xmax;
		hl1 = plot(x,pdp,'Color',[0.1 0.8 0.1]);
		hl2 = plot(xA,kdeA,'Color',[1 0 0]);
		ax1 = gca;
		set(ax1,'XColor','k','YColor','k')
		pdpmax = max(pdp);
		kdemax = max(kdeA);
		maxboth = [pdpmax,kdemax];
		maxboth = max(maxboth);
		axis([xmin xmax 0 maxboth+0.1*maxboth])
		set(gca,'xtick',[])
		set(get(ax2,'Ylabel'),'String','probability')
		lgnd=legend('Probability Density Plot','Kernel Density Estimate');
		set(hl1,'linewidth',2)
		set(hl2,'linewidth',2)     
   		set(handles.optimize_text, 'String', bandwidth); 
		set(lgnd,'color','w');
		legend boxoff
		
		case handles.Myr_kernel

		a=xmin;
		b=xmax;
		c=xint;
		xA = a:c:b;
		xA = transpose(xA);
		tin=linspace(1,length(xA),length(xA));
		A = data1(:,1);
		n = length(A);
		[bandwidth,kdeA,xmesh1,cdf]=kde(A,length(tin),a,b);
		kdeA=transpose(interp1(xmesh1, kdeA, xA));
		pdp=pdp5_2sig(data1(:,1),data1(:,2),xmin,xmax,xint);
		x=xmin:xint:xmax;
		hl1 = plot(x,pdp,'Color',[0.1 0.8 0.1]);
		x=xmin:xint:xmax;
		kernel = str2num(get(handles.Myr_Kernel_text,'String'));
		kernel_data1(1:length(data1(:,1)),1) = kernel;
		kde1=pdp5_2sig(data1(:,1),kernel_data1,xmin,xmax,xint);    
		hl2 = plot(x,kde1,'Color',[1 0 0]);		
		ax1 = gca;
		set(ax1,'XColor','k','YColor','k')
		pdpmax = max(pdp);
		kdemax = max(kde1);
		maxboth = [pdpmax,kdemax];
		maxboth = max(maxboth);
		axis([xmin xmax 0 maxboth+0.1*maxboth])
		set(gca,'xtick',[])
		set(get(ax2,'Ylabel'),'String','probability')
		lgnd=legend('Probability Density Plot','Kernel Density Estimate');
		set(hl1,'linewidth',2)
		set(hl2,'linewidth',2)  
		set(lgnd,'color','w');
		legend boxoff
		end
	end























































function known_p68_Callback(hObject, eventdata, handles)

function known_p68_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function known_s68_Callback(hObject, eventdata, handles)
% hObject    handle to known_s68 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of known_s68 as text
%        str2double(get(hObject,'String')) returns contents of known_s68 as a double


% --- Executes during object creation, after setting all properties.
function known_s68_CreateFcn(hObject, eventdata, handles)
% hObject    handle to known_s68 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function known_p68err_Callback(hObject, eventdata, handles)
% hObject    handle to known_p68err (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of known_p68err as text
%        str2double(get(hObject,'String')) returns contents of known_p68err as a double


% --- Executes during object creation, after setting all properties.
function known_p68err_CreateFcn(hObject, eventdata, handles)
% hObject    handle to known_p68err (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function known_s68err_Callback(hObject, eventdata, handles)
% hObject    handle to known_s68err (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of known_s68err as text
%        str2double(get(hObject,'String')) returns contents of known_s68err as a double


% --- Executes during object creation, after setting all properties.
function known_s68err_CreateFcn(hObject, eventdata, handles)
% hObject    handle to known_s68err (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function known_p76_Callback(hObject, eventdata, handles)
% hObject    handle to known_p76 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of known_p76 as text
%        str2double(get(hObject,'String')) returns contents of known_p76 as a double


% --- Executes during object creation, after setting all properties.
function known_p76_CreateFcn(hObject, eventdata, handles)
% hObject    handle to known_p76 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function known_s76_Callback(hObject, eventdata, handles)
% hObject    handle to known_s76 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of known_s76 as text
%        str2double(get(hObject,'String')) returns contents of known_s76 as a double


% --- Executes during object creation, after setting all properties.
function known_s76_CreateFcn(hObject, eventdata, handles)
% hObject    handle to known_s76 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function known_p76err_Callback(hObject, eventdata, handles)
% hObject    handle to known_p76err (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of known_p76err as text
%        str2double(get(hObject,'String')) returns contents of known_p76err as a double


% --- Executes during object creation, after setting all properties.
function known_p76err_CreateFcn(hObject, eventdata, handles)
% hObject    handle to known_p76err (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function known_s76err_Callback(hObject, eventdata, handles)
% hObject    handle to known_s76err (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of known_s76err as text
%        str2double(get(hObject,'String')) returns contents of known_s76err as a double


% --- Executes during object creation, after setting all properties.
function known_s76err_CreateFcn(hObject, eventdata, handles)
% hObject    handle to known_s76err (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function known_p75_Callback(hObject, eventdata, handles)
% hObject    handle to known_p75 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of known_p75 as text
%        str2double(get(hObject,'String')) returns contents of known_p75 as a double


% --- Executes during object creation, after setting all properties.
function known_p75_CreateFcn(hObject, eventdata, handles)
% hObject    handle to known_p75 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function known_s75_Callback(hObject, eventdata, handles)
% hObject    handle to known_s75 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of known_s75 as text
%        str2double(get(hObject,'String')) returns contents of known_s75 as a double


% --- Executes during object creation, after setting all properties.
function known_s75_CreateFcn(hObject, eventdata, handles)
% hObject    handle to known_s75 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function known_p75err_Callback(hObject, eventdata, handles)
% hObject    handle to known_p75err (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of known_p75err as text
%        str2double(get(hObject,'String')) returns contents of known_p75err as a double


% --- Executes during object creation, after setting all properties.
function known_p75err_CreateFcn(hObject, eventdata, handles)
% hObject    handle to known_p75err (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function known_s75err_Callback(hObject, eventdata, handles)
% hObject    handle to known_s75err (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of known_s75err as text
%        str2double(get(hObject,'String')) returns contents of known_s75err as a double


% --- Executes during object creation, after setting all properties.
function known_s75err_CreateFcn(hObject, eventdata, handles)
% hObject    handle to known_s75err (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function known_p82_Callback(hObject, eventdata, handles)
% hObject    handle to known_p82 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of known_p82 as text
%        str2double(get(hObject,'String')) returns contents of known_p82 as a double


% --- Executes during object creation, after setting all properties.
function known_p82_CreateFcn(hObject, eventdata, handles)
% hObject    handle to known_p82 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function known_s82_Callback(hObject, eventdata, handles)
% hObject    handle to known_s82 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of known_s82 as text
%        str2double(get(hObject,'String')) returns contents of known_s82 as a double


% --- Executes during object creation, after setting all properties.
function known_s82_CreateFcn(hObject, eventdata, handles)
% hObject    handle to known_s82 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function known_p82err_Callback(hObject, eventdata, handles)
% hObject    handle to known_p82err (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of known_p82err as text
%        str2double(get(hObject,'String')) returns contents of known_p82err as a double


% --- Executes during object creation, after setting all properties.
function known_p82err_CreateFcn(hObject, eventdata, handles)
% hObject    handle to known_p82err (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function known_s82err_Callback(hObject, eventdata, handles)
% hObject    handle to known_s82err (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of known_s82err as text
%        str2double(get(hObject,'String')) returns contents of known_s82err as a double


% --- Executes during object creation, after setting all properties.
function known_s82err_CreateFcn(hObject, eventdata, handles)
% hObject    handle to known_s82err (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit20_Callback(hObject, eventdata, handles)
% hObject    handle to edit20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit20 as text
%        str2double(get(hObject,'String')) returns contents of edit20 as a double


% --- Executes during object creation, after setting all properties.
function edit20_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit21_Callback(hObject, eventdata, handles)
% hObject    handle to edit21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit21 as text
%        str2double(get(hObject,'String')) returns contents of edit21 as a double


% --- Executes during object creation, after setting all properties.
function edit21_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit22_Callback(hObject, eventdata, handles)
% hObject    handle to edit22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit22 as text
%        str2double(get(hObject,'String')) returns contents of edit22 as a double


% --- Executes during object creation, after setting all properties.
function edit22_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit23_Callback(hObject, eventdata, handles)
% hObject    handle to edit23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit23 as text
%        str2double(get(hObject,'String')) returns contents of edit23 as a double


% --- Executes during object creation, after setting all properties.
function edit23_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function spline_breaks_Callback(hObject, eventdata, handles)
% hObject    handle to spline_breaks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of spline_breaks as text
%        str2double(get(hObject,'String')) returns contents of spline_breaks as a double


% --- Executes during object creation, after setting all properties.
function spline_breaks_CreateFcn(hObject, eventdata, handles)
% hObject    handle to spline_breaks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in example_prn.
function example_prn_Callback(hObject, eventdata, handles)
% hObject    handle to example_prn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

LiveUPbDataReductionExample;



function edit25_Callback(hObject, eventdata, handles)
% hObject    handle to edit25 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit25 as text
%        str2double(get(hObject,'String')) returns contents of edit25 as a double


% --- Executes during object creation, after setting all properties.
function edit25_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit25 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit26_Callback(hObject, eventdata, handles)
% hObject    handle to edit26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit26 as text
%        str2double(get(hObject,'String')) returns contents of edit26 as a double


% --- Executes during object creation, after setting all properties.
function edit26_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit27_Callback(hObject, eventdata, handles)
% hObject    handle to edit27 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit27 as text
%        str2double(get(hObject,'String')) returns contents of edit27 as a double


% --- Executes during object creation, after setting all properties.
function edit27_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit27 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit28_Callback(hObject, eventdata, handles)
% hObject    handle to edit28 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit28 as text
%        str2double(get(hObject,'String')) returns contents of edit28 as a double


% --- Executes during object creation, after setting all properties.
function edit28_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit28 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)







% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

xmin = str2num(get(handles.edit21,'String'));
xmax = str2num(get(handles.edit20,'String'));
ymin = str2num(get(handles.edit23,'String'));
ymax = str2num(get(handles.edit22,'String'));
agelabelmin = str2num(get(handles.edit63,'String'));
agelabelmax = str2num(get(handles.edit62,'String'));
agelabelint = str2num(get(handles.edit64,'String'));

concordant_samples_sort = handles.concordant_samples_sort;
discordant_samples_sort = handles.discordant_samples_sort;

concordant_data = [concordant_samples_sort(:,2),concordant_samples_sort(:,3), ...
	concordant_samples_sort(:,4),concordant_samples_sort(:,5),...
	concordant_samples_sort(:,6),concordant_samples_sort(:,7)];

concordant_data_rho = concordant_samples_sort(:,8);

concordant_data_center=[concordant_data(:,3),concordant_data(:,5)];

concordant_data_sigx_abs = concordant_data(:,3).*concordant_data(:,4).*0.01;
concordant_data_sigy_abs = concordant_data(:,5).*concordant_data(:,6).*0.01;

concordant_data_sigx_sq = concordant_data_sigx_abs.*concordant_data_sigx_abs;
concordant_data_sigy_sq = concordant_data_sigy_abs.*concordant_data_sigy_abs;
concordant_data_rho_sigx_sigy = concordant_data_sigx_abs.*concordant_data_sigy_abs.*concordant_data_rho;
sigmarule=1.25;
numpoints=50;





%replaced with 32 bit code
%replaced with 32 bit code
%replaced with 32 bit code
axes(handles.axes_current_intensities);

for i = 1:length(concordant_data_rho);

concordant_data_covmat=[concordant_data_sigx_sq(i,1),concordant_data_rho_sigx_sigy(i,1);concordant_data_rho_sigx_sigy(i,1), ...
	concordant_data_sigy_sq(i,1)];
[concordant_data_PD,concordant_data_PV]=eig(concordant_data_covmat);
concordant_data_PV=diag(concordant_data_PV).^.5;
concordant_data_theta=linspace(0,2.*pi,numpoints)';
concordant_data_elpt=[cos(concordant_data_theta),sin(concordant_data_theta)]*diag(concordant_data_PV)*concordant_data_PD';
numsigma=length(sigmarule);
concordant_data_elpt=repmat(concordant_data_elpt,1,numsigma).*repmat(sigmarule(floor(1:.5:numsigma+.5)),numpoints,1);
concordant_data_elpt=concordant_data_elpt+repmat(concordant_data_center(i,1:2),numpoints,numsigma);
plot(concordant_data_elpt(:,1:2:end),concordant_data_elpt(:,2:2:end),'b','LineWidth',1.2);
hold on
end

timemin = 0;
timemax = 4500000000;
timeinterval = 50000000;
time = timemin:timeinterval:timemax;

x = exp(0.00000000098485.*time)-1;
y = exp(0.000000000155125.*time)-1;

age_label_num = [agelabelmin+agelabelint:agelabelint:agelabelmax];
for i=1:length(age_label_num)
age_label(i,1) = {sprintf('%.1f',age_label_num(1,i))};
age_label2(i,1) = strcat(age_label(i,1),' Ga');
end
age_label_num = age_label_num.*1000000000;
age_label_x = exp(0.00000000098485.*age_label_num)-1;
age_label_y = exp(0.000000000155125.*age_label_num)-1;

plot(x,y,'k','LineWidth',1.4)
hold on
scatter(age_label_x, age_label_y,20,'MarkerEdgeColor','k','MarkerFaceColor','y','LineWidth',1.5)
labelpoints (age_label_x, age_label_y, age_label2, 'SE');

axis([xmin xmax ymin ymax]);
xlabel('207Pb/235U', 'FontSize', 7);
ylabel('206Pb/238U', 'FontSize', 7);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

discordant_data = [discordant_samples_sort(:,2),discordant_samples_sort(:,3), ...
	discordant_samples_sort(:,4),discordant_samples_sort(:,5),...
	discordant_samples_sort(:,6),discordant_samples_sort(:,7)];

discordant_data_rho = discordant_samples_sort(:,8);

discordant_data_center=[discordant_data(:,3),discordant_data(:,5)];

discordant_data_sigx_abs = discordant_data(:,3).*discordant_data(:,4).*0.01;
discordant_data_sigy_abs = discordant_data(:,5).*discordant_data(:,6).*0.01;

discordant_data_sigx_sq = discordant_data_sigx_abs.*discordant_data_sigx_abs;
discordant_data_sigy_sq = discordant_data_sigy_abs.*discordant_data_sigy_abs;
discordant_data_rho_sigx_sigy = discordant_data_sigx_abs.*discordant_data_sigy_abs.*discordant_data_rho;
sigmarule=1.25;
numpoints=50;
set(gca,'fontsize',20)

axes(handles.axes_current_concordia);

for i = 1:length(discordant_data_rho);

discordant_data_covmat=[discordant_data_sigx_sq(i,1),discordant_data_rho_sigx_sigy(i,1);discordant_data_rho_sigx_sigy(i,1), ...
	discordant_data_sigy_sq(i,1)];
[discordant_data_PD,discordant_data_PV]=eig(discordant_data_covmat);
discordant_data_PV=diag(discordant_data_PV).^.5;
discordant_data_theta=linspace(0,2.*pi,numpoints)';
discordant_data_elpt=[cos(discordant_data_theta),sin(discordant_data_theta)]*diag(discordant_data_PV)*discordant_data_PD';
numsigma=length(sigmarule);
discordant_data_elpt=repmat(discordant_data_elpt,1,numsigma).*repmat(sigmarule(floor(1:.5:numsigma+.5)),numpoints,1);
discordant_data_elpt=discordant_data_elpt+repmat(discordant_data_center(i,1:2),numpoints,numsigma);
plot(discordant_data_elpt(:,1:2:end),discordant_data_elpt(:,2:2:end),'r','LineWidth',1.2);
hold on
end

timemin = 0;
timemax = 4500000000;
timeinterval = 50000000;
time = timemin:timeinterval:timemax;

x = exp(0.00000000098485.*time)-1;
y = exp(0.000000000155125.*time)-1;

plot(x,y,'k','LineWidth',1.4)
hold on
scatter(age_label_x, age_label_y,20,'MarkerEdgeColor','k','MarkerFaceColor','y','LineWidth',1.5)
labelpoints (age_label_x, age_label_y, age_label2, 'SE');

axis([xmin xmax ymin ymax]);
xlabel('207Pb/235U', 'FontSize', 7);
ylabel('206Pb/238U', 'FontSize', 7);

nsamp1 = num2str(length(concordant_samples_sort(:,1)));
nsamp2 = num2str(length(discordant_samples_sort(:,1)));

set(handles.text56,'String',nsamp1);
set(handles.text58,'String',nsamp2);



% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton10.
function pushbutton10_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton12.
function pushbutton12_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton13.
function pushbutton13_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




function edit29_Callback(hObject, eventdata, handles)
% hObject    handle to edit29 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit29 as text
%        str2double(get(hObject,'String')) returns contents of edit29 as a double


% --- Executes during object creation, after setting all properties.
function edit29_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit29 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit30_Callback(hObject, eventdata, handles)
% hObject    handle to edit30 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit30 as text
%        str2double(get(hObject,'String')) returns contents of edit30 as a double


% --- Executes during object creation, after setting all properties.
function edit30_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit30 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit31_Callback(hObject, eventdata, handles)
% hObject    handle to edit31 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit31 as text
%        str2double(get(hObject,'String')) returns contents of edit31 as a double


% --- Executes during object creation, after setting all properties.
function edit31_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit31 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit32_Callback(hObject, eventdata, handles)
% hObject    handle to edit32 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit32 as text
%        str2double(get(hObject,'String')) returns contents of edit32 as a double


% --- Executes during object creation, after setting all properties.
function edit32_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit32 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function filter_transition_68_76_Callback(hObject, eventdata, handles)
% hObject    handle to filter_transition_68_76 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of filter_transition_68_76 as text
%        str2double(get(hObject,'String')) returns contents of filter_transition_68_76 as a double


% --- Executes during object creation, after setting all properties.
function filter_transition_68_76_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filter_transition_68_76 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function filter_unc_cutoff_Callback(hObject, eventdata, handles)
% hObject    handle to filter_unc_cutoff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of filter_unc_cutoff as text
%        str2double(get(hObject,'String')) returns contents of filter_unc_cutoff as a double


% --- Executes during object creation, after setting all properties.
function filter_unc_cutoff_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filter_unc_cutoff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function filter_disc_transition_Callback(hObject, eventdata, handles)
% hObject    handle to filter_disc_transition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of filter_disc_transition as text
%        str2double(get(hObject,'String')) returns contents of filter_disc_transition as a double


% --- Executes during object creation, after setting all properties.
function filter_disc_transition_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filter_disc_transition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function filter_disc_rev_Callback(hObject, eventdata, handles)
% hObject    handle to filter_disc_rev (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of filter_disc_rev as text
%        str2double(get(hObject,'String')) returns contents of filter_disc_rev as a double


% --- Executes during object creation, after setting all properties.
function filter_disc_rev_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filter_disc_rev (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function filter_disc_young_Callback(hObject, eventdata, handles)
% hObject    handle to filter_disc_young (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of filter_disc_young as text
%        str2double(get(hObject,'String')) returns contents of filter_disc_young as a double


% --- Executes during object creation, after setting all properties.
function filter_disc_young_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filter_disc_young (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function filter_disc_old_Callback(hObject, eventdata, handles)
% hObject    handle to filter_disc_old (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of filter_disc_old as text
%        str2double(get(hObject,'String')) returns contents of filter_disc_old as a double


% --- Executes during object creation, after setting all properties.
function filter_disc_old_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filter_disc_old (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton15.
function pushbutton15_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%cla(handles.axes9,'reset'); %clear PDP plot
%cla(handles.axes17,'reset'); %clear CDF plot

% --- Executes on button press in pushbutton16.
function pushbutton16_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton17.
function pushbutton17_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton18.
function pushbutton18_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton20.
function pushbutton20_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

cla(handles.axes_current_intensities,'reset'); %clear PDP plot
cla(handles.axes_current_concordia,'reset'); %clear CDF plot
% --- Executes on button press in pushbutton21.
function pushbutton21_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton25.
function pushbutton25_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton25 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edit43_Callback(hObject, eventdata, handles)
% hObject    handle to edit43 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit43 as text
%        str2double(get(hObject,'String')) returns contents of edit43 as a double


% --- Executes during object creation, after setting all properties.
function edit43_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit43 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit44_Callback(hObject, eventdata, handles)
% hObject    handle to edit44 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit44 as text
%        str2double(get(hObject,'String')) returns contents of edit44 as a double


% --- Executes during object creation, after setting all properties.
function edit44_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit44 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton26.
function pushbutton26_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edit45_Callback(hObject, eventdata, handles)
% hObject    handle to edit45 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit45 as text
%        str2double(get(hObject,'String')) returns contents of edit45 as a double


% --- Executes during object creation, after setting all properties.
function edit45_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit45 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit46_Callback(hObject, eventdata, handles)
% hObject    handle to edit46 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit46 as text
%        str2double(get(hObject,'String')) returns contents of edit46 as a double


% --- Executes during object creation, after setting all properties.
function edit46_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit46 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit47_Callback(hObject, eventdata, handles)
% hObject    handle to edit47 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit47 as text
%        str2double(get(hObject,'String')) returns contents of edit47 as a double


% --- Executes during object creation, after setting all properties.
function edit47_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit47 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit48_Callback(hObject, eventdata, handles)
% hObject    handle to edit48 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit48 as text
%        str2double(get(hObject,'String')) returns contents of edit48 as a double


% --- Executes during object creation, after setting all properties.
function edit48_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit48 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton27.
function pushbutton27_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton27 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton28.
function pushbutton28_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton28 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edit49_Callback(hObject, eventdata, handles)
% hObject    handle to edit49 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit49 as text
%        str2double(get(hObject,'String')) returns contents of edit49 as a double


% --- Executes during object creation, after setting all properties.
function edit49_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit49 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit50_Callback(hObject, eventdata, handles)
% hObject    handle to edit50 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit50 as text
%        str2double(get(hObject,'String')) returns contents of edit50 as a double


% --- Executes during object creation, after setting all properties.
function edit50_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit50 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end






function edit51_Callback(hObject, eventdata, handles)
% hObject    handle to edit51 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit51 as text
%        str2double(get(hObject,'String')) returns contents of edit51 as a double


% --- Executes during object creation, after setting all properties.
function edit51_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit51 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit52_Callback(hObject, eventdata, handles)
% hObject    handle to edit52 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit52 as text
%        str2double(get(hObject,'String')) returns contents of edit52 as a double


% --- Executes during object creation, after setting all properties.
function edit52_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit52 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit53_Callback(hObject, eventdata, handles)
% hObject    handle to edit53 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit53 as text
%        str2double(get(hObject,'String')) returns contents of edit53 as a double


% --- Executes during object creation, after setting all properties.
function edit53_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit53 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit54_Callback(hObject, eventdata, handles)
% hObject    handle to edit54 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit54 as text
%        str2double(get(hObject,'String')) returns contents of edit54 as a double


% --- Executes during object creation, after setting all properties.
function edit54_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit54 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton30.
function pushbutton30_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton30 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function xmin_Callback(hObject, eventdata, handles)
% hObject    handle to xmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xmin as text
%        str2double(get(hObject,'String')) returns contents of xmin as a double


% --- Executes during object creation, after setting all properties.
function xmin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit56_Callback(hObject, eventdata, handles)
% hObject    handle to edit56 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit56 as text
%        str2double(get(hObject,'String')) returns contents of edit56 as a double


% --- Executes during object creation, after setting all properties.
function edit56_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit56 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function xmax_Callback(hObject, eventdata, handles)
% hObject    handle to xmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xmax as text
%        str2double(get(hObject,'String')) returns contents of xmax as a double


% --- Executes during object creation, after setting all properties.
function xmax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function xint_Callback(hObject, eventdata, handles)
% hObject    handle to xint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xint as text
%        str2double(get(hObject,'String')) returns contents of xint as a double


% --- Executes during object creation, after setting all properties.
function xint_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ymin_Callback(hObject, eventdata, handles)
% hObject    handle to ymin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ymin as text
%        str2double(get(hObject,'String')) returns contents of ymin as a double


% --- Executes during object creation, after setting all properties.
function ymin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ymin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ymax_Callback(hObject, eventdata, handles)
% hObject    handle to ymax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ymax as text
%        str2double(get(hObject,'String')) returns contents of ymax as a double


% --- Executes during object creation, after setting all properties.
function ymax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ymax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function bins_Callback(hObject, eventdata, handles)
% hObject    handle to bins (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of bins as text
%        str2double(get(hObject,'String')) returns contents of bins as a double


% --- Executes during object creation, after setting all properties.
function bins_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bins (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton31.
function pushbutton31_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton31 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

cla reset
set(gca,'xtick',[],'ytick',[],'Xcolor','w','Ycolor','w')

% --- Executes on button press in plot_rejected.
function plot_rejected_Callback(hObject, eventdata, handles)
% hObject    handle to plot_rejected (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

axes(handles.axes_distribution); 
cla reset
set(gca,'xtick',[],'ytick',[],'Xcolor','w','Ycolor','w')

data2 = handles.data2;

xmin = str2num(get(handles.xmin,'String'));
xmax = str2num(get(handles.xmax,'String'));
xint = str2num(get(handles.xint,'String'));
hist_ymin = str2num(get(handles.ymin,'String'));
hist_ymax = str2num(get(handles.ymax,'String'));
bins = str2num(get(handles.bins,'String'));
 
rad_on=get(handles.uipanel_distribution,'selectedobject');
switch rad_on
    case handles.radio_hist
    
axes(handles.axes_distribution);    
hist(data2(:,1), bins);
set(gca,'box','off')
axis([xmin xmax hist_ymin hist_ymax])
set(get(gca,'child'),'FaceColor',[0.9,0.9,0.9],'EdgeColor','k');
ax1 = gca;
set(ax1,'XColor','k','YColor','k')
set(get(ax1,'Ylabel'),'String','frequency')    
set(get(ax1,'Xlabel'),'String','Age (Ma)')
 
    case handles.radio_pdp
 
axes(handles.axes_distribution);     
x=xmin:xint:xmax;
pdp=pdp5_2sig(data2(:,1),data2(:,2),xmin,xmax,xint);    
hl1 = plot(x,pdp,'Color','k');
ax1 = gca;
set(ax1,'XColor','k','YColor','k')
pdpmax = max(pdp);
axis([xmin xmax 0 pdpmax+0.1*pdpmax])
legend('Probability Density Plot');
set(hl1,'linewidth',1.5)
set(gca,'box','off')
ax1 = gca;
set(ax1,'XColor','k','YColor','k')
set(get(ax1,'Ylabel'),'String','probability')    
set(get(ax1,'Xlabel'),'String','Age (Ma)')
 
    case handles.radio_kde
 
axes(handles.axes_distribution);     
x=xmin:xint:xmax;
a=xmin;
b=xmax;
c=xint;
xA = a:c:b;
xA = transpose(xA);
tin=linspace(1,length(xA),length(xA));
A = data2(:,1);
n = length(A);
[bandwidth,kdeA,xmesh1,cdf]=kde(A,length(tin),a,b);
kdeA=transpose(interp1(xmesh1, kdeA, xA));
 
hl1 = plot(tin,kdeA,'Color','b');
ax1 = gca;
set(ax1,'XColor','k','YColor','k')
kdemax = max(kdeA);
axis([xmin xmax 0 kdemax+0.1*kdemax])
legend('Kernel Density Estimate');
set(hl1,'linewidth',1.5)
set(gca,'box','off')
ax1 = gca;
set(ax1,'XColor','k','YColor','k')
set(get(ax1,'Ylabel'),'String','probability')    
set(get(ax1,'Xlabel'),'String','Age (Ma)')   
 
    case handles.radio_hist_pdp
 
axes(handles.axes_distribution);        
x=xmin:xint:xmax;
pdp=pdp5_2sig(data2(:,1),data2(:,2),xmin,xmax,xint);
 
hist(data2(:,1), bins);
set(gca,'box','off')
axis([xmin xmax hist_ymin hist_ymax])
set(get(gca,'child'),'FaceColor',[0.9,0.9,0.9],'EdgeColor','k');
ax1 = gca;
set(ax1,'XColor','k','YColor','k')
set(get(ax1,'Ylabel'),'String','frequency')
xlabel('Age (Ma)')
 
ax2 = axes('Units', 'character'); %create a new axis and set units to be character
set(ax2, 'Position',get(ax1,'Position'),...
             'XAxisLocation','top',...
             'YAxisLocation','right',...
             'Color','none',...
             'XColor','k','YColor','k');
 
hold on
 
a=xmin;
b=xmax;
c=xint;
xA = a:c:b;
xA = transpose(xA);
tin=linspace(1,length(xA),length(xA));
A = data2(:,1);
n = length(A);
[bandwidth,kdeA,xmesh1,cdf]=kde(A,length(tin),a,b);
kdeA=transpose(interp1(xmesh1, kdeA, xA));
 
pdp=pdp5_2sig(data2(:,1),data2(:,2),xmin,xmax,xint);
x=xmin:xint:xmax;
hl1 = plot(x,pdp,'Color','k');
%hl2 = plot(xA,kdeA,'b');
ax1 = gca;
set(ax1,'XColor','k','YColor','k')
 
pdpmax = max(pdp);
kdemax = max(kdeA);
maxboth = [pdpmax,kdemax];
maxboth = max(maxboth);
axis([xmin xmax 0 maxboth+0.1*maxboth])
 
set(gca,'xtick',[])
set(get(ax2,'Ylabel'),'String','probability')
 
legend('Probability Density Plot');
set(hl1,'linewidth',1.5)
%set(hl2,'linewidth',2) 
%set(get(ax2,'Xlabel'),'String','Age (Ma)') 
 
    case handles.radio_hist_kde
        
axes(handles.axes_distribution);        
x=xmin:xint:xmax;
pdp=pdp5_2sig(data2(:,1),data2(:,2),xmin,xmax,xint);
 
hist(data2(:,1), bins);
set(gca,'box','off')
axis([xmin xmax hist_ymin hist_ymax])
set(get(gca,'child'),'FaceColor',[0.9,0.9,0.9],'EdgeColor','k');
ax1 = gca;
set(ax1,'XColor','k','YColor','k')
set(get(ax1,'Ylabel'),'String','frequency')
xlabel('Age (Ma)')
 
ax2 = axes('Units', 'character'); %create a new axis and set units to be character
set(ax2, 'Position',get(ax1,'Position'),...
             'XAxisLocation','top',...
             'YAxisLocation','right',...
             'Color','none',...
             'XColor','k','YColor','k');
 
hold on
 
a=xmin;
b=xmax;
c=xint;
xA = a:c:b;
xA = transpose(xA);
tin=linspace(1,length(xA),length(xA));
A = data2(:,1);
n = length(A);
[bandwidth,kdeA,xmesh1,cdf]=kde(A,length(tin),a,b);
kdeA=transpose(interp1(xmesh1, kdeA, xA));
 
pdp=pdp5_2sig(data2(:,1),data2(:,2),xmin,xmax,xint);
x=xmin:xint:xmax;
%hl1 = plot(x,pdp,'Color','k');
hl2 = plot(xA,kdeA,'b');
ax1 = gca;
set(ax1,'XColor','k','YColor','k')
 
pdpmax = max(pdp);
kdemax = max(kdeA);
maxboth = [pdpmax,kdemax];
maxboth = max(maxboth);
axis([xmin xmax 0 maxboth+0.1*maxboth])
 
set(gca,'xtick',[])
set(get(ax2,'Ylabel'),'String','probability')
 
legend('Probability Density Plot');
%set(hl1,'linewidth',1.5)
set(hl2,'linewidth',1.5) 
%set(get(ax2,'Xlabel'),'String','Age (Ma)')         
 
    
    case handles.radio_hist_pdp_kde
 
axes(handles.axes_distribution);        
x=xmin:xint:xmax;
pdp=pdp5_2sig(data2(:,1),data2(:,2),xmin,xmax,xint);
 
hist(data2(:,1), bins);
set(gca,'box','off')
axis([xmin xmax hist_ymin hist_ymax])
set(get(gca,'child'),'FaceColor',[0.9,0.9,0.9],'EdgeColor','k');
ax1 = gca;
set(ax1,'XColor','k','YColor','k')
set(get(ax1,'Ylabel'),'String','frequency')
 
 
ax2 = axes('Units', 'character'); %create a new axis and set units to be character
set(ax2, 'Position',get(ax1,'Position'),...
             'XAxisLocation','top',...
             'YAxisLocation','right',...
             'Color','none',...
             'XColor','k','YColor','k');
 
hold on
 
a=xmin;
b=xmax;
c=xint;
xA = a:c:b;
xA = transpose(xA);
tin=linspace(1,length(xA),length(xA));
A = data2(:,1);
n = length(A);
[bandwidth,kdeA,xmesh1,cdf]=kde(A,length(tin),a,b);
kdeA=transpose(interp1(xmesh1, kdeA, xA));
 
pdp=pdp5_2sig(data2(:,1),data2(:,2),xmin,xmax,xint);
x=xmin:xint:xmax;
hl1 = plot(x,pdp,'Color','k');
hl2 = plot(xA,kdeA,'b');
ax1 = gca;
set(ax1,'XColor','k','YColor','k')
 
pdpmax = max(pdp);
kdemax = max(kdeA);
maxboth = [pdpmax,kdemax];
maxboth = max(maxboth);
axis([xmin xmax 0 maxboth+0.1*maxboth])
 
set(gca,'xtick',[])
set(get(ax2,'Ylabel'),'String','probability')
 
legend('Probability Density Plot','Kernel Density Estimate');
set(hl1,'linewidth',1.5)
set(hl2,'linewidth',1.5)        
        
        
         case handles.radio_pdp
        Two_Sample_Compare_PDP;
    
    case handles.radio_hist_pdp_kde
        Two_Sample_Compare_KDE;
        
        
        
    otherwise
        set(handles.edit_radioselect,'string','');
end
 
 
nsamp = num2str(length(data2));
set(handles.n_plotted,'String',nsamp);




% --- Executes on button press in pushbutton33.
function pushbutton33_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton33 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton34.
function pushbutton34_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton34 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in radio_pdp.
function radio_pdp_Callback(hObject, eventdata, handles)
% hObject    handle to radio_pdp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radio_pdp

% --- Executes on button press in plot_filtered.
function plot_filtered_Callback(hObject, eventdata, handles)
% hObject    handle to plot_filtered (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

axes(handles.axes_distribution); 
cla reset

set(gca,'xtick',[],'ytick',[],'Xcolor','w','Ycolor','w')

data1 = handles.data1;

xmin = str2num(get(handles.xmin,'String'));
xmax = str2num(get(handles.xmax,'String'));
xint = str2num(get(handles.xint,'String'));
hist_ymin = str2num(get(handles.ymin,'String'));
hist_ymax = str2num(get(handles.ymax,'String'));
bins = str2num(get(handles.bins,'String'));

rad_on=get(handles.uipanel_distribution,'selectedobject');
switch rad_on
    case handles.radio_hist
    
axes(handles.axes_distribution);    
hist(data1(:,1), bins);
set(gca,'box','off')
axis([xmin xmax hist_ymin hist_ymax])
set(get(gca,'child'),'FaceColor',[0.9,0.9,0.9],'EdgeColor','k');
ax1 = gca;
set(ax1,'XColor','k','YColor','k')
set(get(ax1,'Ylabel'),'String','frequency')    
set(get(ax1,'Xlabel'),'String','Age (Ma)')

    case handles.radio_pdp

axes(handles.axes_distribution);     
x=xmin:xint:xmax;
pdp=pdp5_2sig(data1(:,1),data1(:,2),xmin,xmax,xint);    
hl1 = plot(x,pdp,'Color','k');
ax1 = gca;
set(ax1,'XColor','k','YColor','k')
pdpmax = max(pdp);
axis([xmin xmax 0 pdpmax+0.1*pdpmax])
legend('Probability Density Plot');
set(hl1,'linewidth',1.5)
set(gca,'box','off')
ax1 = gca;
set(ax1,'XColor','k','YColor','k')
set(get(ax1,'Ylabel'),'String','probability')    
set(get(ax1,'Xlabel'),'String','Age (Ma)')

    case handles.radio_kde

axes(handles.axes_distribution);     
x=xmin:xint:xmax;
a=xmin;
b=xmax;
c=xint;
xA = a:c:b;
xA = transpose(xA);
tin=linspace(1,length(xA),length(xA));
A = data1(:,1);
n = length(A);
[bandwidth,kdeA,xmesh1,cdf]=kde(A,length(tin),a,b);
kdeA=transpose(interp1(xmesh1, kdeA, xA));

hl1 = plot(tin,kdeA,'Color','b');
ax1 = gca;
set(ax1,'XColor','k','YColor','k')
kdemax = max(kdeA);
axis([xmin xmax 0 kdemax+0.1*kdemax])
legend('Kernel Density Estimate');
set(hl1,'linewidth',1.5)
set(gca,'box','off')
ax1 = gca;
set(ax1,'XColor','k','YColor','k')
set(get(ax1,'Ylabel'),'String','probability')    
set(get(ax1,'Xlabel'),'String','Age (Ma)')   

    case handles.radio_hist_pdp

axes(handles.axes_distribution);        
x=xmin:xint:xmax;
pdp=pdp5_2sig(data1(:,1),data1(:,2),xmin,xmax,xint);

hist(data1(:,1), bins);
set(gca,'box','off')
axis([xmin xmax hist_ymin hist_ymax])
set(get(gca,'child'),'FaceColor',[0.9,0.9,0.9],'EdgeColor','k');
ax1 = gca;
set(ax1,'XColor','k','YColor','k')
set(get(ax1,'Ylabel'),'String','frequency')
xlabel('Age (Ma)')

ax2 = axes('Units', 'character'); %create a new axis and set units to be character
set(ax2, 'Position',get(ax1,'Position'),...
             'XAxisLocation','top',...
             'YAxisLocation','right',...
             'Color','none',...
             'XColor','k','YColor','k');

hold on

a=xmin;
b=xmax;
c=xint;
xA = a:c:b;
xA = transpose(xA);
tin=linspace(1,length(xA),length(xA));
A = data1(:,1);
n = length(A);
[bandwidth,kdeA,xmesh1,cdf]=kde(A,length(tin),a,b);
kdeA=transpose(interp1(xmesh1, kdeA, xA));

pdp=pdp5_2sig(data1(:,1),data1(:,2),xmin,xmax,xint);
x=xmin:xint:xmax;
hl1 = plot(x,pdp,'Color','k');
%hl2 = plot(xA,kdeA,'b');
ax1 = gca;
set(ax1,'XColor','k','YColor','k')

pdpmax = max(pdp);
kdemax = max(kdeA);
maxboth = [pdpmax,kdemax];
maxboth = max(maxboth);
axis([xmin xmax 0 maxboth+0.1*maxboth])

set(gca,'xtick',[])
set(get(ax2,'Ylabel'),'String','probability')

legend('Probability Density Plot');
set(hl1,'linewidth',1.5)
%set(hl2,'linewidth',2) 
%set(get(ax2,'Xlabel'),'String','Age (Ma)') 

    case handles.radio_hist_kde
        
axes(handles.axes_distribution);        
x=xmin:xint:xmax;
pdp=pdp5_2sig(data1(:,1),data1(:,2),xmin,xmax,xint);

hist(data1(:,1), bins);
set(gca,'box','off')
axis([xmin xmax hist_ymin hist_ymax])
set(get(gca,'child'),'FaceColor',[0.9,0.9,0.9],'EdgeColor','k');
ax1 = gca;
set(ax1,'XColor','k','YColor','k')
set(get(ax1,'Ylabel'),'String','frequency')
xlabel('Age (Ma)')

ax2 = axes('Units', 'character'); %create a new axis and set units to be character
set(ax2, 'Position',get(ax1,'Position'),...
             'XAxisLocation','top',...
             'YAxisLocation','right',...
             'Color','none',...
             'XColor','k','YColor','k');

hold on

a=xmin;
b=xmax;
c=xint;
xA = a:c:b;
xA = transpose(xA);
tin=linspace(1,length(xA),length(xA));
A = data1(:,1);
n = length(A);
[bandwidth,kdeA,xmesh1,cdf]=kde(A,length(tin),a,b);
kdeA=transpose(interp1(xmesh1, kdeA, xA));

pdp=pdp5_2sig(data1(:,1),data1(:,2),xmin,xmax,xint);
x=xmin:xint:xmax;
%hl1 = plot(x,pdp,'Color','k');
hl2 = plot(xA,kdeA,'b');
ax1 = gca;
set(ax1,'XColor','k','YColor','k')

pdpmax = max(pdp);
kdemax = max(kdeA);
maxboth = [pdpmax,kdemax];
maxboth = max(maxboth);
axis([xmin xmax 0 maxboth+0.1*maxboth])

set(gca,'xtick',[])
set(get(ax2,'Ylabel'),'String','probability')

legend('Kernel Density Estimate');
%set(hl1,'linewidth',1.5)
set(hl2,'linewidth',1.5) 
%set(get(ax2,'Xlabel'),'String','Age (Ma)')         
    
    case handles.radio_hist_pdp_kde

axes(handles.axes_distribution);        
x=xmin:xint:xmax;
pdp=pdp5_2sig(data1(:,1),data1(:,2),xmin,xmax,xint);

hist(data1(:,1), bins);
xlabel('Age (Ma)')
set(gca,'box','off')
axis([xmin xmax hist_ymin hist_ymax])
set(get(gca,'child'),'FaceColor',[0.9,0.9,0.9],'EdgeColor','k');
ax1 = gca;
set(ax1,'XColor','k','YColor','k')
set(get(ax1,'Ylabel'),'String','frequency')


ax2 = axes('Units', 'character'); %create a new axis and set units to be character
set(ax2, 'Position',get(ax1,'Position'),...
             'XAxisLocation','top',...
             'YAxisLocation','right',...
             'Color','none',...
             'XColor','k','YColor','k');

hold on

a=xmin;
b=xmax;
c=xint;
xA = a:c:b;
xA = transpose(xA);
tin=linspace(1,length(xA),length(xA));
A = data1(:,1);
n = length(A);
[bandwidth,kdeA,xmesh1,cdf]=kde(A,length(tin),a,b);
kdeA=transpose(interp1(xmesh1, kdeA, xA));

pdp=pdp5_2sig(data1(:,1),data1(:,2),xmin,xmax,xint);
x=xmin:xint:xmax;
hl1 = plot(x,pdp,'Color','k');
hl2 = plot(xA,kdeA,'b');
ax1 = gca;
set(ax1,'XColor','k','YColor','k')

pdpmax = max(pdp);
kdemax = max(kdeA);
maxboth = [pdpmax,kdemax];
maxboth = max(maxboth);
axis([xmin xmax 0 maxboth+0.1*maxboth])

set(gca,'xtick',[])
set(get(ax2,'Ylabel'),'String','probability')

legend('Probability Density Plot','Kernel Density Estimate');
set(hl1,'linewidth',1.5)
set(hl2,'linewidth',1.5)        
        
        
            
        
        
    otherwise
        set(handles.edit_radioselect,'string','');

end


nsamp = num2str(length(data1));
set(handles.n_plotted,'String',nsamp);

























% --- Executes on button press in pushbutton36.
function pushbutton36_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton36 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data1 = handles.data1;
final_sample_num = handles.final_sample_num;
samples = handles.samples;
discordant_samples_sort = handles.discordant_samples_sort;
analysis_num = handles.analysis_num;

for i = 1:length(samples)
if samples(i,1) > 0
	samples_ascribe1(i,1) = analysis_num(i,1);
else 
	samples_ascribe1(i,1) = {''};
end
end

samples_ascribe = samples_ascribe1(~cellfun(@isempty, samples_ascribe1));
name_reduced_samples = samples_ascribe(discordant_samples_sort(:,1),1);

dat = {'Analysis_name', 'bias_corr_samples_Pb207_Pb206', 'bias_corr_samples_Pb207_Pb206_err', ...
    'bias_corr_samples_Pb207_U235', 'bias_corr_samples_Pb207_U235_err', 'bias_corr_samples_Pb206_U238', 'bias_corr_samples_Pb206_U238_err' ...
    'rho', 'bias_corr_samples_Pb208_Th232', 'bias_corr_samples_Pb208_Th232_err', 'samples_Pb206_U238_age,', 'samples_Pb206_U238_age_err' ...
    'samples_Pb207_U235_age', 'samples_Pb207_U235_age_err', 'samples_Pb207_Pb206_age', 'samples_Pb207_Pb206_age_err', 'samples_Pb208_Th232_age', ...
    'samples_Pb208_Th232_age_err', 'discordance_Pb206U238_Pb207Pb206', 'discordance_Pb206U238_Pb207U235', 'best_age', 'best_age_err'};

dat(2:length(discordant_samples_sort(:,1))+1,:) = num2cell(discordant_samples_sort);
dat(2:length(discordant_samples_sort(:,1))+1,1) = name_reduced_samples;

[file,path] = uiputfile('*.xls','Save file');
xlswrite([path file], dat);









% --- Executes on button press in export_drift_plots.
function pushbutton39_Callback(hObject, eventdata, handles)
% hObject    handle to export_drift_plots (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

time2 = handles.time2;
pleis_time = handles.pleis_time;
frac_corr_pleis_Pb206_U238 = handles.frac_corr_pleis_Pb206_U238;
spline_Pb206_U238 = handles.spline_Pb206_U238;
frac_corr_pleis_Pb207_Pb206 = handles.frac_corr_pleis_Pb207_Pb206;
spline_Pb207_Pb206 = handles.spline_Pb207_Pb206;
frac_corr_pleis_Pb207_U235 = handles.frac_corr_pleis_Pb207_U235;
spline_Pb207_U235 = handles.spline_Pb207_U235;
frac_corr_pleis_Pb208_Th232 = handles.frac_corr_pleis_Pb208_Th232;
spline_Pb208_Th232 = handles.spline_Pb208_Th232;







f = figure; %create new figure
plot(pleis_time,frac_corr_pleis_Pb206_U238,'.', time2,[spline_Pb206_U238])
hold on 
scatter(time2,spline_Pb206_U238, '.', 'r');
xlabel('decimal time');
ylabel('Pb206/U238');
axis([min(time2) max(time2) min(frac_corr_pleis_Pb206_U238) max(frac_corr_pleis_Pb206_U238)]);

f1 = figure; %create new figure
plot(pleis_time,frac_corr_pleis_Pb207_Pb206,'.', time2,[spline_Pb207_Pb206])
hold on 
scatter(time2,spline_Pb207_Pb206, '.', 'r');
xlabel('decimal time');
ylabel('Pb207/Pb206');
axis([min(time2) max(time2) min(frac_corr_pleis_Pb207_Pb206) max(frac_corr_pleis_Pb207_Pb206)]);

f2 = figure; %create new figure
plot(pleis_time,frac_corr_pleis_Pb207_U235,'.', time2,[spline_Pb207_U235])
hold on 
scatter(time2,spline_Pb207_U235, '.', 'r');
xlabel('decimal time');
ylabel('Pb207/U235');
axis([min(time2) max(time2) min(frac_corr_pleis_Pb207_U235) max(frac_corr_pleis_Pb207_U235)]);

f3 = figure; %create new figure
plot(pleis_time,frac_corr_pleis_Pb208_Th232,'.', time2,[spline_Pb208_Th232])
hold on 
scatter(time2,spline_Pb208_Th232, '.', 'r');
xlabel('decimal time');
ylabel('Pb208/Th232');
axis([min(time2) max(time2) min(frac_corr_pleis_Pb208_Th232) max(frac_corr_pleis_Pb208_Th232)]);










% --- Executes on button press in pushbutton43.
function pushbutton43_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton43 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

f = figure; %create new figure
axes(handles.axes_distribution); 
cla reset
set(gca,'xtick',[],'ytick',[],'Xcolor','w','Ycolor','w')

data1 = handles.data1;
data2 = handles.data2;

xmin = str2num(get(handles.xmin,'String'));
xmax = str2num(get(handles.xmax,'String'));
xint = str2num(get(handles.xint,'String'));
hist_ymin = str2num(get(handles.ymin,'String'));
hist_ymax = str2num(get(handles.ymax,'String'));
bins = str2num(get(handles.bins,'String'));

rad_on=get(handles.uipanel_distribution,'selectedobject');
switch rad_on
    case handles.radio_hist
    
axes(handles.axes_distribution);    
hist(data1(:,1), bins);
set(gca,'box','off')
axis([xmin xmax hist_ymin hist_ymax])
set(get(gca,'child'),'FaceColor',[0.9,0.9,0.9],'EdgeColor','k');
ax1 = gca;
set(ax1,'XColor','k','YColor','k')
set(get(ax1,'Ylabel'),'String','frequency')    
set(get(ax1,'Xlabel'),'String','Age (Ma)')

    case handles.radio_pdp

axes(handles.axes_distribution);     
x=xmin:xint:xmax;
pdp=pdp5_2sig(data1(:,1),data1(:,2),xmin,xmax,xint);    
hl1 = plot(x,pdp,'Color','k');
ax1 = gca;
set(ax1,'XColor','k','YColor','k')
pdpmax = max(pdp);
axis([xmin xmax 0 pdpmax+0.1*pdpmax])
legend('Probability Density Plot');
set(hl1,'linewidth',1.5)
set(gca,'box','off')
ax1 = gca;
set(ax1,'XColor','k','YColor','k')
set(get(ax1,'Ylabel'),'String','probability')    
set(get(ax1,'Xlabel'),'String','Age (Ma)')

    case handles.radio_kde

axes(handles.axes_distribution);     
x=xmin:xint:xmax;
a=xmin;
b=xmax;
c=xint;
xA = a:c:b;
xA = transpose(xA);
tin=linspace(1,length(xA),length(xA));
A = data1(:,1);
n = length(A);
[bandwidth,kdeA,xmesh1,cdf]=kde(A,length(tin),a,b);
kdeA=transpose(interp1(xmesh1, kdeA, xA));

hl1 = plot(tin,kdeA,'Color','b');
ax1 = gca;
set(ax1,'XColor','k','YColor','k')
kdemax = max(kdeA);
axis([xmin xmax 0 kdemax+0.1*kdemax])
legend('Kernel Density Estimate');
set(hl1,'linewidth',1.5)
set(gca,'box','off')
ax1 = gca;
set(ax1,'XColor','k','YColor','k')
set(get(ax1,'Ylabel'),'String','probability')    
set(get(ax1,'Xlabel'),'String','Age (Ma)')   

    case handles.radio_hist_pdp

axes(handles.axes_distribution);        
x=xmin:xint:xmax;
pdp=pdp5_2sig(data1(:,1),data1(:,2),xmin,xmax,xint);

hist(data1(:,1), bins);
set(gca,'box','off')
axis([xmin xmax hist_ymin hist_ymax])
set(get(gca,'child'),'FaceColor',[0.9,0.9,0.9],'EdgeColor','k');
ax1 = gca;
set(ax1,'XColor','k','YColor','k')
set(get(ax1,'Ylabel'),'String','frequency')
xlabel('Age (Ma)')

ax2 = axes('Units', 'character'); %create a new axis and set units to be character
set(ax2, 'Position',get(ax1,'Position'),...
             'XAxisLocation','top',...
             'YAxisLocation','right',...
             'Color','none',...
             'XColor','k','YColor','k');

hold on

a=xmin;
b=xmax;
c=xint;
xA = a:c:b;
xA = transpose(xA);
tin=linspace(1,length(xA),length(xA));
A = data1(:,1);
n = length(A);
[bandwidth,kdeA,xmesh1,cdf]=kde(A,length(tin),a,b);
kdeA=transpose(interp1(xmesh1, kdeA, xA));

pdp=pdp5_2sig(data1(:,1),data1(:,2),xmin,xmax,xint);
x=xmin:xint:xmax;
hl1 = plot(x,pdp,'Color','k');
%hl2 = plot(xA,kdeA,'b');
ax1 = gca;
set(ax1,'XColor','k','YColor','k')

pdpmax = max(pdp);
kdemax = max(kdeA);
maxboth = [pdpmax,kdemax];
maxboth = max(maxboth);
axis([xmin xmax 0 maxboth+0.1*maxboth])

set(gca,'xtick',[])
set(get(ax2,'Ylabel'),'String','probability')

legend('Probability Density Plot');
set(hl1,'linewidth',1.5)
%set(hl2,'linewidth',2) 
%set(get(ax2,'Xlabel'),'String','Age (Ma)') 

    case handles.radio_hist_kde
        
axes(handles.axes_distribution);        
x=xmin:xint:xmax;
pdp=pdp5_2sig(data1(:,1),data1(:,2),xmin,xmax,xint);

hist(data1(:,1), bins);
set(gca,'box','off')
axis([xmin xmax hist_ymin hist_ymax])
set(get(gca,'child'),'FaceColor',[0.9,0.9,0.9],'EdgeColor','k');
ax1 = gca;
set(ax1,'XColor','k','YColor','k')
set(get(ax1,'Ylabel'),'String','frequency')
xlabel('Age (Ma)')

ax2 = axes('Units', 'character'); %create a new axis and set units to be character
set(ax2, 'Position',get(ax1,'Position'),...
             'XAxisLocation','top',...
             'YAxisLocation','right',...
             'Color','none',...
             'XColor','k','YColor','k');

hold on

a=xmin;
b=xmax;
c=xint;
xA = a:c:b;
xA = transpose(xA);
tin=linspace(1,length(xA),length(xA));
A = data1(:,1);
n = length(A);
[bandwidth,kdeA,xmesh1,cdf]=kde(A,length(tin),a,b);
kdeA=transpose(interp1(xmesh1, kdeA, xA));

pdp=pdp5_2sig(data1(:,1),data1(:,2),xmin,xmax,xint);
x=xmin:xint:xmax;
%hl1 = plot(x,pdp,'Color','k');
hl2 = plot(xA,kdeA,'b');
ax1 = gca;
set(ax1,'XColor','k','YColor','k')

pdpmax = max(pdp);
kdemax = max(kdeA);
maxboth = [pdpmax,kdemax];
maxboth = max(maxboth);
axis([xmin xmax 0 maxboth+0.1*maxboth])

set(gca,'xtick',[])
set(get(ax2,'Ylabel'),'String','probability')

legend('Probability Density Plot');
%set(hl1,'linewidth',1.5)
set(hl2,'linewidth',1.5) 
%set(get(ax2,'Xlabel'),'String','Age (Ma)')         

    
    case handles.radio_hist_pdp_kde

axes(handles.axes_distribution);        
x=xmin:xint:xmax;
pdp=pdp5_2sig(data1(:,1),data1(:,2),xmin,xmax,xint);

hist(data1(:,1), bins);
set(gca,'box','off')
axis([xmin xmax hist_ymin hist_ymax])
set(get(gca,'child'),'FaceColor',[0.9,0.9,0.9],'EdgeColor','k');
ax1 = gca;
set(ax1,'XColor','k','YColor','k')
set(get(ax1,'Ylabel'),'String','frequency')


ax2 = axes('Units', 'character'); %create a new axis and set units to be character
set(ax2, 'Position',get(ax1,'Position'),...
             'XAxisLocation','top',...
             'YAxisLocation','right',...
             'Color','none',...
             'XColor','k','YColor','k');

hold on

a=xmin;
b=xmax;
c=xint;
xA = a:c:b;
xA = transpose(xA);
tin=linspace(1,length(xA),length(xA));
A = data1(:,1);
n = length(A);
[bandwidth,kdeA,xmesh1,cdf]=kde(A,length(tin),a,b);
kdeA=transpose(interp1(xmesh1, kdeA, xA));

pdp=pdp5_2sig(data1(:,1),data1(:,2),xmin,xmax,xint);
x=xmin:xint:xmax;
hl1 = plot(x,pdp,'Color','k');
hl2 = plot(xA,kdeA,'b');
ax1 = gca;
set(ax1,'XColor','k','YColor','k')

pdpmax = max(pdp);
kdemax = max(kdeA);
maxboth = [pdpmax,kdemax];
maxboth = max(maxboth);
axis([xmin xmax 0 maxboth+0.1*maxboth])

set(gca,'xtick',[])
set(get(ax2,'Ylabel'),'String','probability')

legend('Probability Density Plot','Kernel Density Estimate');
set(hl1,'linewidth',1.5)
set(hl2,'linewidth',1.5)        
        
        
         case handles.radio_pdp
        Two_Sample_Compare_PDP;
    
    case handles.radio_hist_pdp_kde
        Two_Sample_Compare_KDE;
        
        
        
    otherwise
        set(handles.edit_radioselect,'string','');
end


nsamp = num2str(length(data1));
set(handles.n_plotted,'String',nsamp);


% --- Executes on button press in pushbutton46.
function pushbutton46_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton46 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in plot_all.
function plot_all_Callback(hObject, eventdata, handles)
% hObject    handle to plot_all (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


axes(handles.axes_distribution); 
cla reset

set(gca,'xtick',[],'ytick',[],'Xcolor','w','Ycolor','w')

data1 = handles.data1;
data2 = handles.data2;

data3 = vertcat(data1,data2);

xmin = str2num(get(handles.xmin,'String'));
xmax = str2num(get(handles.xmax,'String'));
xint = str2num(get(handles.xint,'String'));
hist_ymin = str2num(get(handles.ymin,'String'));
hist_ymax = str2num(get(handles.ymax,'String'));
bins = str2num(get(handles.bins,'String'));
 
rad_on=get(handles.uipanel_distribution,'selectedobject');
switch rad_on
    case handles.radio_hist
    
axes(handles.axes_distribution);    
hist(data3(:,1), bins);
set(gca,'box','off')
axis([xmin xmax hist_ymin hist_ymax])
set(get(gca,'child'),'FaceColor',[0.9,0.9,0.9],'EdgeColor','k');
ax1 = gca;
set(ax1,'XColor','k','YColor','k')
set(get(ax1,'Ylabel'),'String','frequency')    
set(get(ax1,'Xlabel'),'String','Age (Ma)')
 
    case handles.radio_pdp
 
axes(handles.axes_distribution);     
x=xmin:xint:xmax;
pdp=pdp5_2sig(data3(:,1),data3(:,2),xmin,xmax,xint);    
hl1 = plot(x,pdp,'Color','k');
ax1 = gca;
set(ax1,'XColor','k','YColor','k')
pdpmax = max(pdp);
axis([xmin xmax 0 pdpmax+0.1*pdpmax])
legend('Probability Density Plot');
set(hl1,'linewidth',1.5)
set(gca,'box','off')
ax1 = gca;
set(ax1,'XColor','k','YColor','k')
set(get(ax1,'Ylabel'),'String','probability')    
set(get(ax1,'Xlabel'),'String','Age (Ma)')
 
    case handles.radio_kde
 
axes(handles.axes_distribution);     
x=xmin:xint:xmax;
a=xmin;
b=xmax;
c=xint;
xA = a:c:b;
xA = transpose(xA);
tin=linspace(1,length(xA),length(xA));
A = data3(:,1);
n = length(A);
[bandwidth,kdeA,xmesh1,cdf]=kde(A,length(tin),a,b);
kdeA=transpose(interp1(xmesh1, kdeA, xA));
 
hl1 = plot(tin,kdeA,'Color','b');
ax1 = gca;
set(ax1,'XColor','k','YColor','k')
kdemax = max(kdeA);
axis([xmin xmax 0 kdemax+0.1*kdemax])
legend('Kernel Density Estimate');
set(hl1,'linewidth',1.5)
set(gca,'box','off')
ax1 = gca;
set(ax1,'XColor','k','YColor','k')
set(get(ax1,'Ylabel'),'String','probability')    
set(get(ax1,'Xlabel'),'String','Age (Ma)')   
 
    case handles.radio_hist_pdp
 
axes(handles.axes_distribution);        
x=xmin:xint:xmax;
pdp=pdp5_2sig(data3(:,1),data3(:,2),xmin,xmax,xint);
 
hist(data3(:,1), bins);
set(gca,'box','off')
axis([xmin xmax hist_ymin hist_ymax])
set(get(gca,'child'),'FaceColor',[0.9,0.9,0.9],'EdgeColor','k');
ax1 = gca;
set(ax1,'XColor','k','YColor','k')
set(get(ax1,'Ylabel'),'String','frequency')
xlabel('Age (Ma)')
 
ax2 = axes('Units', 'character'); %create a new axis and set units to be character
set(ax2, 'Position',get(ax1,'Position'),...
             'XAxisLocation','top',...
             'YAxisLocation','right',...
             'Color','none',...
             'XColor','k','YColor','k');
 
hold on
 
a=xmin;
b=xmax;
c=xint;
xA = a:c:b;
xA = transpose(xA);
tin=linspace(1,length(xA),length(xA));
A = data3(:,1);
n = length(A);
[bandwidth,kdeA,xmesh1,cdf]=kde(A,length(tin),a,b);
kdeA=transpose(interp1(xmesh1, kdeA, xA));
 
pdp=pdp5_2sig(data3(:,1),data3(:,2),xmin,xmax,xint);
x=xmin:xint:xmax;
hl1 = plot(x,pdp,'Color','k');
%hl2 = plot(xA,kdeA,'b');
ax1 = gca;
set(ax1,'XColor','k','YColor','k')
 
pdpmax = max(pdp);
kdemax = max(kdeA);
maxboth = [pdpmax,kdemax];
maxboth = max(maxboth);
axis([xmin xmax 0 maxboth+0.1*maxboth])
 
set(gca,'xtick',[])
set(get(ax2,'Ylabel'),'String','probability')
 
legend('Probability Density Plot');
set(hl1,'linewidth',1.5)
%set(hl2,'linewidth',2) 
%set(get(ax2,'Xlabel'),'String','Age (Ma)') 
 
    case handles.radio_hist_kde
        
axes(handles.axes_distribution);        
x=xmin:xint:xmax;
pdp=pdp5_2sig(data3(:,1),data3(:,2),xmin,xmax,xint);
 
hist(data3(:,1), bins);
set(gca,'box','off')
axis([xmin xmax hist_ymin hist_ymax])
set(get(gca,'child'),'FaceColor',[0.9,0.9,0.9],'EdgeColor','k');
ax1 = gca;
set(ax1,'XColor','k','YColor','k')
set(get(ax1,'Ylabel'),'String','frequency')
xlabel('Age (Ma)')
 
ax2 = axes('Units', 'character'); %create a new axis and set units to be character
set(ax2, 'Position',get(ax1,'Position'),...
             'XAxisLocation','top',...
             'YAxisLocation','right',...
             'Color','none',...
             'XColor','k','YColor','k');
 
hold on
 
a=xmin;
b=xmax;
c=xint;
xA = a:c:b;
xA = transpose(xA);
tin=linspace(1,length(xA),length(xA));
A = data3(:,1);
n = length(A);
[bandwidth,kdeA,xmesh1,cdf]=kde(A,length(tin),a,b);
kdeA=transpose(interp1(xmesh1, kdeA, xA));
 
pdp=pdp5_2sig(data3(:,1),data3(:,2),xmin,xmax,xint);
x=xmin:xint:xmax;
%hl1 = plot(x,pdp,'Color','k');
hl2 = plot(xA,kdeA,'b');
ax1 = gca;
set(ax1,'XColor','k','YColor','k')
 
pdpmax = max(pdp);
kdemax = max(kdeA);
maxboth = [pdpmax,kdemax];
maxboth = max(maxboth);
axis([xmin xmax 0 maxboth+0.1*maxboth])
 
set(gca,'xtick',[])
set(get(ax2,'Ylabel'),'String','probability')
 
legend('Kernel Density Estimate');
%set(hl1,'linewidth',1.5)
set(hl2,'linewidth',1.5) 
%set(get(ax2,'Xlabel'),'String','Age (Ma)')         
    
    case handles.radio_hist_pdp_kde
 
axes(handles.axes_distribution);        
x=xmin:xint:xmax;
pdp=pdp5_2sig(data3(:,1),data3(:,2),xmin,xmax,xint);
 
hist(data3(:,1), bins);
set(gca,'box','off')
axis([xmin xmax hist_ymin hist_ymax])
set(get(gca,'child'),'FaceColor',[0.9,0.9,0.9],'EdgeColor','k');
ax1 = gca;
set(ax1,'XColor','k','YColor','k')
set(get(ax1,'Ylabel'),'String','frequency')
 
 
ax2 = axes('Units', 'character'); %create a new axis and set units to be character
set(ax2, 'Position',get(ax1,'Position'),...
             'XAxisLocation','top',...
             'YAxisLocation','right',...
             'Color','none',...
             'XColor','k','YColor','k');
 
hold on
 
a=xmin;
b=xmax;
c=xint;
xA = a:c:b;
xA = transpose(xA);
tin=linspace(1,length(xA),length(xA));
A = data3(:,1);
n = length(A);
[bandwidth,kdeA,xmesh1,cdf]=kde(A,length(tin),a,b);
kdeA=transpose(interp1(xmesh1, kdeA, xA));
 
pdp=pdp5_2sig(data3(:,1),data3(:,2),xmin,xmax,xint);
x=xmin:xint:xmax;
hl1 = plot(x,pdp,'Color','k');
hl2 = plot(xA,kdeA,'b');
ax1 = gca;
set(ax1,'XColor','k','YColor','k')
 
pdpmax = max(pdp);
kdemax = max(kdeA);
maxboth = [pdpmax,kdemax];
maxboth = max(maxboth);
axis([xmin xmax 0 maxboth+0.1*maxboth])
 
set(gca,'xtick',[])
set(get(ax2,'Ylabel'),'String','probability')
 
legend('Probability Density Plot','Kernel Density Estimate');
set(hl1,'linewidth',1.5)
set(hl2,'linewidth',1.5)        
        
        
            
        
        
    otherwise
        set(handles.edit_radioselect,'string','');
 
end
 
 
nsamp = num2str(length(data3));
set(handles.n_plotted,'String',nsamp);

























% --- Executes on button press in pushbutton44.
function pushbutton44_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton44 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

















function edit62_Callback(hObject, eventdata, handles)
% hObject    handle to edit62 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit62 as text
%        str2double(get(hObject,'String')) returns contents of edit62 as a double


% --- Executes during object creation, after setting all properties.
function edit62_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit62 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit63_Callback(hObject, eventdata, handles)
% hObject    handle to edit63 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit63 as text
%        str2double(get(hObject,'String')) returns contents of edit63 as a double


% --- Executes during object creation, after setting all properties.
function edit63_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit63 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit64_Callback(hObject, eventdata, handles)
% hObject    handle to edit64 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit64 as text
%        str2double(get(hObject,'String')) returns contents of edit64 as a double


% --- Executes during object creation, after setting all properties.
function edit64_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit64 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end






function edit65_Callback(hObject, eventdata, handles)
% hObject    handle to edit65 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit65 as text
%        str2double(get(hObject,'String')) returns contents of edit65 as a double


% --- Executes during object creation, after setting all properties.
function edit65_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit65 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton50.
function pushbutton50_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton50 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cla(handles.axes_current_intensities,'reset');
cla(handles.axes_current_concordia,'reset');





function edit66_Callback(hObject, eventdata, handles)
% hObject    handle to edit66 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit66 as text
%        str2double(get(hObject,'String')) returns contents of edit66 as a double


% --- Executes during object creation, after setting all properties.
function edit66_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit66 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit67_Callback(hObject, eventdata, handles)
% hObject    handle to edit67 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit67 as text
%        str2double(get(hObject,'String')) returns contents of edit67 as a double


% --- Executes during object creation, after setting all properties.
function edit67_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit67 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function outlier_cutoff_68_Callback(hObject, eventdata, handles)
% hObject    handle to outlier_cutoff_68 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of outlier_cutoff_68 as text
%        str2double(get(hObject,'String')) returns contents of outlier_cutoff_68 as a double


% --- Executes during object creation, after setting all properties.
function outlier_cutoff_68_CreateFcn(hObject, eventdata, handles)
% hObject    handle to outlier_cutoff_68 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in export_drift_plots.
function export_drift_plots_Callback(hObject, eventdata, handles)
% hObject    handle to export_drift_plots (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


time = handles.time2;        
pleis_time = handles.pleis_time;

frac_corr_pleis_Pb206_U238 = handles.frac_corr_pleis_Pb206_U238;
frac_corr_pleis_Pb207_Pb206 = handles.frac_corr_pleis_Pb207_Pb206;
frac_corr_pleis_Pb207_U235 = handles.frac_corr_pleis_Pb207_U235;
frac_corr_pleis_Pb208_Th232 = handles.frac_corr_pleis_Pb208_Th232;

spline_Pb206_U238 = handles.spline_Pb206_U238;
spline_Pb207_Pb206 = handles.spline_Pb207_Pb206;
spline_Pb207_U235 = handles.spline_Pb207_U235;
spline_Pb208_Th232 = handles.spline_Pb208_Th232;

min_all_68 = handles.min_all_68;
max_all_68 = handles.max_all_68;
min_all_76 = handles.min_all_76;
max_all_76 = handles.max_all_76;
min_all_75 = handles.min_all_75;
max_all_75 = handles.max_all_75;
min_all_82 = handles.min_all_82;
max_all_82 = handles.max_all_82;


rad_on=get(handles.uipanel_fit_type,'selectedobject');
switch rad_on
    
    case handles.radio_polynomial
            
spline_x_hi_68 = handles.spline_x_hi_68;
spline_x_lo_68 = handles.spline_x_lo_68;
spline_x_hi_76 = handles.spline_x_hi_76;
spline_x_lo_76 = handles.spline_x_lo_76;
spline_x_hi_75 = handles.spline_x_hi_75;
spline_x_lo_75 = handles.spline_x_lo_75;
spline_x_hi_82 = handles.spline_x_hi_82;
spline_x_lo_82 = handles.spline_x_lo_82;        

frac_corr_pleis_rej_68 = handles.frac_corr_pleis_rej_68;

time_rej = handles.time_rej;
f=figure;
plot(pleis_time,frac_corr_pleis_Pb206_U238,'.', time,[spline_Pb206_U238], 'r','LineWidth',2)
hold on 
%scatter(time,spline_Pb206_U238, '.', 'r');
xlabel('decimal time');
ylabel('Pb206/U238');
hold on
plot(time,spline_x_hi_68)
plot(time,spline_x_lo_68)
scatter(time_rej, frac_corr_pleis_rej_68, 'r')
%scatter(pleis_time, x_hi_68)
%scatter(pleis_time, x_lo_68)
%scatter(pleis_time, spline_hi_decimate_68)
%scatter(pleis_time, spline_lo_decimate_68)
hold off
max_all_68 = max(vertcat(spline_x_hi_68,frac_corr_pleis_Pb206_U238, spline_Pb206_U238));
min_all_68 = min(vertcat(spline_x_lo_68,frac_corr_pleis_Pb206_U238, spline_Pb206_U238));
axis([min(time) max(time) min(min_all_68) max(max_all_68)]);
legend('standard measurements','spline fit','rejected standards','acceptance window')

frac_corr_pleis_rej_76 = handles.frac_corr_pleis_rej_76;
time_rej = handles.time_rej;        
f=figure;
plot(pleis_time,frac_corr_pleis_Pb207_Pb206,'.', time,[spline_Pb207_Pb206], 'r','LineWidth',2)
hold on 
%scatter(time,spline_Pb207_Pb206, '.', 'r');
xlabel('decimal time');
ylabel('Pb207/Pb206');
hold on
plot(time,spline_x_hi_76)
plot(time,spline_x_lo_76)
scatter(time_rej, frac_corr_pleis_rej_76, 'r')
%scatter(pleis_time, x_hi_76)
%scatter(pleis_time, x_lo_76)
hold off
max_all_76 = max(vertcat(spline_x_hi_76,frac_corr_pleis_Pb207_Pb206, spline_Pb207_Pb206));
min_all_76 = min(vertcat(spline_x_lo_76,frac_corr_pleis_Pb207_Pb206, spline_Pb207_Pb206));
axis([min(time) max(time) min(min_all_76) max(max_all_76)]);


frac_corr_pleis_rej_75 = handles.frac_corr_pleis_rej_75; 
time_rej = handles.time_rej;
f=figure;
plot(pleis_time,frac_corr_pleis_Pb207_U235,'.', time,[spline_Pb207_U235], 'r','LineWidth',2)
hold on 
%scatter(time,spline_Pb207_U235, '.', 'r');
xlabel('decimal time');
ylabel('Pb207/U235');
plot(time,spline_x_hi_75)
plot(time,spline_x_lo_75)
scatter(time_rej, frac_corr_pleis_rej_75, 'r')
hold off
max_all_75 = max(vertcat(spline_x_hi_75,frac_corr_pleis_Pb207_U235, spline_Pb207_U235));
min_all_75 = min(vertcat(spline_x_lo_75,frac_corr_pleis_Pb207_U235, spline_Pb207_U235));
axis([min(time) max(time) min(min_all_75) max(max_all_75)]);

frac_corr_pleis_rej_82 = handles.frac_corr_pleis_rej_82;        
time_rej = handles.time_rej; 
f=figure;
plot(pleis_time,frac_corr_pleis_Pb208_Th232,'.', time,[spline_Pb208_Th232], 'r','LineWidth',2)
hold on 
%scatter(time,spline_Pb208_Th232, '.', 'r');
xlabel('decimal time');
ylabel('Pb208/Th232');
plot(time,spline_x_hi_82)
plot(time,spline_x_lo_82)
scatter(time_rej, frac_corr_pleis_rej_82, 'r')
hold off
max_all_82 = max(vertcat(spline_x_hi_82,frac_corr_pleis_Pb208_Th232, spline_Pb208_Th232));
min_all_82 = min(vertcat(spline_x_lo_82,frac_corr_pleis_Pb208_Th232, spline_Pb208_Th232));
axis([min(time) max(time) min(min_all_82) max(max_all_82)]);

     
    
        case handles.radio_cubicspline
            

figure;
plot(pleis_time,frac_corr_pleis_Pb206_U238,'.', time,[spline_Pb206_U238], 'r','LineWidth',2)
hold on 
%scatter(time,poly_Pb206_U238, '.', 'r');
xlabel('decimal time');
ylabel('Pb206/U238');
hold on
%plot(time,spline_x_hi_68)
%plot(time,spline_x_lo_68)
hold off
max_all_68 = max(vertcat(frac_corr_pleis_Pb206_U238, spline_Pb206_U238));
min_all_68 = min(vertcat(frac_corr_pleis_Pb206_U238, spline_Pb206_U238));
axis([min(time) max(time) min(min_all_68) max(max_all_68)]);
legend('standard measurements','polynomial fit')

figure;
plot(pleis_time,frac_corr_pleis_Pb207_Pb206,'.', time,[spline_Pb207_Pb206], 'r','LineWidth',2)
hold on 
scatter(time,spline_Pb207_Pb206, '.', 'r');
xlabel('decimal time');
ylabel('Pb207/Pb206');
hold on
%plot(time,spline_x_hi_76)
%plot(time,spline_x_lo_76)
hold off
max_all_76 = max(vertcat(frac_corr_pleis_Pb207_Pb206, spline_Pb207_Pb206));
min_all_76 = min(vertcat(frac_corr_pleis_Pb207_Pb206, spline_Pb207_Pb206));
axis([min(time) max(time) min(min_all_76) max(max_all_76)]);
legend('standard measurements','polynomial fit')

figure;
plot(pleis_time,frac_corr_pleis_Pb207_U235,'.', time,[spline_Pb207_U235], 'r','LineWidth',2)
hold on 
scatter(time,spline_Pb207_U235, '.', 'r');
xlabel('decimal time');
ylabel('Pb207/U235');
%plot(time,spline_x_hi_75)
%plot(time,spline_x_lo_75)
hold off
max_all_75 = max(vertcat(frac_corr_pleis_Pb207_U235, spline_Pb207_U235));
min_all_75 = min(vertcat(frac_corr_pleis_Pb207_U235, spline_Pb207_U235));
axis([min(time) max(time) min(min_all_75) max(max_all_75)]);
legend('standard measurements','polynomial fit')

figure;
plot(pleis_time,frac_corr_pleis_Pb208_Th232,'.', time,[spline_Pb208_Th232], 'r','LineWidth',2)
hold on 
scatter(time,spline_Pb208_Th232, '.', 'r');
xlabel('decimal time');
ylabel('Pb208/Th232');
%plot(time,spline_x_hi_82)
%plot(time,spline_x_lo_82)
hold off
max_all_82 = max(vertcat(frac_corr_pleis_Pb208_Th232, spline_Pb208_Th232));
min_all_82 = min(vertcat(frac_corr_pleis_Pb208_Th232, spline_Pb208_Th232));
axis([min(time) max(time) min(min_all_82) max(max_all_82)]);     
legend('standard measurements','polynomial fit')

    case handles.radio_smoothingspline
        
spline_x_hi_68 = handles.spline_x_hi_68;
spline_x_lo_68 = handles.spline_x_lo_68;
spline_x_hi_76 = handles.spline_x_hi_76;
spline_x_lo_76 = handles.spline_x_lo_76;
spline_x_hi_75 = handles.spline_x_hi_75;
spline_x_lo_75 = handles.spline_x_lo_75;
spline_x_hi_82 = handles.spline_x_hi_82;
spline_x_lo_82 = handles.spline_x_lo_82;
        
frac_corr_pleis_rej_68 = handles.frac_corr_pleis_rej_68;

time_rej = handles.time_rej;
f=figure;
plot(pleis_time,frac_corr_pleis_Pb206_U238,'.', time,[spline_Pb206_U238], 'r','LineWidth',2)
hold on 
%scatter(time,spline_Pb206_U238,15, '.', 'r');
xlabel('decimal time');
ylabel('Pb206/U238');
hold on
scatter(time_rej, frac_corr_pleis_rej_68, 'r')
plot(time,spline_x_hi_68)
plot(time,spline_x_lo_68)
hold off
axis([min(time) max(time) min(min_all_68) max(max_all_68)]);
legend('standard measurements','spline fit','spline fit points','rejected standards','acceptance window')

frac_corr_pleis_rej_76 = handles.frac_corr_pleis_rej_76;
time_rej = handles.time_rej;        
f=figure;
plot(pleis_time,frac_corr_pleis_Pb207_Pb206,'.', time,[spline_Pb207_Pb206], 'r','LineWidth',2)
hold on 
%scatter(time,spline_Pb207_Pb206,15, '.', 'r');
xlabel('decimal time');
ylabel('Pb206/U238');
hold on
scatter(time_rej, frac_corr_pleis_rej_76, 'r')
plot(time,spline_x_hi_76)
plot(time,spline_x_lo_76)
hold off
axis([min(time) max(time) min(min_all_76) max(max_all_76)]);
legend('standard measurements','spline fit','spline fit points','rejected standards','acceptance window')

frac_corr_pleis_rej_75 = handles.frac_corr_pleis_rej_75; 
time_rej = handles.time_rej;
f=figure;
plot(pleis_time,frac_corr_pleis_Pb207_U235,'.', time,[spline_Pb207_U235], 'r','LineWidth',2)
hold on 
%scatter(time,spline_Pb207_U235,15, '.', 'r');
xlabel('decimal time');
ylabel('Pb206/U238');
hold on
scatter(time_rej, frac_corr_pleis_rej_75, 'r')
plot(time,spline_x_hi_75)
plot(time,spline_x_lo_75)
hold off
axis([min(time) max(time) min(min_all_75) max(max_all_75)]);
legend('standard measurements','spline fit','spline fit points','rejected standards','acceptance window')

frac_corr_pleis_rej_82 = handles.frac_corr_pleis_rej_82;        
time_rej = handles.time_rej; 
f=figure;
plot(pleis_time,frac_corr_pleis_Pb208_Th232,'.', time,[spline_Pb208_Th232], 'r','LineWidth',2)
hold on 
%scatter(time,spline_Pb208_Th232,15, '.', 'r');
xlabel('decimal time');
ylabel('Pb206/U238');
hold on
scatter(time_rej, frac_corr_pleis_rej_82, 'r')
plot(time,spline_x_hi_82)
plot(time,spline_x_lo_82)
hold off
axis([min(time) max(time) min(min_all_82) max(max_all_82)]);
legend('standard measurements','spline fit','spline fit points','rejected standards','acceptance window')

    case handles.radiobutton26

f=figure;
plot(pleis_time,frac_corr_pleis_Pb206_U238,'.', time,[spline_Pb206_U238], 'r','LineWidth',2)
hold on 
%scatter(time,spline_Pb206_U238, '.', 'r');
xlabel('decimal time');
ylabel('Pb206/U238');
hold on
%plot(time,spline_x_hi_68)
%plot(time,spline_x_lo_68)
hold off
max_all_68 = max(vertcat(frac_corr_pleis_Pb206_U238, spline_Pb206_U238));
min_all_68 = min(vertcat(frac_corr_pleis_Pb206_U238, spline_Pb206_U238));
axis([min(time) max(time) min(min_all_68) max(max_all_68)]);
legend('standard measurements','spline fit')

f=figure;
plot(pleis_time,frac_corr_pleis_Pb207_Pb206,'.', time,[spline_Pb207_Pb206], 'r','LineWidth',2)
hold on 
%scatter(time,spline_Pb207_Pb206, '.', 'r');
xlabel('decimal time');
ylabel('Pb206/U238');
hold on
%plot(time,spline_x_hi_76)
%plot(time,spline_x_lo_76)
hold off
max_all_76 = max(vertcat(frac_corr_pleis_Pb207_Pb206, spline_Pb207_Pb206));
min_all_76 = min(vertcat(frac_corr_pleis_Pb207_Pb206, spline_Pb207_Pb206));
axis([min(time) max(time) min(min_all_76) max(max_all_76)]);
legend('standard measurements','spline fit')

f=figure;
plot(pleis_time,frac_corr_pleis_Pb207_U235,'.', time,[spline_Pb207_U235], 'r','LineWidth',2)
hold on 
%scatter(time,spline_Pb207_U235, '.', 'r');
xlabel('decimal time');
ylabel('Pb206/U238');
hold on
%plot(time,spline_x_hi_75)
%plot(time,spline_x_lo_75)
hold off
max_all_75 = max(vertcat(frac_corr_pleis_Pb207_U235, spline_Pb207_U235));
min_all_75 = min(vertcat(frac_corr_pleis_Pb207_U235, spline_Pb207_U235));
axis([min(time) max(time) min(min_all_75) max(max_all_75)]);
legend('standard measurements','spline fit')

f=figure;
plot(pleis_time,frac_corr_pleis_Pb208_Th232,'.', time,[spline_Pb208_Th232], 'r','LineWidth',2)
hold on 
%scatter(time,spline_Pb208_Th232, '.', 'r');
xlabel('decimal time');
ylabel('Pb206/U238');
hold on
%plot(time,spline_x_hi_82)
%plot(time,spline_x_lo_82)
hold off
max_all_82 = max(vertcat(frac_corr_pleis_Pb208_Th232, spline_Pb208_Th232));
min_all_82 = min(vertcat(frac_corr_pleis_Pb208_Th232, spline_Pb208_Th232));
axis([min(time) max(time) min(min_all_82) max(max_all_82)]);
legend('standard measurements','spline fit')

    otherwise
        set(handles.edit_radioselect,'string','');

end





function edit69_Callback(hObject, eventdata, handles)
% hObject    handle to edit69 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit69 as text
%        str2double(get(hObject,'String')) returns contents of edit69 as a double


% --- Executes during object creation, after setting all properties.
function edit69_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit69 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit70_Callback(hObject, eventdata, handles)
% hObject    handle to edit70 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit70 as text
%        str2double(get(hObject,'String')) returns contents of edit70 as a double


% --- Executes during object creation, after setting all properties.
function edit70_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit70 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit71_Callback(hObject, eventdata, handles)
% hObject    handle to edit71 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit71 as text
%        str2double(get(hObject,'String')) returns contents of edit71 as a double


% --- Executes during object creation, after setting all properties.
function edit71_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit71 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit72_Callback(hObject, eventdata, handles)
% hObject    handle to edit72 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit72 as text
%        str2double(get(hObject,'String')) returns contents of edit72 as a double


% --- Executes during object creation, after setting all properties.
function edit72_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit72 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit73_Callback(hObject, eventdata, handles)
% hObject    handle to edit73 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit73 as text
%        str2double(get(hObject,'String')) returns contents of edit73 as a double


% --- Executes during object creation, after setting all properties.
function edit73_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit73 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function outlier_cutoff_76_Callback(hObject, eventdata, handles)
% hObject    handle to outlier_cutoff_76 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of outlier_cutoff_76 as text
%        str2double(get(hObject,'String')) returns contents of outlier_cutoff_76 as a double


% --- Executes during object creation, after setting all properties.
function outlier_cutoff_76_CreateFcn(hObject, eventdata, handles)
% hObject    handle to outlier_cutoff_76 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit75_Callback(hObject, eventdata, handles)
% hObject    handle to edit75 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit75 as text
%        str2double(get(hObject,'String')) returns contents of edit75 as a double


% --- Executes during object creation, after setting all properties.
function edit75_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit75 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit76_Callback(hObject, eventdata, handles)
% hObject    handle to edit76 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit76 as text
%        str2double(get(hObject,'String')) returns contents of edit76 as a double


% --- Executes during object creation, after setting all properties.
function edit76_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit76 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function poly_order_Callback(hObject, eventdata, handles)
% hObject    handle to poly_order (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of poly_order as text
%        str2double(get(hObject,'String')) returns contents of poly_order as a double


% --- Executes during object creation, after setting all properties.
function poly_order_CreateFcn(hObject, eventdata, handles)
% hObject    handle to poly_order (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton56.
function pushbutton56_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton56 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

xmin = str2num(get(handles.edit21,'String'));
xmax = str2num(get(handles.edit20,'String'));
ymin = str2num(get(handles.edit23,'String'));
ymax = str2num(get(handles.edit22,'String'));
agelabelmin = str2num(get(handles.edit63,'String'));
agelabelmax = str2num(get(handles.edit62,'String'));
agelabelint = str2num(get(handles.edit64,'String'));

concordant_samples_sort = handles.concordant_samples_sort;
discordant_samples_sort = handles.discordant_samples_sort;

concordant_data = [concordant_samples_sort(:,2),concordant_samples_sort(:,3), ...
	concordant_samples_sort(:,4),concordant_samples_sort(:,5),...
	concordant_samples_sort(:,6),concordant_samples_sort(:,7)];

concordant_data_rho = concordant_samples_sort(:,8);

concordant_data_center=[concordant_data(:,3),concordant_data(:,5)];

concordant_data_sigx_abs = concordant_data(:,3).*concordant_data(:,4).*0.01;
concordant_data_sigy_abs = concordant_data(:,5).*concordant_data(:,6).*0.01;

concordant_data_sigx_sq = concordant_data_sigx_abs.*concordant_data_sigx_abs;
concordant_data_sigy_sq = concordant_data_sigy_abs.*concordant_data_sigy_abs;
concordant_data_rho_sigx_sigy = concordant_data_sigx_abs.*concordant_data_sigy_abs.*concordant_data_rho;
sigmarule=1.25;
numpoints=50;

figure;

for i = 1:length(concordant_data_rho);

concordant_data_covmat=[concordant_data_sigx_sq(i,1),concordant_data_rho_sigx_sigy(i,1);concordant_data_rho_sigx_sigy(i,1), ...
	concordant_data_sigy_sq(i,1)];
[concordant_data_PD,concordant_data_PV]=eig(concordant_data_covmat);
concordant_data_PV=diag(concordant_data_PV).^.5;
concordant_data_theta=linspace(0,2.*pi,numpoints)';
concordant_data_elpt=[cos(concordant_data_theta),sin(concordant_data_theta)]*diag(concordant_data_PV)*concordant_data_PD';
numsigma=length(sigmarule);
concordant_data_elpt=repmat(concordant_data_elpt,1,numsigma).*repmat(sigmarule(floor(1:.5:numsigma+.5)),numpoints,1);
concordant_data_elpt=concordant_data_elpt+repmat(concordant_data_center(i,1:2),numpoints,numsigma);
plot(concordant_data_elpt(:,1:2:end),concordant_data_elpt(:,2:2:end),'b','LineWidth',1.2);
hold on
end

timemin = 0;
timemax = 4500000000;
timeinterval = 50000000;
time = timemin:timeinterval:timemax;

x = exp(0.00000000098485.*time)-1;
y = exp(0.000000000155125.*time)-1;

age_label_num = [agelabelmin+agelabelint:agelabelint:agelabelmax];
for i=1:length(age_label_num)
age_label(i,1) = {sprintf('%.1f',age_label_num(1,i))};
age_label2(i,1) = strcat(age_label(i,1),' Ga');
end
age_label_num = age_label_num.*1000000000;
age_label_x = exp(0.00000000098485.*age_label_num)-1;
age_label_y = exp(0.000000000155125.*age_label_num)-1;

plot(x,y,'k','LineWidth',1.4)
hold on
scatter(age_label_x, age_label_y,20,'MarkerEdgeColor','k','MarkerFaceColor','y','LineWidth',1.5)
labelpoints (age_label_x, age_label_y, age_label2, 'SE');

axis([xmin xmax ymin ymax]);
xlabel('207Pb/235U');
ylabel('206Pb/238U');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

discordant_data = [discordant_samples_sort(:,2),discordant_samples_sort(:,3), ...
	discordant_samples_sort(:,4),discordant_samples_sort(:,5),...
	discordant_samples_sort(:,6),discordant_samples_sort(:,7)];

discordant_data_rho = discordant_samples_sort(:,8);

discordant_data_center=[discordant_data(:,3),discordant_data(:,5)];

discordant_data_sigx_abs = discordant_data(:,3).*discordant_data(:,4).*0.01;
discordant_data_sigy_abs = discordant_data(:,5).*discordant_data(:,6).*0.01;

discordant_data_sigx_sq = discordant_data_sigx_abs.*discordant_data_sigx_abs;
discordant_data_sigy_sq = discordant_data_sigy_abs.*discordant_data_sigy_abs;
discordant_data_rho_sigx_sigy = discordant_data_sigx_abs.*discordant_data_sigy_abs.*discordant_data_rho;
sigmarule=1.25;
numpoints=50;

figure;

for i = 1:length(discordant_data_rho);

discordant_data_covmat=[discordant_data_sigx_sq(i,1),discordant_data_rho_sigx_sigy(i,1);discordant_data_rho_sigx_sigy(i,1), ...
	discordant_data_sigy_sq(i,1)];
[discordant_data_PD,discordant_data_PV]=eig(discordant_data_covmat);
discordant_data_PV=diag(discordant_data_PV).^.5;
discordant_data_theta=linspace(0,2.*pi,numpoints)';
discordant_data_elpt=[cos(discordant_data_theta),sin(discordant_data_theta)]*diag(discordant_data_PV)*discordant_data_PD';
numsigma=length(sigmarule);
discordant_data_elpt=repmat(discordant_data_elpt,1,numsigma).*repmat(sigmarule(floor(1:.5:numsigma+.5)),numpoints,1);
discordant_data_elpt=discordant_data_elpt+repmat(discordant_data_center(i,1:2),numpoints,numsigma);
plot(discordant_data_elpt(:,1:2:end),discordant_data_elpt(:,2:2:end),'r','LineWidth',1.2);
hold on
end

timemin = 0;
timemax = 4500000000;
timeinterval = 50000000;
time = timemin:timeinterval:timemax;

x = exp(0.00000000098485.*time)-1;
y = exp(0.000000000155125.*time)-1;

plot(x,y,'k','LineWidth',1.4)
hold on
scatter(age_label_x, age_label_y,20,'MarkerEdgeColor','k','MarkerFaceColor','y','LineWidth',1.5)
labelpoints (age_label_x, age_label_y, age_label2, 'SE');

axis([xmin xmax ymin ymax]);
xlabel('207Pb/235U');
ylabel('206Pb/238U');



function BL_min_Callback(hObject, eventdata, handles)
% hObject    handle to BL_min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of BL_min as text
%        str2double(get(hObject,'String')) returns contents of BL_min as a double


% --- Executes during object creation, after setting all properties.
function BL_min_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BL_min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function BL_max_Callback(hObject, eventdata, handles)
% hObject    handle to BL_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of BL_max as text
%        str2double(get(hObject,'String')) returns contents of BL_max as a double


% --- Executes during object creation, after setting all properties.
function BL_max_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BL_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function threshold_Callback(hObject, eventdata, handles)
% hObject    handle to threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of threshold as text
%        str2double(get(hObject,'String')) returns contents of threshold as a double


% --- Executes during object creation, after setting all properties.
function threshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function add_int_Callback(hObject, eventdata, handles)
% hObject    handle to add_int (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of add_int as text
%        str2double(get(hObject,'String')) returns contents of add_int as a double


% --- Executes during object creation, after setting all properties.
function add_int_CreateFcn(hObject, eventdata, handles)
% hObject    handle to add_int (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function int_duration_Callback(hObject, eventdata, handles)
% hObject    handle to int_duration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of int_duration as text
%        str2double(get(hObject,'String')) returns contents of int_duration as a double


% --- Executes during object creation, after setting all properties.
function int_duration_CreateFcn(hObject, eventdata, handles)
% hObject    handle to int_duration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in plot_selected.
function plot_selected_Callback(hObject, eventdata, handles)
% hObject    handle to plot_selected (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

cla(handles.axes_current_intensities,'reset');
cla(handles.axes_current_concordia,'reset');

data_ind = handles.data_ind;
name = handles.name;
t_BL_trim_length = handles.t_BL_trim_length;
t_INT_trim = handles.t_INT_trim;
BL_xmin = handles.BL_xmin;
BL_xmax = handles.BL_xmax;
t_INT_trim_max_idx = handles.t_INT_trim_max_idx;
t_INT_trim_min_idx = handles.t_INT_trim_min_idx;
INT_xmax = handles.INT_xmax;
INT_xmin = handles.INT_xmin;

Pb206_U238_err = handles.Pb206_U238_err;
Pb207_U235_err = handles.Pb207_U235_err;
Pb207_Pb206_err = handles.Pb207_Pb206_err;

Pb206_U238 = handles.Pb206_U238;
Pb207_U235 = handles.Pb207_U235;
Pb207_Pb206 = handles.Pb207_Pb206;

All_Pb206_U238_age = handles.All_Pb206_U238_age;
All_Pb206_U238_age_err = handles.All_Pb206_U238_age_err;
All_Pb207_U235_age = handles.All_Pb207_U235_age;
All_Pb207_U235_age_err = handles.All_Pb207_U235_age_err;
All_Pb207_Pb206_age = handles.All_Pb207_Pb206_age;
All_Pb207_Pb206_age_err = handles.All_Pb207_Pb206_age_err;

name_idx = get(handles.listbox1,'Value');

axes(handles.axes_current_intensities);

values = data_ind(:,3:11,name_idx);
values2 = values(any(values,2),:);
t = data_ind(1:length(values2),2,name_idx);
Y1 = msnorm(t,values2);

Y1_BL_trim = Y1(1:t_BL_trim_length(1,length(name)),:);

Y1_BL_trim_min = min(Y1_BL_trim);
Y1_BL_trim_max = max(Y1_BL_trim);
Y1_BL_trim_min = min(Y1_BL_trim_min);
Y1_BL_trim_max = max(Y1_BL_trim_max);

t_INT_trim_last = nonzeros(t_INT_trim(:,name_idx));

t_INT_trim_min = min(t_INT_trim_last);
t_INT_trim_min_idx = t_INT_trim_max_idx - length(t_INT_trim_last) + 1;

Y1_INT_trim = Y1(t_INT_trim_min_idx(1,name_idx):t_INT_trim_max_idx(1,name_idx),:);
values_INT_trim = values(t_INT_trim_min_idx:t_INT_trim_max_idx,:);

Y1_INT_trim_min = min(Y1_INT_trim);
Y1_INT_trim_max = max(Y1_INT_trim);
Y1_INT_trim_min = min(Y1_INT_trim_min);
Y1_INT_trim_max = max(Y1_INT_trim_max);

hold on

rectangle('Position',[BL_xmin Y1_BL_trim_min BL_xmax-BL_xmin Y1_BL_trim_max-Y1_BL_trim_min],'EdgeColor','k','LineWidth',3)
rectangle('Position',[INT_xmin(1,name_idx) Y1_INT_trim_min INT_xmax(1,name_idx)-INT_xmin(1,name_idx) Y1_INT_trim_max-Y1_INT_trim_min],'EdgeColor','k','LineWidth',3)

plot(t,Y1,'LineWidth',1)
xlabel('time (seconds)')
ylabel('Relative Intensities')
title('Normalized Spectra')
h = legend('Hg202','Hg201','Pb204','Pb206','Pb207','Pb208','Th232','U238','Hg204');
set(h,'FontSize',5);

hold off















%%%%%%%%%% only last sample from here down %%%%%%%%%%%%










%%%%%%%%%%%%%%%%%%%% concordia %%%%%%%%%%%%%%%%%%%%%%%%%



%{
final_samples = [final_sample_num, nonzeros(samples.*bias_corr_samples_Pb207_Pb206), nonzeros(samples.*bias_corr_samples_Pb207_Pb206_err), ...
	nonzeros(samples.*bias_corr_samples_Pb207_U235), nonzeros(samples.*bias_corr_samples_Pb207_U235_err), ...
	nonzeros(samples.*bias_corr_samples_Pb206_U238), nonzeros(samples.*bias_corr_samples_Pb206_U238_err), ...
	nonzeros(samples.*rho), nonzeros(samples.*bias_corr_samples_Pb208_Th232), nonzeros(samples.*bias_corr_samples_Pb208_Th232_err), ...
	samples_Pb206_U238_age, samples_Pb206_U238_age_err, samples_Pb207_U235_age, samples_Pb207_U235_age_err, ...
	samples_Pb207_Pb206_age, samples_Pb207_Pb206_age_err, samples_Pb208_Th232_age, samples_Pb208_Th232_age_err, ...
	discordance_Pb206U238_Pb207Pb206, discordance_Pb206U238_Pb207U235, best_age, best_age_err];
%}






rhoA =((Pb206_U238_err.*Pb206_U238_err) + ...
	(Pb207_U235_err.*Pb207_U235_err)) - ...
	(Pb207_Pb206_err.*Pb207_Pb206_err);
rhoB =2.*(Pb206_U238_err.*Pb207_U235_err);
rho = rhoA./rhoB;


if rho < 0
	rho_corr = 0.7;
elseif rho > 1
	rho_corr = 0.7;
else
	rho_corr = rho;
end


concordia_data = [Pb207_Pb206,Pb207_Pb206_err, ...
	Pb207_U235,Pb207_U235_err,...
	Pb206_U238,Pb206_U238_err];

center=[concordia_data(name_idx,3),concordia_data(name_idx,5)];

sigx_abs = concordia_data(:,3).*concordia_data(:,4).*0.01;
sigy_abs = concordia_data(:,5).*concordia_data(:,6).*0.01;

sigx_sq = sigx_abs(name_idx,1).*sigx_abs(name_idx,1);
sigy_sq = sigy_abs(name_idx,1).*sigy_abs(name_idx,1);
rho_sigx_sigy = sigx_abs(name_idx,1).*sigy_abs(name_idx,1).*rho(name_idx,1);
sigmarule=1.25;
numpoints=50;


axes(handles.axes_current_concordia)

covmat=[sigx_sq,rho_sigx_sigy;rho_sigx_sigy,sigy_sq];
[PD,PV]=eig(covmat);
PV=diag(PV).^.5;
theta=linspace(0,2.*pi,numpoints)';
elpt=[cos(theta),sin(theta)]*diag(PV)*PD';
numsigma=length(sigmarule);
elpt=repmat(elpt,1,numsigma).*repmat(sigmarule(floor(1:.5:numsigma+.5)),numpoints,1);
elpt=elpt+repmat(center,numpoints,numsigma);
plot(elpt(:,1:2:end),elpt(:,2:2:end),'b','LineWidth',2);
hold on

timemin = 0;
timemax = 4500000000;
timeinterval = 50000000;
time = timemin:timeinterval:timemax;

x = exp(0.00000000098485.*time)-1;
y = exp(0.000000000155125.*time)-1;

xaxismin = Pb207_U235(name_idx,1) - 0.15.*Pb207_U235(name_idx,1);
xaxismax = Pb207_U235(name_idx,1) + 0.15.*Pb207_U235(name_idx,1);
yaxismin = Pb206_U238(name_idx,1) - 0.15.*Pb206_U238(name_idx,1);
yaxismax = Pb206_U238(name_idx,1) + 0.15.*Pb206_U238(name_idx,1);

Pb206_U238_age = 1/0.000000000155125.*log(1+Pb206_U238)/1000000;
Pb206_U238_age_err =abs((1/0.000000000155125.*log(1+Pb206_U238 ...
	-(Pb206_U238_err/100.*Pb206_U238))/1000000) ...
	-(1/0.000000000155125.*log(1+Pb206_U238 ...
	+(Pb206_U238_err/100.*Pb206_U238))/1000000))/2;

Pb207_Pb206_age = All_Pb206_U238_age(name_idx,1);
Pb207_Pb206_age_err = All_Pb206_U238_age_err(name_idx,1);

%Pb207_Pb206_age = newton_method(Pb207_Pb206(name_idx,1), 2000, .0000001);
%Pb207_Pb206_age_err = AgePb76Er5(Pb207_Pb206_age, Pb207_Pb206_err);


age_label_num = [100:50:5000];
for i=1:length(age_label_num)
age_label(i,1) = {sprintf('%.1f',age_label_num(1,i))};
age_label2(i,1) = strcat(age_label(i,1),' Ma');
end
age_label_num = age_label_num.*1000000;
age_label_x = exp(0.00000000098485.*age_label_num)-1;
age_label_y = exp(0.000000000155125.*age_label_num)-1;

plot(x,y,'k','LineWidth',1.4)
hold on
scatter(age_label_x, age_label_y,20,'MarkerEdgeColor','k','MarkerFaceColor','y','LineWidth',1.5)
labelpoints (age_label_x, age_label_y, age_label2, 'SE');


cutoff_76_68 = str2num(get(handles.filter_transition_68_76,'String'));

age_label3_x = Pb207_U235(name_idx,1);
age_label3_y = Pb206_U238(name_idx,1);

if Pb206_U238_age < cutoff_76_68
    age_label3 = {Pb206_U238_age};
else
    age_label3 = {Pb207_Pb206_age};
end

if Pb206_U238_age < cutoff_76_68
    age_label4 = {Pb206_U238_age_err};
else
    age_label4 = {Pb207_Pb206_age_err};
end

scatter(age_label3_x, age_label3_y, 200,'MarkerEdgeColor','k','MarkerFaceColor','g','LineWidth',1.5);
%labelpoints (age_label3_x, age_label3_y, age_label3, 'NW', .005,'FontSize', 25);

%age_plot = strcat(age_label3, ' +/- ', age_label4)
set(handles.text139, 'String', age_label3); 
set(handles.text141, 'String', age_label4); 



axis([xaxismin xaxismax yaxismin yaxismax]);
xlabel('207Pb/235U');
ylabel('206Pb/238U');


% --- Executes on button press in example_txt.
function example_txt_Callback(hObject, eventdata, handles)
% hObject    handle to example_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function replace_bad_rho_Callback(hObject, eventdata, handles)
% hObject    handle to replace_bad_rho (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of replace_bad_rho as text
%        str2double(get(hObject,'String')) returns contents of replace_bad_rho as a double


% --- Executes during object creation, after setting all properties.
function replace_bad_rho_CreateFcn(hObject, eventdata, handles)
% hObject    handle to replace_bad_rho (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in radio_errorprop_sliding.
function radio_errorprop_sliding_Callback(hObject, eventdata, handles)
% hObject    handle to radio_errorprop_sliding (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radio_errorprop_sliding


% --- Executes on button press in radio_errorprop_envelope.
function radio_errorprop_envelope_Callback(hObject, eventdata, handles)
% hObject    handle to radio_errorprop_envelope (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radio_errorprop_envelope


function ref_mat_primary_Callback(hObject, eventdata, handles)
% hObject    handle to ref_mat_primary (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ref_mat_primary as text
%        str2double(get(hObject,'String')) returns contents of ref_mat_primary as a double


% --- Executes during object creation, after setting all properties.
function ref_mat_primary_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ref_mat_primary (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ref_mat_secondary_Callback(hObject, eventdata, handles)
% hObject    handle to ref_mat_secondary (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ref_mat_secondary as text
%        str2double(get(hObject,'String')) returns contents of ref_mat_secondary as a double


% --- Executes during object creation, after setting all properties.
function ref_mat_secondary_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ref_mat_secondary (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in radio_intensities_log.
function radio_intensities_log_Callback(hObject, eventdata, handles)
% hObject    handle to radio_intensities_log (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radio_intensities_log


% --- Executes on button press in radio_intensities_norm.
function radio_intensities_norm_Callback(hObject, eventdata, handles)
% hObject    handle to radio_intensities_norm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radio_intensities_norm


% --- Executes on button press in radio_plot_fractionation.
function radio_plot_fractionation_Callback(hObject, eventdata, handles)
% hObject    handle to radio_plot_fractionation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radio_plot_fractionation


% --- Executes on button press in radio_plot_ratios.
function radio_plot_ratios_Callback(hObject, eventdata, handles)
% hObject    handle to radio_plot_ratios (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radio_plot_ratios


% --- Executes on button press in pushbutton59.
function pushbutton59_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton59 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton60.
function pushbutton60_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton60 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton61.
function pushbutton61_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton61 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton62.
function pushbutton62_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton62 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton63.
function pushbutton63_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton63 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function outlier_cutoff_75_Callback(hObject, eventdata, handles)
% hObject    handle to outlier_cutoff_75 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of outlier_cutoff_75 as text
%        str2double(get(hObject,'String')) returns contents of outlier_cutoff_75 as a double


% --- Executes during object creation, after setting all properties.
function outlier_cutoff_75_CreateFcn(hObject, eventdata, handles)
% hObject    handle to outlier_cutoff_75 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function outlier_cutoff_82_Callback(hObject, eventdata, handles)
% hObject    handle to outlier_cutoff_82 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of outlier_cutoff_82 as text
%        str2double(get(hObject,'String')) returns contents of outlier_cutoff_82 as a double


% --- Executes during object creation, after setting all properties.
function outlier_cutoff_82_CreateFcn(hObject, eventdata, handles)
% hObject    handle to outlier_cutoff_82 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end






function sliding_window_Callback(hObject, eventdata, handles)
% hObject    handle to sliding_window (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sliding_window as text
%        str2double(get(hObject,'String')) returns contents of sliding_window as a double


% --- Executes during object creation, after setting all properties.
function sliding_window_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliding_window (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function diff_cutoff_68_Callback(hObject, eventdata, handles)
% hObject    handle to diff_cutoff_68 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of diff_cutoff_68 as text
%        str2double(get(hObject,'String')) returns contents of diff_cutoff_68 as a double


% --- Executes during object creation, after setting all properties.
function diff_cutoff_68_CreateFcn(hObject, eventdata, handles)
% hObject    handle to diff_cutoff_68 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function diff_cutoff_76_Callback(hObject, eventdata, handles)
% hObject    handle to diff_cutoff_76 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of diff_cutoff_76 as text
%        str2double(get(hObject,'String')) returns contents of diff_cutoff_76 as a double


% --- Executes during object creation, after setting all properties.
function diff_cutoff_76_CreateFcn(hObject, eventdata, handles)
% hObject    handle to diff_cutoff_76 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function diff_cutoff_75_Callback(hObject, eventdata, handles)
% hObject    handle to diff_cutoff_75 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of diff_cutoff_75 as text
%        str2double(get(hObject,'String')) returns contents of diff_cutoff_75 as a double


% --- Executes during object creation, after setting all properties.
function diff_cutoff_75_CreateFcn(hObject, eventdata, handles)
% hObject    handle to diff_cutoff_75 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function diff_cutoff_82_Callback(hObject, eventdata, handles)
% hObject    handle to diff_cutoff_82 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of diff_cutoff_82 as text
%        str2double(get(hObject,'String')) returns contents of diff_cutoff_82 as a double


% --- Executes during object creation, after setting all properties.
function diff_cutoff_82_CreateFcn(hObject, eventdata, handles)
% hObject    handle to diff_cutoff_82 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end









function reject_poly_order_Callback(hObject, eventdata, handles)
% hObject    handle to reject_poly_order (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of reject_poly_order as text
%        str2double(get(hObject,'String')) returns contents of reject_poly_order as a double


% --- Executes during object creation, after setting all properties.
function reject_poly_order_CreateFcn(hObject, eventdata, handles)
% hObject    handle to reject_poly_order (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function reject_spline_breaks_Callback(hObject, eventdata, handles)
% hObject    handle to reject_spline_breaks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of reject_spline_breaks as text
%        str2double(get(hObject,'String')) returns contents of reject_spline_breaks as a double


% --- Executes during object creation, after setting all properties.
function reject_spline_breaks_CreateFcn(hObject, eventdata, handles)
% hObject    handle to reject_spline_breaks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton69.
function pushbutton69_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton69 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edit110_Callback(hObject, eventdata, handles)
% hObject    handle to edit110 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit110 as text
%        str2double(get(hObject,'String')) returns contents of edit110 as a double


% --- Executes during object creation, after setting all properties.
function edit110_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit110 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit111_Callback(hObject, eventdata, handles)
% hObject    handle to edit111 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit111 as text
%        str2double(get(hObject,'String')) returns contents of edit111 as a double


% --- Executes during object creation, after setting all properties.
function edit111_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit111 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit112_Callback(hObject, eventdata, handles)
% hObject    handle to edit112 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit112 as text
%        str2double(get(hObject,'String')) returns contents of edit112 as a double


% --- Executes during object creation, after setting all properties.
function edit112_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit112 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit113_Callback(hObject, eventdata, handles)
% hObject    handle to edit113 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit113 as text
%        str2double(get(hObject,'String')) returns contents of edit113 as a double


% --- Executes during object creation, after setting all properties.
function edit113_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit113 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit114_Callback(hObject, eventdata, handles)
% hObject    handle to edit114 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit114 as text
%        str2double(get(hObject,'String')) returns contents of edit114 as a double


% --- Executes during object creation, after setting all properties.
function edit114_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit114 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit115_Callback(hObject, eventdata, handles)
% hObject    handle to edit115 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit115 as text
%        str2double(get(hObject,'String')) returns contents of edit115 as a double


% --- Executes during object creation, after setting all properties.
function edit115_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit115 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton70.
function pushbutton70_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton70 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton71.
function pushbutton71_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton71 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edit116_Callback(hObject, eventdata, handles)
% hObject    handle to edit116 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit116 as text
%        str2double(get(hObject,'String')) returns contents of edit116 as a double


% --- Executes during object creation, after setting all properties.
function edit116_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit116 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton72.
function pushbutton72_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton72 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edit55_Callback(hObject, eventdata, handles)
% hObject    handle to xmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xmin as text
%        str2double(get(hObject,'String')) returns contents of xmin as a double


% --- Executes during object creation, after setting all properties.
function edit55_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit57_Callback(hObject, eventdata, handles)
% hObject    handle to xmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xmax as text
%        str2double(get(hObject,'String')) returns contents of xmax as a double


% --- Executes during object creation, after setting all properties.
function edit57_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit58_Callback(hObject, eventdata, handles)
% hObject    handle to xint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xint as text
%        str2double(get(hObject,'String')) returns contents of xint as a double


% --- Executes during object creation, after setting all properties.
function edit58_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit59_Callback(hObject, eventdata, handles)
% hObject    handle to ymin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ymin as text
%        str2double(get(hObject,'String')) returns contents of ymin as a double


% --- Executes during object creation, after setting all properties.
function edit59_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ymin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit60_Callback(hObject, eventdata, handles)
% hObject    handle to ymax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ymax as text
%        str2double(get(hObject,'String')) returns contents of ymax as a double


% --- Executes during object creation, after setting all properties.
function edit60_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ymax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit61_Callback(hObject, eventdata, handles)
% hObject    handle to bins (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of bins as text
%        str2double(get(hObject,'String')) returns contents of bins as a double


% --- Executes during object creation, after setting all properties.
function edit61_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bins (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton73.
function pushbutton73_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton73 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton74.
function pushbutton74_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton74 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function Myr_Kernel_text_Callback(hObject, eventdata, handles)
% hObject    handle to Myr_Kernel_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Myr_Kernel_text as text
%        str2double(get(hObject,'String')) returns contents of Myr_Kernel_text as a double


% --- Executes during object creation, after setting all properties.
function Myr_Kernel_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Myr_Kernel_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton76.
function pushbutton76_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton76 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function pval_Callback(hObject, eventdata, handles)
% hObject    handle to pval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pval as text
%        str2double(get(hObject,'String')) returns contents of pval as a double


% --- Executes during object creation, after setting all properties.
function pval_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
