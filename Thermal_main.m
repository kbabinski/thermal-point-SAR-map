%% 
%***************************************************************************************
%    Title: Thermal Image SAR Map Algorithm
%    Author: Kristina Babinski
%    Date: 2017
%    Organization: University of Maryland UAS Test Site
%**************************************************************************************/
%% 
close all;
clear variables;
clc;
%% Read in image then convert to grayscale, then black and white
I=imread ('whiteHotIR_2.JPG');
%%Convert to grayscale
Igray= rgb2gray(I);
level = .9;
Ibinary = imbinarize (Igray, level);
imshow (Ibinary);
%Ibinary2 = imfill(Ibinary,'holes');
%Ibinary2 = bwareaopen (Ibinary, 80);
%imshowpair (Ibinary, Ibinary2, 'montage');

%% Crop image if necessary - Data printed on image can obscure results

%[x, y] = size (Ibinary2);
%IbwCrop = Ibinary2 (30:430, 20:620);
% IbwCrop is image to be used for ID POI
%imshow (IbwCrop);
%imshowpair (I, IbwCrop, 'montage');

%% Identify Point of Interest in image (POI) True/False

%***************************************************************************************
%    Title: Image Processing and Counting Using MATLAB
%    Author: Aditya Reddy
%    Date: 2017
%    Code version: 1
%    Availability: http://www.instructables.com/id/Image-Processing-and-Counting-using-MATLAB/
%**************************************************************************************/
%If image was cropped, use IbwCrop in place of Ibinary
B = bwboundaries(Ibinary);
imshow(Ibinary)
text(10,10,strcat('\color{green}Objects Found:',num2str(length(B))))
hold on

for k = 1:length(B)
boundary = B{k};
plot(boundary(:,2), boundary(:,1), 'g', 'LineWidth', 0.2)
end
%If/else statement to identify 
A = bwarea (Ibinary);
if (A > 100)
ID = 1;
disp ('There is a point of interest in this image');
else 
disp ('There is NO point of interest in this image');
ID = 0;
end

%% Read in the time the photo was taken

imageInfo = imfinfo('whiteHotIR_2.JPG');
imageDate = imageInfo.FileModDate;
% Image time needs to be changed to zulu time to correspond with GPS info
imageDateLocal = datetime(imageDate,'TimeZone','America/New_York');

imageDateLocal.TimeZone = 'Atlantic/Reykjavik'; %This line changes it to zulu time to correspond with .gpx data
    %Time zone may need to be altered based on daylight savings. Confirm
    %change in "imageDateLocal" variable in workspace. To search for other
    %variables type timezones ('America') or timezones ('Atlantic') etc.
    %into command window
    
% imageDateLocal needs to be formatted to match gps info
%formatOut = 'yyyy-mm-dd HH:MM:SS';
formatOut = 'HH:MM:SS';
imageDateZuluFormat = datestr(imageDateLocal,formatOut);


%% Read in .gpx file and place necessary data into cells
%***************************************************************************************
%    Author: Mathew Vaugn
%    Date: 6/20/2017
%**************************************************************************************/
%clear all; close all; clc;
fileID = fopen('badElf1.gpx','r');
transpose_data = fopen('extracted_data.csv','wt');
line = fgets(fileID);
regex = '^<trkpt lat="(-?\d+\.\d+)" lon="(-?\d+\.\d+)"><ele>\d+\.\d+</ele><time>(\d{4}-\d{2}-\d{2})T(\d+:\d+:\d+).*$'
while(line ~= -1)
    [tokens matches] = regexp(line,regex,'tokens','match')
    %store the info somehow
    if ~isempty(tokens)
        fprintf(transpose_data,'%s,%s,%s,%s\n',tokens{1}{1,:});
    end
    line = fgets(fileID);
end
fclose(fileID);
fclose(transpose_data);

%% Read in extracted_data.csv file, create table with row names
table = readtable('extracted_data.csv');
table.Properties.VariableNames = {'Lat' 'Lon' 'Date' 'Time'};

%% Use a regular expression to pull the row out of a table that contains the same expression as variable imageDateZuluFormat
Lia = ismember(table.Time, imageDateZuluFormat);
RowIdx = find(Lia);
rows = RowIdx;
vars = 'Lat';
lat = table{rows, vars};
vars2 = 'Lon';
lon = table{rows, vars2};


%% limLat = [min(Lat) max(Lat)];
% 
% tracks = gpxread('badElf1.gpx', 'Index', 1:2);
% webmap('openstreetmap')
% colors = {'cyan'};
% wmline(tracks, 'Color', colors)
% [latlim, lonlim] = geoquadline(tracks(1).Latitude, tracks(1).Longitude);
% wmlimits(latlim, lonlim)
