function panorama = generate_panorama(detector, imds, C, MT, MD)
    

    I = readimage(imds,1);
    grayImage = im2gray(I);

    % detect point features from points
    points = detectSURFFeatures(detector(grayImage));


    % extract feature descriptors at the points
    [features, points] = extractFeatures(grayImage, points);

    numImages = numel(imds.Files);
    tforms(numImages) = projtform2d;

    for n = 2:numImages
        
        pointsPrevious = points;
        featuresPrevious = features;
        
        I = readimage(imds, n);
        grayImage = im2gray(I);
        imageSize(n,:) = size(grayImage);

        % detect point features from points
        points = detectSURFFeatures(detector(grayImage));

        % extract feature descriptors at the points
        [features,points] = extractFeatures(grayImage, points);
        
        % match the features using descriptors
        indexPairs = matchFeatures(features, featuresPrevious, Unique=true);
        
        matchedPoints = points(indexPairs(:,1), :);
        matchedPointsPrev = pointsPrevious(indexPairs(:,2), :); 
        
        % RANSAC 
        tforms(n) = estgeotform2d(matchedPoints, matchedPointsPrev,...
        'projective', 'Confidence', C, 'MaxNumTrials', MT, 'MaxDistance', MD);

        tforms(n).A = tforms(n-1).A * tforms(n).A; 

        %showMatchedFeatures(imagesOriginal(:,:,n-1),imagesOriginal(:,:,n),matchedPointsPrev, ... 
        %    matchedPoints, 'montage')
    end

    for i = 1:numel(tforms)           
        [xlim(i,:), ylim(i,:)] = outputLimits(tforms(i), [1 imageSize(i,2)], [1 imageSize(i,1)]);    
    end

    avgXLim = mean(xlim, 2);
    [~,idx] = sort(avgXLim);
    centerIdx = floor((numel(tforms)+1)/2);
    centerImageIdx = idx(centerIdx);
    Tinv = invert(tforms(centerImageIdx));

    for i = 1:numel(tforms)    
        tforms(i).A = Tinv.A * tforms(i).A;
    end

    for i = 1:numel(tforms)           
        [xlim(i,:), ylim(i,:)] = outputLimits(tforms(i), [1 imageSize(i,2)], [1 imageSize(i,1)]);
    end
    maxImageSize = max(imageSize);
     
    xMin = min([1; xlim(:)]);
    xMax = max([maxImageSize(2); xlim(:)]);
    yMin = min([1; ylim(:)]);
    yMax = max([maxImageSize(1); ylim(:)]);
    
    width  = round(xMax - xMin);
    height = round(yMax - yMin);
    
    panorama = zeros([height width 3], 'like', I);
    blender = vision.AlphaBlender('Operation', 'Binary mask', ...
        'MaskSource', 'Input port');  
    
    xLimits = [xMin xMax];
    yLimits = [yMin yMax];
    panoramaView = imref2d([height width], xLimits, yLimits);
    
    for i = 1:numImages
    
        I = readimage(imds, i);   
   
        
        warpedImage = imwarp(I, tforms(i), 'OutputView', panoramaView);
        mask = imwarp(true(size(I, 1), size(I, 2)), tforms(i), 'OutputView', panoramaView);
        panorama = step(blender, panorama, warpedImage, mask);
    end
    
end