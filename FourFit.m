pkg load optim

% Define the function to fit (the first three terms of the Fourier series)
fourier = @(b,x) b(1) + b(2)*cos(x*b(3)) + b(4)*sin(x*b(5));

% Generate some noisy data that cannot be described with the first three terms of the Fourier series
x = linspace(0,2*pi,50)';
y = 2*sin(2*x) + 3*sin(3*x) + 4*sin(4*x) + 0.2*randn(size(x));

% Define the residual function
residual = @(b) y - fourier(b,x);

% Initial guess for the parameters
b0 = [0, 1, 1, 1, 1];

% Perform the fitting using lsqnonlin
options = optimset('Display','off');
[beta,resnorm,residual,exitflag,output,lambda,jacobian] = lsqnonlin(residual,b0,[],[],options);

% Calculate the goodness of fit
sse = sum(residual.^2);
sst = sum((y-mean(y)).^2);
rsq = 1 - sse/sst;

% Calculate the standard error and confidence interval for each parameter
n = length(y);
J = full(jacobian);
se = sqrt(diag(inv(J'*J)*sse/(n-length(beta))));
ci = tinv(0.975,n-length(beta))*se;
lower = beta - ci;
upper = beta + ci;

% Calculate the p-value
dof = n - length(beta);
F = (rsq/(length(beta)-1))/((1-rsq)/dof);
p_value = 1 - fcdf(F, length(beta)-1, dof);

% Plot the data and the fit
xfit = linspace(0,2*pi,200)';
yfit = fourier(beta,xfit);
figure;
plot(x,y,'bo',xfit,yfit,'r-');
legend('Data','Fit');
xlabel('x');
ylabel('y');
title('Fourier Fit');

% Display the results as text in the figure
fprintf('b1 = %f +/- %f\n', beta(1), ci(1));
fprintf('b2 = %f +/- %f\n', beta(2), ci(2));
fprintf('b3 = %f +/- %f\n', beta(3), ci(3));
fprintf('b4 = %f +/- %f\n', beta(4), ci(4));
fprintf('b5 = %f +/- %f\n', beta(5), ci(5));
fprintf('R-squared = %f\n', rsq);
fprintf('p-value = %f\n', p_value);
