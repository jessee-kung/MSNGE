function [h] = solve_lsq_h(W, h_init, x, itr_max)
    r = size(W, 2);
    alpha = 1;
    beta = 0.1;
    hk = h_init;
    
    for k=1:itr_max
        grad = W'*(W*hk - x);
        grad_norm = norm(grad(grad < 0 | hk > 0));
        if grad_norm < 1e-4
            break;
        end
        
        
        for i=1:40
            
            % f(xk+1) - f(xk) <= sigma * grad_f_W(xk)' * (xk+1 - xk)
            hkp1 = max(hk - alpha * grad, 0);
            d = hkp1 - hk;
            cond = norm(x - W*hkp1)^2 - norm(x - W*hk)^2 - 0.01 * grad' * d <= 0;
            if i == 1
                cond_1st = cond;
            end
            
            if ~cond_1st
                if ~cond
                    alpha = alpha * beta;
                else
                    hk = hkp1;
                    break;
                end
            else
                if cond
                    alpha = alpha / beta;
                    hk = hkp1;
                else
                    break;
                end
            end
        end
    end
    h = hk;
end