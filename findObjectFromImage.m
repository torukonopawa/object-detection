function [centerCoords, currentFrame] = findObjectFromImage(imageSnapshot, fudgeFactor, imageFormat)
    %Finding center of the object from the image.
    %inputs:
    %   fileName : image file name
    %outputs:
    %   centerCoords : x,y coord of object

        %take image, grayscale and turn it into 2D array
    %rgbImageMatrix = imread(imageSnapshot);
    rgbImageMatrix = imageSnapshot;
    imageMatrix = rgb2gray(rgbImageMatrix);

        %removing unwanted pixels/noise as much as possible (w/MORPHOLOGY)
    [~,threshold] = edge(imageMatrix,'sobel');
    %if very high fudgeFactor, object borders starts to vanish
    %fudgeFactor = 1; %1;
    BWblackwhite = edge(imageMatrix,'sobel',threshold * fudgeFactor);
    %with structural element(disk), white borders expands
    SE = strel('disk',5);
    BWdilated = imdilate(BWblackwhite, SE);
    %filling inside circles
    BWfilled = imfill(BWdilated,'holes');
    
    imshow(BWfilled);
    
    %get struct of all regions data (area/center)
    regions = regionprops('struct', BWfilled, 'area', 'centroid');
    %put data to matrices
    regionAreaSizes = [regions.Area];
        regionCenters = [regions.Centroid];
        	xCents = regionCenters(1:2:end)';
        	yCents = regionCenters(2:2:end)';
    regionCenters = [xCents yCents];
    %find largest region, assume it is the object
    [objectArea,objectIndex] = max(regionAreaSizes);
    %return object coords
    objectCoords = regionCenters(objectIndex,:);

        %show image, send center coords
   centerCoords = objectCoords;
   
   currentFrame = BWfilled;
   %centerCoords = 0;
   
   switch imageFormat
       case 1
           imshow(rgbImageMatrix);
       case 2
           imshow(imageMatrix);
       case 3
           imshow(BWfilled);
   end
   
        %show object
    hold on;
	viscircles(objectCoords, sqrt(objectArea/pi));
    hold off;

end
