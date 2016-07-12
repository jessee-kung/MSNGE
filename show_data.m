function show_data(X,Xy,M,My)
    %% USEFUL HINTS
    %
    % To export figure to expected size, use following instructions:
    %
    % set(gcf, 'PaperUnits', 'inches', 'PaperPosition', [0 0 4 3]);
    % print(gcf, '-depsc', 'target.eps');
    %
    
    [l, N] = size(X);
    c = size(unique(Xy), 1);
    
    if c <= 6
        pale = jet(9);
        pale = hsv2rgb(rgb2hsv( pale([2,4,6,7,9,8], :) ) - repmat([0 0.1 0.05], 6, 1));
        
    else
        pale = [zeros(c, 1), 0.9 * ones(c, 2)];
        hue = 0;
        for i=1:c
            pale(i, 1) = hue;
            pale(i, :) = hsv2rgb(pale(i, :));
            hue = hue + (1/(c-1));
        end
        pale = max(pale, 0);
        pale = min(pale, 1);
    end
    
    if(l ~= 2)
        fprintf('No plot can be generated\n');
        return
    else
        figure();
        hold on;
        for i=1:N
            scatter(X(1,i), X(2,i), 10, 'MarkerFaceColor', pale(Xy(i), :), 'MarkerEdgeColor', pale(Xy(i), :));
        end
        
        if nargin > 3
            nM = size(M, 2);
            for i=1:nM
                plot(M(1,i), M(2,i), '+', 'Color', pale(My(i), :));
                %scatter(M(1,i), M(2,i), 'MarkerFaceColor', [1 1 1], 'MarkerEdgeColor', pale(Xy(i), :));
            end
        elseif nargin > 2
            nM = size(M, 2);
            for i=1:nM
                plot(M(1,i), M(2,i), 'k+');
            end
        end
        hold off;
    end
end