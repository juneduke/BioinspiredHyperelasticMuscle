%%Initialize%%
clear all;
clc;
close all;

%% Load and preprocess the first dataset
cd('DIRECTORY'); %Change Directory
load("DataSet1.mat");
X = [BicepVolume, TricepVolume, BicepOptical, TricepOptical];
Y = Angle;

% Standardize the first dataset
X_mean = mean(X,1);
X_std  = std(X,0,1);
X_norm = (X - X_mean) ./ X_std;


%% Load and preprocess the second dataset
load("DataSet2.mat");
X2 = [BicepVolume2, TricepVolume2, BicepOptical2, TricepOptical2];
Y2 = Angle2;

% Standardize the second dataset
X_mean2 = mean(X2,1);
X_std2  = std(X2,0,1);
X_norm2 = (X2 - X_mean2) ./ X_std2;

%% Combine both datasets
X_combined = [X_norm; X_norm2];
Y_combined = [Y; Y2];

%% PCA (optional) on combined set
[coeffs, score, latent, tsquared, explained] = pca(X_combined);

disp('Variance explained by each PC (combined):');
disp(explained);

% 95% variance Principal Components
cumulativeVar   = cumsum(explained) / sum(explained);
numPCs_95       = find(cumulativeVar >= 0.95, 1);
disp("Number of PCs for >=95% variance: " + num2str(numPCs_95));

%% Principal Component Analysis
[coeffs, score, latent, tsquared, explained] = pca(X);

% Compute number of components from explained variance
enoughExplained = cumsum(explained)/sum(explained) >= 95/100;
numberOfComponentsToKeep = find(enoughExplained, 1);
disp("The number of components needed to explain at least 95% of the variance is "+ num2str(numberOfComponentsToKeep))

%% PCA Visualization

figure;
colorMap = colormap("lines");
barPlot = bar(explained);
hold on;
plot(cumsum(explained),"o-");
hold off;
barPlot(1).FaceColor = "flat";
barPlot(1).CData(1:numberOfComponentsToKeep,:) = repmat(colorMap(2,:),[numberOfComponentsToKeep 1]);
label = ["Selected components"; sprintf("Cumulative explained\nvariance")];
legend(label,"Location","best");
title("Scree Plot of Explained Variances")
xlabel("Principal component")
ylabel("Variance explained (%)")
clear barPlot colorMap label explained

figure();
biplot(coeffs(:,1:2),'varlabels',{'BicepVolume','TricepVolume','BicepOptical','TricepOptical'});

figure();
scatter3(score(:,1),score(:,2),score(:,3));
axis equal;
xlabel('1st Principal Component');
ylabel('2nd Principal Component');
zlabel('3rd Principal Component');



corrWithPC1 = corr(score(:,1), Y);
fprintf('Correlation of Angle with PC1: %.4f\n', corrWithPC1);

%% Train Neural Network with Early Stopping

% Define the network
hiddenLayerSize = [40, 20];
net = fitnet(hiddenLayerSize, 'trainlm');

% Data splits for early stopping: 70% training, 15% validation, 15% testing
net.divideParam.trainRatio = 0.7;
net.divideParam.valRatio   = 0.15;
net.divideParam.testRatio  = 0.15;

% Training parameters
net.trainParam.show   = 1;       % Show training progress updates
net.trainParam.lr     = 0.01;    % Learning rate
net.trainParam.epochs = 200;     % Number of epochs
net.trainParam.goal   = 1e-6;    % Desired MSE
net.trainParam.max_fail = 6;     % Early stopping criterion (validation fails)


% Data Formatting
net = configure(net, X_combined', Y_combined');
[net, tr] = train(net, X_combined', Y_combined');


% Evaluate performance
testX = X_combined(tr.testInd, :)';
testY = Y_combined(tr.testInd)';
testY_pred = net(testX);
mse_test = mean((testY - testY_pred).^2);
ss_res   = sum((testY - testY_pred).^2);
ss_tot   = sum((testY - mean(testY)).^2);
r2_test  = 1 - (ss_res / ss_tot);

fprintf('Test MSE: %.4f\n', mse_test);
fprintf('Test R^2: %.4f\n', r2_test);


%% Permutation-based Feature Importance 

% Baseline MSE on test set
baselineMSE = mse_test;
featureImportance = zeros(1, size(X_combined,2));

for i = 1:size(X_combined,2)
    % Permute the i-th feature in test set
    testX_permuted = testX;
    idx = randperm(size(testX,2));
    testX_permuted(i,:) = testX(i, idx);

    % Predict from permuted data
    permY_pred = net(testX_permuted);

    % Calculate permuted MSE
    permMSE = mean((testY - permY_pred).^2);
    featureImportance(i) = permMSE - baselineMSE;
end

disp('Feature Importance (Permutation Method):');
disp('Features: [BicepVolume, TricepVolume, BicepOptical, TricepOptical]');
disp(featureImportance);

