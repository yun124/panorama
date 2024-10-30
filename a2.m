clear;
% 2: FAST feature detector 
s1im1 = im2gray(im2double(imread("S1-im1.png")));
s1im2 = im2gray(im2double(imread("S1-im2.png")));

s2im1 = im2gray(im2double(imread("S2-im1.png")));
s2im2 = im2gray(im2double(imread("S2-im2.png")));
s2im3 = im2gray(im2double(imread("S2-im3.png")));
s2im4 = im2gray(im2double(imread("S2-im4.png")));


s3im1 = im2gray(im2double(imread("S3-im1.png")));
s3im2 = im2gray(im2double(imread("S3-im2.png")));
s3im3 = im2gray(im2double(imread("S3-im3.png")));
s3im4 = im2gray(im2double(imread("S3-im4.png")));


s4im1 = im2gray(im2double(imread("S4-im1.png")));
s4im2 = im2gray(im2double(imread("S4-im2.png")));
s4im3 = im2gray(im2double(imread("S4-im3.png")));
s4im4 = im2gray(im2double(imread("S4-im4.png")));


imwrite(my_fast_detector(s1im1) + s1im1, "S1-fast.png");

imwrite(my_fast_detector(s2im1) + s2im1, "S2-fast.png");



% 2: Robust FAST using Harris Cornerness metric

imwrite(my_fastr_detector(s1im1) + s1im1, "S1-fastR.png");
imwrite(my_fastr_detector(s2im1) + s2im1, "S2-fastR.png");




% 3: Point description and matching
% SURF



% detect point features from FAST points
s1im1Points = detectSURFFeatures(my_fast_detector(s1im1));
s2im1Points = detectSURFFeatures(my_fast_detector(s2im1));
s1im2Points = detectSURFFeatures(my_fast_detector(s1im2));
s2im2Points = detectSURFFeatures(my_fast_detector(s2im2));

% extract feature descriptors at the points
[s1im1Features, s1im1Points] = extractFeatures(s1im1, s1im1Points);
[s2im1Features, s2im1Points] = extractFeatures(s2im1, s2im1Points);
[s1im2Features, s1im2Points] = extractFeatures(s1im2, s1im2Points);
[s2im2Features, s2im2Points] = extractFeatures(s2im2, s2im2Points);

% match the features using descriptors
s1Pairs = matchFeatures(s1im1Features, s1im2Features);
s2Pairs = matchFeatures(s2im1Features, s2im2Features);

% display matched features for S1
matchedS1im1Points = s1im1Points(s1Pairs(:, 1), :);
matchedS1im2Points = s1im2Points(s1Pairs(:, 2), :);
f1 = figure(1);
showMatchedFeatures(s1im1, s1im2, matchedS1im1Points, ...
    matchedS1im2Points, 'montage');
saveas(f1, "S1-fastMatch.png")


% display matched features for S2
matchedS2im1Points = s2im1Points(s2Pairs(:, 1), :);
matchedS2im2Points = s2im2Points(s2Pairs(:, 2), :);
f2 = figure(2);
showMatchedFeatures(s2im1, s2im2, matchedS2im1Points, ...
    matchedS2im2Points, 'montage');
saveas(f2, "S2-fastMatch.png")




% detect point features from FASTR points
s1im1RPoints = detectSURFFeatures(my_fastr_detector(s1im1));
s2im1RPoints = detectSURFFeatures(my_fastr_detector(s2im1));
s1im2RPoints = detectSURFFeatures(my_fastr_detector(s1im2));
s2im2RPoints = detectSURFFeatures(my_fastr_detector(s2im2));

% extract feature descriptors at the points
[s1im1RFeatures, s1im1RPoints] = extractFeatures(s1im1, s1im1RPoints);
[s2im1RFeatures, s2im1RPoints] = extractFeatures(s2im1, s2im1RPoints);
[s1im2RFeatures, s1im2RPoints] = extractFeatures(s1im2, s1im2RPoints);
[s2im2RFeatures, s2im2RPoints] = extractFeatures(s2im2, s2im2RPoints);

% match the features using descriptors
s1RPairs = matchFeatures(s1im1RFeatures, s1im2RFeatures);
s2RPairs = matchFeatures(s2im1RFeatures, s2im2RFeatures);


% display matched features for S1
matchedS1im1RPoints = s1im1RPoints(s1RPairs(:, 1), :);
matchedS1im2RPoints = s1im2RPoints(s1RPairs(:, 2), :);
f3 = figure(3);
showMatchedFeatures(s1im1, s1im2, matchedS1im1RPoints, ...
    matchedS1im2RPoints, 'montage');
saveas(f3, "S1-fastRMatch.png")

% display matched features for S2
matchedS2im1RPoints = s2im1RPoints(s2RPairs(:, 1), :);
matchedS2im2RPoints = s2im2RPoints(s2RPairs(:, 2), :);
f4 = figure(4);
showMatchedFeatures(s2im1, s2im2, matchedS2im1RPoints, ...
    matchedS2im2RPoints, 'montage');
saveas(f4, "S2-fastRMatch.png")



%clear;
% 4: RANSAC and Panoramas

imageFolder = fullfile(pwd);



imageFiles = {'S1-im1.png', 'S1-im2.png'};
imds = imageDatastore(fullfile(imageFolder, imageFiles));
s1rPano = generate_panorama(@my_fastr_detector, imds, 99, 6000, 1.7);
%imshow(s1rPano)
imwrite(s1rPano, "S1-panorama.png");

imageFiles = {'S2-im1.png', 'S2-im2.png'};
imds = imageDatastore(fullfile(imageFolder, imageFiles));
s2rPano = generate_panorama(@my_fastr_detector, imds, 99, 6000, 1.7);
imwrite(s2rPano, "S2-panorama.png");
%imshow(s2rPano)
imageFiles = {'S3-im1.png', 'S3-im2.png'};
imds = imageDatastore(fullfile(imageFolder, imageFiles));
s3rPano = generate_panorama(@my_fastr_detector, imds, 99, 6000, 1.7);
imwrite(s3rPano, "S3-panorama.png")
%imshow(s3rPano)
imageFiles = {'S4-im1.png', 'S4-im2.png'};
imds = imageDatastore(fullfile(imageFolder, imageFiles));
s4rPano = generate_panorama(@my_fastr_detector, imds, 99, 6000, 1.7);
imwrite(s4rPano, "S4-panorama.png");
%imshow(s5rPano)

%%

%imageFolder = fullfile(pwd);
imageFiles = {'S2-im1.png', 'S2-im2.png', 'S2-im3.png', 'S2-im4.png'};
imds = imageDatastore(fullfile(imageFolder, imageFiles));
s2rPano4 = generate_panorama(@my_fastr_detector, imds, 99, 800000, 1.7);
imwrite(s2rPano4, "S2-panorama4.png");

%%

imageFiles = {'S4-im1.png', 'S4-im2.png', 'S4-im3.png', 'S4-im4.png'};
imds = imageDatastore(fullfile(imageFolder, imageFiles));
s4rPano4 = generate_panorama(@my_fastr_detector, imds, 95, 800000, 1.8);
imwrite(s4rPano4, "S4-panorama4.png");
