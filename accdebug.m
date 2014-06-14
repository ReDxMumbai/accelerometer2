%%Corresponding Arduino Code
 %% Initialize
if exist('micro','var')
    fclose(micro)
    instrreset
    clear
    close all
    clc
end
%% Setup
micro = serial('/dev/tty.usbserial-A1019F7C');
set(micro,'BaudRate',9600);
sampleSize = 5;%number of int's being transmitted
nSamples = 5;
bufferSize = sampleSize * nSamples*2; %in bytes
set(micro, 'InputBufferSize', bufferSize)
fopen(micro)
pause(2)

%% Capture
window = 100*nSamples;
data = zeros(window,sampleSize);
ind = 1:nSamples:window;
lim = numel(ind);
chunk = ind(2) - ind(1) - 1;
pos = 1;


if micro.BytesAvailable > 0
    dump = fread(micro, micro.BytesAvailable); % EMPTY BUFFER
    clear dump
end
time = clock;
timestamp = [num2str(time(1)) '_' num2str(time(2)) '_' num2str(time(3)) ...
    '_' num2str(time(4)) '_' num2str(time(5)) '_' num2str(round(time(6)))];
fid = fopen(['testdata' timestamp '.csv'],'w');
graph=zeros(1,window);
index=1;

while (1)
    %tic
    fwrite(micro,1);
    raw = fscanf(micro,'%f')';
    if length(raw)<3
        continue;
    end
    %disp(sqrt(raw*raw'));
    graph(index+1)=sqrt(raw*raw');
    index=mod(index+1,window-1);
    %disp(index);
    figure(1);
    plot(1:window,graph);
    drawnow;
    fprintf(fid,'%d,%d\n',graph,index);
    
end
fclose(fid)
