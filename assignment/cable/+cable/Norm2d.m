classdef Norm2d
    % Bivariate normal likelihood equivalence class
    properties
        Mean(2,1) double
        Covariance(2,2) double
        Precision(2,2) double
        Correlation double
    end
    
    % Public methods
    methods
        % Constructor
        function obj = Norm2d(mu,sigma)
            % May need to do this as varargin
            % Set default values
            if nargin < 1
                mu = [0;0];
                sigma = ones(2);
            elseif nargin < 2
                sigma = ones(2);
            end

            % Set up obj
            obj.Mean = 0;
            obj.Covariance = 0;
            
            % Set values
            obj = set.Mean(obj,mu);
            obj = set.Covar(obj,sigma);
        end
        
        % Math stuff
        function pdfOut = pdf(X,Mu,Sigma)
            % Calculate the probability density function
            % X is a 2xn matrix
            % pdfOut is a 1xn matrix
            
            % Check inputs
            verifyMean(Mu);
            verifySigma(Sigma);
            verifyX(X);
            
            if nargin < 2
                Mu = [0;0];
                Sigma = ones(2);
            elseif nargin < 3
                Sigma = ones(2);
                Sigma = Sigma + eye(size(Sigma));
            end
            
            rho = Sigma(1,2) / sqrt(Sigma(1,1) * Sigma(2,2));
            sigma1 = sqrt(Sigma(1,1));
            sigma2 = sqrt(Sigma(2,2));
            z = ((X(1,:) - Mu(1))/sigma1).^2 - ...
                2 * rho .* ((X(1,:) - Mu(1))/sigma1) .* ...
                ((X(2,:) - Mu(2))/sigma2) + ...
                ((X(2,:) - Mu(2))/sigma2).^2;
            
            pdfOut = 1/(2*pi*sigma1*sigma2*sqrt(1 - rho^2)) * ...
                exp((-1/2) * z/(1 - rho^2));
        end
        function logpdfOut = logpdf(X,Mu,Sigma)
            % DON'T just take the log of pdfOut
            % That is technically what you do, but "simplify" the equation
            
            % Check inputs
            verifyMean(Mu);
            verifySigma(Sigma);
            verifyX(X);
            
            if nargin < 2
                Mu = [0;0];
                Sigma = ones(2);
            elseif nargin < 3
                Sigma = ones(2);
            end
            
            rho = Sigma(1,2) / sqrt(Sigma(1,1) * Sigma(2,2));
            sigma1 = sqrt(Sigma(1,1));
            sigma2 = sqrt(Sigma(2,2));
            z = ((X(1,:) - Mu(1))/sigma1).^2 - ...
                2 * rho .* ((X(1,:) - Mu(1))/sigma1) .* ...
                ((X(2,:) - Mu(2))/sigma2) + ...
                ((X(2,:) - Mu(2))/sigma2).^2;
            
            logpdfOut = log(1) - log(2*pi*sigma1*sigma2*sqrt(1 - rho^2)) + ...
                ((-1/2) * z/(1 - rho^2)) * exp(1);
        end
        function cdfOut = cdf(X,Mu,Sigma)
            % freebie
            verifyMean(Mu);
            verifySigma(Sigma);
            verifyX(X);
            
            cdfOut = mvncdf(X,Mu,Sigma);
        end
        function logcdfOut = logcdf(X,Mu,Sigma)
            % freebie
            verifyMean(Mu);
            verifySigma(Sigma);
            verifyX(X);
            logcdfOut = log(mvncdf(X,Mu,Sigma));
        end
        function sample = rng(Mu,Sigma,dimMat)
            % Pull a random sample from this distribution
            verifyMean(Mu);
            verifySigma(Sigma);
            verifySize(dimMat);
            % Preallocate
            sample = zeros(dimMat);
            fprintf(1,"This function isn't ready yet, sorry.\n")
            % Sample from first distribution
