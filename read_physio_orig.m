function data_list = read_physio(fname);
% function to physiology log files from scanner
% Inputs:
%  1) fname: Filename to be read
% 
% Outputs:
%  1) data_list: structure containing all the columns of the file 
%                in separate fields
%
%%  Daniel Herzka
%%  Philips Research North America
%%  Code: Version 2 
%%  Date: 02-10-05

close all
CommentLines = 5;
plotflag = 0; % flag to turn on the individual plotting of each field
dt = 0.002;  % assume 500Hz sampling rate

% read the .dat file
fname
fid = fopen([fname])
if fid==-1
    disp('read_physio: Error opening file.');
    data_list = [];
    return;
end;

% Extract numbers
rawdata = textscan(fid,'%d%d%d%d%d%d%d%d%d%d%d%d%d','delimiter',' ','commentStyle', '#', 'headerLines', CommentLines);
               % this is not the fastest way to scan the file, but will do
               % for now...
rawdata = {rawdata{[1,2,4,5,7,8,10:end]}};
t = [1:length(rawdata{1})] * dt;

% Extract comments
fseek(fid,0,-1);     % rewind file
for i = 1:CommentLines
    fields = fgetl(fid);
end;
fclose(fid);
fields2 = fields

% tokenize field names and distribute data
count = 1;
[T,fields] = strtok(fields);
plot_fields = []; %plot_flags = [];
data_list.constant = [];
while ~isempty(fields)
    [T,fields] = strtok(fields);
    data_list.(T) = rawdata{count};
    if length(unique(data_list.(T)))>1
        data_list.constant(end+1) = NaN;
        plot_fields = strvcat(plot_fields, T);
        %plot_flag =[plot_flag 1];
    else
        data_list.constant(end+1) = unique(data_list.(T));
    end;
    count = count+1;
end;

% find markers within data.
%                         0x01        0x02   0x04        0x08          0x10         0x20 
marker_legend = strvcat( 'ECG_Rtop', 'PPU', 'RespTrig', 'MeasMarker', 'StartScan', 'StopScan');    
flags = uint8(2.^[0:5]);
[i,j] = find(bitand( repmat(uint8(data_list.mark), [1,                     length(flags)]),...
                     repmat(flags,                 [size(data_list.mark,1),1])));
for ii = 1:size(marker_legend)
    data_list.markers.(deblank(marker_legend(ii,:))) = i(find(j==flags(ii)));
end;
    
    
    
if plotflag

    % determine plot grid sizes (add extra for legend)
    C = ceil(sqrt(sum(size(plot_fields,1) + 1)));
    R = ceil(sum(size(plot_fields,1) +1 )/C );
    
    styles = ['rs';'go'; 'kd'; 'r+'; 'g^'; 'kv'];
    

    for ii = 1:size(plot_fields,1)
        %figure
        subplot(R,C,ii);
        plot(t,data_list.(deblank(plot_fields(ii,:))), 'b.-');
        hold on;
        xlabel('Time (s)');
        ylabel(deblank(plot_fields(ii,:)));
        c = 1; leg_string = [];
         for jj = 1:length(flags)
            d = i(find(j==flags(jj)));
            if ~isempty(d)
                p(c) = plot(d*dt, data_list.(deblank(plot_fields(ii,:)))(d), styles(jj,:));
                c = c+1;
                leg_string = strvcat(leg_string, marker_legend(jj,:));
            end;
        end;    
         legend(p, leg_string)
    end;

 end

    
    
    
function n = tok1(r)
[t,rr] = strtok(r);
if isempty(rr), n = str2num(t); return; end;
n = [ str2num(t), tok1(deblank(rr))];
    