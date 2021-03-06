%% psi: entry values
%% s: with the waited values for each given set of entry data
%% iterations: maximum amount of iterations
%% hiddenLayerSizes: array containing the size of each hidden layer
%% g: transference function
%% gDeriv: derivative of the transference function

function[W, trainingMeanErrors, testingMeanErrors, trainingQuadraticMeanError] = backpropagation(psiTrain, psiTest, sTrain, sTest, n, error, iterations, hiddenLayerSizes, g, gDeriv, psiNormalizer, sNormalizer, denormalizer, showProgress)

    psi = psiNormalizer(psiTrain);
    s = sNormalizer(sTrain);
    
    layerSizes = [length(psi(1,:)) hiddenLayerSizes length(s(:,1))];

    M = length(layerSizes);

    V = cell(1,M);

    W = cell(1,M);
    
    H = cell(1,M);
    
    Delta = cell(1,M);
    o = zeros(length(s(:,1)),length(s));
    
    diff = o - s;
    trainingMeanErrors = [];
    testingMeanErrors = [];
    
    finish = false;
    epoch = 0;
    showProgress = nargin == 14; % If nargin is 14, function was called using the showProgress value
    
    for m = 2:M
       limit = (layerSizes(m-1)+1)^(1/2);
       W{m} = rand([layerSizes(m) (layerSizes(m-1)+1)])*2*limit - limit;
    end
    
    while(epoch ~= iterations && ~finish)
       epoch = epoch+1;
       indexes = randperm(length(s));
       
       for i = indexes
          
           %% step 2
           V{1} = psi(i,:)';
           V{1} = [-1; V{1}];
           
           %% step 3
           for m = 2:M
               H{m} = W{m}*V{m-1};
               V{m} = g(H{m});
               if(m ~= M)
                 V{m} = [-1; V{m}];
               end
           end

          if showProgress && mod(i, 100) == 0
            plotTerrain(psi, o);
          end
           
           %% step 4
           Delta{M} = gDeriv(H{M}).*(s(:,i)-V{M});
           
           %% step 5
           for m = M:-1:3
              Delta{m-1} = gDeriv(H{m-1}).*(W{m}(:,2:end)'*Delta{m});
           end
           
           %% step 6
           for m = 2:M    
               W{m} = W{m} + n*Delta{m}*(V{m-1}');
           end
           
           
           o(:,i) = V{M};
           diff = o - s;
           
           if(abs(diff) < error)
               finish = true;
           end
           
       end
       
       trainingMeanErrors = [trainingMeanErrors mean(abs(sTrain-denormalizer(o)))];
       testingMeanErrors = [testingMeanErrors mean(abs(sTest'-test(psiTest,sTest,W,g,psiNormalizer,denormalizer)))];
       
       
    end
    epoch
    trainingQuadraticMeanError = mean(diff.^2);

end