%             x1 = Mu(1) .* rand(size(sample(:,1)));
%             sample(:,1) = pdf(x1,Mu(1),Sigma(1));
%             % sample from second distribution
%             sample(:,2) = pdf(; % use sample(:,1), mu(2), and sigma(4)

        end
        function dev = deviance(Data,Mu,Sigma)
            % Data is an n*2 matrix (2 cols, n rows)
            X = linspace(1,size(Data,1),size(Data,1));
            X = [X,X];
            dev = (-2) * sum(logpdf(X,Mu,Sigma),'all');
        end
        
        % Getters
        function meanOut = get.Mean(obj)
            meanOut = obj.Mean;
        end
        function covarOut = get.Covariance(obj)
            covarOut = obj.Covariance;
        end
        function precisionOut = get.Precision(obj)
            precisionOut = obj.Precision;
        end
        function corrOut = get.Correlation(obj)
            corrOut = obj.Correlation;
        end
        
        % Setters
        function obj = set.Mean(obj,val)
%             if size(val) ~= [2,2]
%                 check = FALSE;
%                 while check == FALSE
%                     % check
%                     if size(val) == [2,2]
%                         check = TRUE;
%                     end
%                 end
%             end
            
            verifyMean(val);
            obj.Mean = val;
            obj = updateMean(obj); % Derivatives
        end
        function obj = set.Covariance(obj,val)
            verifySigma(val);
            obj.Covariance = val;
            obj = updateCovar(obj);
        end
    end
    
    % Hidden methods
    methods (Access = private)
        % Update derivative values
        function obj = updateMean(obj)
            % Recalculate values that rely on obj.Mean
            
        end
        function obj = updateCovar(obj)
            % Recalculate values that rely on obj.Covariance
            % Precision is the inverse of Covar
                % Make sure it is invertible first!!
            obj.Precision = inv(obj.Covariance);
            obj.Correlation = obj.Covariance(1,2) / sqrt(obj.Covariance(1,1) * obj.Covariance(2,2));
        end
        
        % Validate inputs
        function verifyMean(Mu)
            % Cannot take strings etc
            checkNumber(Mu,"Mu");
            % Must be 2*1 in size
            if ~isequal(size(Mu),[2,1])
                error("Error: Mean (mu) must be a 2x1 vector.");
            end
            % Must be real
            checkReal(Mu,"Mu");
            % Must not be infinity
            checkInf(Mu,"Mu");
            % If you can get to this point, it should be good
        end
        function verifySigma(Sigma)
            % Cannot take strings etc
            checkNumber(Sigma,"Sigma");
            % Must be 2*2 in size
            if ~isequal(size(Mu),[2,2])
                error("Error: Sigma must be a 2x2 matrix.");
            end
            % Must be real
            checkReal(Sigma,"Sigma");
            % Must not be infinity
            checkInf(Sigma,"Sigma");
            % Must be invertible
            if det(Sigma) == 0
                error("Error: Determinant of sigma is 0; cannot invert.")
            end
            % Values must conform to equation
            if Sigma(2) ~= Sigma(3)
                error("Error: off-diagonal elements of Sigma are not equal")
%             elseif Sigma(2) ~= sqrt(Sigma(1) * Sigma(4))
%                 error("Error: off-diagonal elements of Sigma are wrong(?)")
            end
            
            
            % If you can get to this point, it should be good
        end
        function verifyX(X)
            % Cannot take strings etc
            checkNumber(X,"X");
            % Must be 2*n in size
            A = size(X);
            if size(A) > 2
                error("Error: X has more than two dimensions.")
            elseif A(1) ~= 2
                error("Error: X must have two rows.")
            end
            % Must not have infinite values
            checkInf(X,"X");
            % Must not have imaginary values
            checkReal(X,"X");
        end
        function verifySize(dimMat)
            % calling it dimMat since size() is a built-in function
            % Cannot take strings etc
            checkNumber(dimMat,"size");
            % Can't take 3+ dimensions
            A = size(dimMat);
            if size(A) > 2
                error("Error: Size has more than two dimensions.")
            end
            % Must not have infinite values
            checkInf(dimMat,"size");
            % Must not have imaginary values
            checkReal(dimMat,"size");
        end
        
        % Subfunctions
        function checkInf(var,varStr)
            % Checks whether any matrix elements are infinity
            % varStr is a string of the variable's name, for errors
            A = find(var == Inf);
            if A
                error("Error: Element %i of %s must be finite.",A(1),varStr);
            end
        end
        function checkReal(var,varStr)
            % Checks whether any matrix elements are imaginary
            % varStr is a string of the variable's name, for errors
            A = find(~isreal(var));
            if A
                error("Error: Element %i of %s is imaginary.",A(1),varStr);
            end
        end
        function checkNumber(var,varStr)
            if ~isnumeric(var)
                error("Error: %s is not a numeric variable.",varStr);
            end
        end
    end
end