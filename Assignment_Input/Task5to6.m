% Task 5: Robust method --------------------------
clear; close all;
I = imread('IMG_05.png');
%figure, imshow(I)
I_gray = rgb2gray(I);
%figure, imshow(I_gray)
B = imresize(I_gray, [512 NaN]);
%figure, imshow(B)
histogram(B, 64)
pout_imadjust = imadjust(B);
pout_histeq = histeq(B);
pout_adapthisteq = adapthisteq(B);
histogram(B, 64)
C = imbinarize(B);
%figure, imshowpair(B,BW,'montage')
[~,threshold] = edge(C,'sobel');
fudgeFactor = 0.5;
D = edge(C,'sobel',threshold * fudgeFactor);
figure, imshow(D)
padsize = 1;
padvalue = 255; % or 1 if image is single, double, or logical.
paddedImage = padarray(D, padsize, padvalue);
se90 = strel('line', 3, 90);
se0 = strel('line', 3, 0);
BWsdil = imdilate(paddedImage, [se90 se0]);
figure, imshow(BWsdil), title('dilated gradient mask');
BWdfill = imfill(BWsdil, 'holes');
figure, imshow(BWdfill);
BWnobord = imclearborder(BWdfill,4); %Removes the border that was made earlier
props = regionprops(BWnobord, 'MajorAxisLength', 'MinorAxisLength'); %Calculates the Axis length
MajorAxisL = [props.MajorAxisLength]; %Stores the Axis length
MinorAxisL = [props.MinorAxisLength];
aspectRatio = MajorAxisL ./ MinorAxisL; %Calculates the aspect ratio
Amount = length(props);
cmap = zeros(Amount+1, 3);
for k = 1 : Amount %For loop for the amount of objects in the image
	if aspectRatio(k) > 2.3 % Whatever value you want.
		cmap(k+1, :) = [0, 0, 1]; % Bacteria is labeled in blue
	else
		cmap(k+1, :) = [1, 0, 0]; % The blood cells have a smaller aspect ratio value and are labeled red
	end
end
cmap;
h3 = subplot(2, 2, 3);
labeledImage = bwlabel(BWnobord);
ReLabeled = imresize(labeledImage, [512 NaN]);
imshow(labeledImage, []);
colormap(h3, cmap);
% Task 6: Performance evaluation -----------------
% Step 1: Load ground truth data
GT = imread("IMG_05_GT.png");
L_GT = label2rgb(GT(:,:,1), 'prism','k','shuffle');
L_GT = rgb2gray(L_GT);
B_GT = imresize(L_GT, [514, 566]);
I2 = im2double(B_GT);
I2 = logical(I2);
labeledImage = logical(labeledImage);
mask = false(size(labeledImage));
mask(25:end-25,25:end-25) = true;
BW = activecontour(labeledImage, mask, 300);
mask2 = false(size(B_GT));
mask2(25:end-25,25:end-25) = true;
BA_GT = activecontour(B_GT, mask2, 300);
similarity = dice(labeledImage, I2);
TP=0;FP=0;TN=0;FN=0;
      for i=1:514
          for j=1:566
              if(I2(i,j)==1 && labeledImage(i,j)==1)
                  TP=TP+1;
              elseif(I2(i,j)==0 && labeledImage(i,j)==1)
                  FP=FP+1;
              elseif(I2(i,j)==0 && labeledImage(i,j)==0)
                  TN=TN+1;
              else
                  FN=FN+1;
              end
          end
      end
Recall = TP / (TP + FN);
Precision = TP/(TP + FP);
figure, imshowpair(B_GT, labeledImage)
title(['Dice = ' num2str(similarity) ' Recall = ' num2str(Recall) ' Precision = ' num2str(Precision)])