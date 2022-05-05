clear; close all;

% Task 1: Pre-processing -----------------------
% Step-1: Load input image
I = imread('IMG_11.png');
%figure, imshow(I)

% Step-2: Covert image to grayscale
I_gray = rgb2gray(I);
%figure, imshow(I_gray)

% Step-3: Rescale image
B = imresize(I_gray, [512 NaN]);
%figure, imshow(B)
histogram(B, 64)

% Step-5: Enhance image before binarisation
pout_imadjust = imadjust(B);
pout_histeq = histeq(B);
pout_adapthisteq = adapthisteq(B);
% Step-6: Histogram after enhancement
histogram(B, 64)
% Step-7: Image Binarisation
C = imbinarize(B);
%figure, imshowpair(B,BW,'montage')
% Task 2: Edge detection ------------------------
[~,threshold] = edge(C,'sobel');
fudgeFactor = 0.5;
D = edge(C,'sobel',threshold * fudgeFactor);
figure, imshow(D)
% Task 3: Simple segmentation --------------------
padsize = 1;
padvalue = 255; % or 1 if image is single, double, or logical.
paddedImage = padarray(D, padsize, padvalue);
se90 = strel('line', 3, 90);
se0 = strel('line', 3, 0);
BWsdil = imdilate(paddedImage, [se90 se0]);
figure, imshow(BWsdil), title('dilated gradient mask');
BWdfill = imfill(BWsdil, 'holes');
figure, imshow(BWdfill);
% Task 4: Object Recognition --------------------
BWnobord = imclearborder(BWdfill,4); %Removes the border that was made earlier
props = regionprops(BWnobord, 'MajorAxisLength', 'MinorAxisLength'); %Calculates the Axis length
MajorAxisL = [props.MajorAxisLength]; %Stores the Axis length
MinorAxisL = [props.MinorAxisLength];
aspectRatio = MajorAxisL ./ MinorAxisL; %Calculates the aspect ratio
Amount = length(props);
cmap = zeros(Amount+1, 3);
for k = 1 : Amount %For loop for the amount of objects in the image
	if aspectRatio(k) > 2 % Whatever value you want.
		cmap(k+1, :) = [0, 0, 1]; % Bacteria is labeled in blue
	else
		cmap(k+1, :) = [1, 0, 0]; % The blood cells have a smaller aspect ratio value and are labeled red
	end
end
cmap;
h3 = subplot(2, 2, 3);
labeledImage = bwlabel(BWnobord);
imshow(labeledImage, []);
colormap(h3, cmap);