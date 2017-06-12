%% 
%***************************************************************************************
%    Title: Thermal Image SAR Map Algorithm
%    Author: Kristina Babinski
%    Date: 2017
%    Organization: University of Maryland UAS Test Site
%**************************************************************************************/
%% Read in image
I=imread ('WhiteHot1.png');
%%Convert to grayscale
Igray= rgb2gray(I);
%% Convert to BW with threshold
level = .9;
Ibinary = imbinarize (Igray, level);
%Ibinary2 = imfill(Ibinary,'holes');
Ibinary2 = bwareaopen (Ibinary, 80);
%imshowpair (Ibinary, Ibinary2, 'montage');

%% Crop image to remove time/lat/long data for identification of "point of
%%interest" (POI)
[x, y] = size (Ibinary2);
IbwCrop = Ibinary2 (30:430, 20:620);
% IbwCrop is image to be used for ID POI
imshow (IbwCrop);
%imshowpair (I, IbwCrop, 'montage');

%% POI identification - return true or false 
%***************************************************************************************
%    Title: Image Processing and Counting Using MATLAB
%    Author: Aditya Reddy
%    Date: 2017
%    Code version: 1
%    Availability: http://www.instructables.com/id/Image-Processing-and-Counting-using-MATLAB/
%**************************************************************************************/
B = bwboundaries(IbwCrop);
imshow(IbwCrop)
text(10,10,strcat('\color{green}Objects Found:',num2str(length(B))))
hold on

for k = 1:length(B)
boundary = B{k};
plot(boundary(:,2), boundary(:,1), 'g', 'LineWidth', 0.2)
end
%If/else statement to identify 
A = bwarea (IbwCrop);
if (A > 1000)
ID = 1;
disp ('There is a point of interest in this image');
else 
disp ('There is NO point of interest in this image');
ID = 0;
end
%% Lat/Long info from image.
%Crop lat/long from bottom left corner of image
IbwCrop2 = Igray(450:480, 1:130);
imshow (IbwCrop2);

textResults= ocr (IbwCrop2);

%Now you need to figure out how to clean up this image so you can use ocr
%to extract the coordinates -.-






